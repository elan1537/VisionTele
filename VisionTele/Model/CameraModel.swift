import RealityKit
import ARKit
import CoreImage
import SwiftUI
import Foundation
import GRPC
import NIO


final class CameraModel: ObservableObject {
    private let session = ARKitSession()
    private let cameraProvider = CameraFrameProvider()
    private let worldTracking = WorldTrackingProvider()
    private let formats = CameraVideoFormat.supportedVideoFormats(for: .main, cameraPositions: [.left])

    func run() {
        guard CameraFrameProvider.isSupported else {
            print("CameraFrameProvider is NOT supported")
            return
        }
        
        Task {
            @MainActor in
            _ = await session.requestAuthorization(for: [.worldSensing, .cameraAccess])
            
            do {
                try await session.run([worldTracking, cameraProvider])
                print("ARKit session is running...")
            } catch {
                print("ARKit Session error \(error)")
            }
        }
    }
    
    func stop() {
        session.stop()
    }
    
    func startserver() {
        Task { startServer() }
    }
    
    func uiImageFromPixelBuffer(pixelBuffer: CVPixelBuffer) -> UIImage? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil

        }
        return UIImage(cgImage: cgImage)
    }
    
    func arrayFromTransform(_ transform: simd_float4x4) -> [[Float]] {
        var array: [[Float]] = Array(repeating: Array(repeating: Float(), count: 4), count: 4)
        array[0] = [transform.columns.0.x, transform.columns.1.x, transform.columns.2.x, transform.columns.3.x]
        array[1] = [transform.columns.0.y, transform.columns.1.y, transform.columns.2.y, transform.columns.3.y]
        array[2] = [transform.columns.0.z, transform.columns.1.z, transform.columns.2.z, transform.columns.3.z]
        array[3] = [transform.columns.0.w, transform.columns.1.w, transform.columns.2.w, transform.columns.3.w]
        return array
    }
}

extension CameraModel {
    
    @MainActor
    func processDeviceAnchorUpdates(withFrequency hz: UInt64) async {
        let nanaoSecondsToSleep: UInt64 = NSEC_PER_SEC / hz
        
        while true {
            if Task.isCancelled { return }
            
            do {
                try await Task.sleep(nanoseconds: nanaoSecondsToSleep)
            } catch {
                return
            }
            
            await self.queryAndProcessLatestDeviceAnchor()
        }
    }
    
    @MainActor
    private func queryAndProcessLatestDeviceAnchor() async {
        guard worldTracking.state == .running else { return }
        
        let deviceAnchor = worldTracking.queryDeviceAnchor(atTimestamp: CACurrentMediaTime())

        guard let deviceAnchor, deviceAnchor.isTracked else { return }
        
        DataManager.shared.latestHead = deviceAnchor.originFromAnchorTransform
    }
    
    @MainActor
    func processCameraFrameUpdates(withFrequency hz: UInt64) async {
        guard let cameraFrameUpdates = cameraProvider.cameraFrameUpdates(for: formats[0]) else { return }

        for await cameraFrame in cameraFrameUpdates {
        
            guard let mainCameraSample = cameraFrame.sample(for: .left) else {
                print("No nextElements?")
                continue
            }
            
            let parameters = mainCameraSample.parameters
            let pixelBuffer = mainCameraSample.pixelBuffer
            let uiImage = self.uiImageFromPixelBuffer(pixelBuffer: pixelBuffer)!
            
            DispatchQueue.main.async {
                DataManager.shared.latestParameters.extrinsics = parameters.extrinsics
                DataManager.shared.latestParameters.intrinsic = parameters.intrinsics
                DataManager.shared.latestParameters.cameraPosition = parameters.cameraPosition.description
                DataManager.shared.latestParameters.cameraType = parameters.cameraType.description
                DataManager.shared.latestParameters.captureTime = parameters.captureTimestamp
                DataManager.shared.latestParameters.colorTemperature = parameters.colorTemperature
                DataManager.shared.latestParameters.exposureDuration = parameters.exposureDuration
                DataManager.shared.latestParameters.midExposureTimestamp = parameters.midExposureTimestamp
                
                if let jpegData = uiImage.jpegData(compressionQuality: 1.0) {
                    DataManager.shared.latestFrame = jpegData
                    DataManager.shared.latestuiImage = uiImage
                }
            }
        }
    }
}

class FrameTrackingServiceProvider: Frametracking_FrameTrackingServiceProvider {
    func streamFrameUpdates(request: Frametracking_FrameUpdate, context: StreamingResponseCallContext<Frametracking_FrameUpdate>) -> EventLoopFuture<GRPC.GRPCStatus> {
        
        let eventLoop = context.eventLoop
        let task = eventLoop.scheduleRepeatedAsyncTask(initialDelay: .milliseconds(10), delay: .milliseconds(10)) { task -> EventLoopFuture<Void> in
            
            let recent_frame = fill_frameUpdates()
            return context.sendResponse(recent_frame).map { _ in }
        }
        
        context.statusPromise.futureResult.whenComplete { _ in task.cancel() }
        return eventLoop.makePromise(of: GRPCStatus.self).futureResult

    }
    
    var interceptors: Frametracking_FrameTrackingServiceServerInterceptorFactoryProtocol?
}

func fill_frameUpdates() -> Frametracking_FrameUpdate {
    var videoUpdate = Frametracking_FrameUpdate()
    
    videoUpdate.head = createMatrix4x4(from: DataManager.shared.latestHead!)
    videoUpdate.extrinsic = createMatrix4x4(from: DataManager.shared.latestParameters.extrinsics)
    videoUpdate.intrinsic = createMatrix3x3(from: DataManager.shared.latestParameters.intrinsic)
    videoUpdate.captureTime = DataManager.shared.latestParameters.captureTime
    videoUpdate.midExposureTimestamp = Int32(DataManager.shared.latestParameters.midExposureTimestamp)
    videoUpdate.colorTemperature = Int32(DataManager.shared.latestParameters.colorTemperature)
    videoUpdate.exposureDuration = DataManager.shared.latestParameters.exposureDuration
    videoUpdate.cameraType = DataManager.shared.latestParameters.cameraType
    
    videoUpdate.cameraPosition = DataManager.shared.latestParameters.cameraPosition
    videoUpdate.image = DataManager.shared.latestFrame
    
    let timestamp = Date().timeIntervalSince1970
    // Extract the fractional part representing the nanoseconds
    let fractionalPart = timestamp.truncatingRemainder(dividingBy: 1.0)

    // Convert the fractional part to nanoseconds and then to an integer
    let nanoseconds = Int(fractionalPart * 1_000_000_000)
    
    videoUpdate.seconds = Int64(timestamp)
    videoUpdate.nanos = Int32(nanoseconds)
    
    return videoUpdate
    
}


func startServer() {
    DispatchQueue.global().async {
        let port = 7000
        let host = "0.0.0.0"
        
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 4)
        defer {
            try! group.syncShutdownGracefully()
        }
        let provider = FrameTrackingServiceProvider()
        
        let server = GRPC.Server.insecure(group: group)
            .withServiceProviders([provider])
            .bind(host: host, port: port)
        server.map {
            $0.channel.localAddress
        }.whenSuccess { address in
            print("server started on \(address!) \(address!.port!)")
        }
        
        _ = try! server.flatMap {
            $0.onClose
        }.wait()
    }
}


