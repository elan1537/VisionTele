import RealityKit
import ARKit
import SwiftUI

@Observable class DevicePositionModel {
    private let session = ARKitSession()
    private let worldTracking = WorldTrackingProvider()
    private let handTracking = HandTrackingProvider()
    private var handModel = HandTrackingModel()
    
    var handEntity = Entity()
    var position: SIMD3<Float> = .zero
    var rotation: SIMD3<Float> = .zero
    var isGrab: Bool = false
    
    var indexPosition: SIMD3<Float> = .zero
    
    init() {
        handModel.setup(entity: self.handEntity)
        Task {
            @MainActor in
            _ = await session.requestAuthorization(for: [.worldSensing, .handTracking])
            do {
                try await session.run([worldTracking, handTracking])
                await self.updateHandTracking()
            } catch {
                print("ARKit Session error \(error)")
            }
        }
    }
    
    func queryPosition() {
        guard let deviceAnchor = worldTracking.queryDeviceAnchor(atTimestamp: CACurrentMediaTime()) else {
            return
        }
        
        let dp = deviceAnchor.originFromAnchorTransform
        position = dp.xyz()
        rotation = dp.rot()
    }
    
    private func updateHandTracking() async {
        for await update in handTracking.anchorUpdates {
            let handAnchor = update.anchor
            
            guard handAnchor.isTracked,
                    let fingerTips = handAnchor.handSkeleton?.joint(.indexFingerTip),
                    let thumbTips = handAnchor.handSkeleton?.joint(.thumbTip),
                  fingerTips.isTracked, thumbTips.isTracked
            else {
                continue
            }
            
            let originFromWrist = handAnchor.originFromAnchorTransform
            let wristFromIndex = fingerTips.anchorFromJointTransform
            let wristFromThumb = thumbTips.anchorFromJointTransform
            let originFromIndex = originFromWrist * wristFromIndex
            let originFromThumb = originFromWrist * wristFromThumb
            
            guard handAnchor.chirality == .right else { continue }
            
            isGrab = isGrabbing(originFromThumb.xyz(), originFromIndex.xyz())
            indexPosition = originFromIndex.xyz()
        }
    }
    
    private func isGrabbing(_ indexAnchor: SIMD3<Float>, _ thumbAnchor: SIMD3<Float>) -> Bool {
        return distance(indexAnchor, thumbAnchor) < 0.01
    }
}

extension simd_float4x4 {
    func xyz() -> SIMD3<Float> {
        SIMD3<Float>(self.columns.3.x , self.columns.3.y , self.columns.3.z)
    }
    
    func rot() -> SIMD3<Float> {
        let pitch = asin(-self.columns.2.x) * 180 / .pi
        let yaw = atan2(self.columns.2.y, self.columns.2.z) * 180 / .pi
        let roll = atan2(self.columns.1.x, self.columns.0.x) * 180 / .pi
        
        return SIMD3<Float>(pitch, yaw, roll)
    }
}
