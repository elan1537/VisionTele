import RealityKit
import ARKit
import SwiftUI

@Observable class DevicePositionModel {
    private let session = ARKitSession()
    private let worldTracking = WorldTrackingProvider()
    
    var position: SIMD3<Float> = .zero
    var rotation: SIMD3<Float> = .zero
    
    init() {
        Task {
            @MainActor in
            _ = await session.requestAuthorization(for: [.worldSensing])
            do {
                try await session.run([worldTracking])
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
