import Foundation
import RealityKit
import SwiftUI


class DataManager {
    static let shared = DataManager()
    
    var latestParameters: CameraParameterData = CameraParameterData()
    var latestHead: simd_float4x4?
    var latestFrame = Data()
    var latestuiImage = UIImage()
    
    private init() {}
}


struct CameraParameterData {
    var extrinsics: simd_float4x4 = simd_float4x4(1)
    var intrinsic: simd_float3x3 = simd_float3x3(1)
    var captureTime: TimeInterval = TimeInterval()
    var midExposureTimestamp: TimeInterval = TimeInterval()
    var colorTemperature = Int()
    var exposureDuration: CFTimeInterval = CFTimeInterval()
    var cameraType = String()
    var cameraPosition = String()
}

func createMatrix3x3(from jointMatrix: simd_float3x3) -> Frametracking_Matrix3x3 {
    var matrix = Frametracking_Matrix3x3()
    
    matrix.m00 = Float(jointMatrix.columns.0.x)
    matrix.m01 = Float(jointMatrix.columns.1.x)
    matrix.m02 = Float(jointMatrix.columns.2.x)

    matrix.m10 = Float(jointMatrix.columns.0.y)
    matrix.m11 = Float(jointMatrix.columns.1.y)
    matrix.m12 = Float(jointMatrix.columns.2.y)

    matrix.m20 = Float(jointMatrix.columns.0.z)
    matrix.m21 = Float(jointMatrix.columns.1.z)
    matrix.m22 = Float(jointMatrix.columns.2.z)
    
    return matrix
}

func createMatrix4x4(from jointMatrix: simd_float4x4) -> Frametracking_Matrix4x4 {
    var matrix = Frametracking_Matrix4x4()
    
    matrix.m00 = Float(jointMatrix.columns.0.x)
    matrix.m01 = Float(jointMatrix.columns.1.x)
    matrix.m02 = Float(jointMatrix.columns.2.x)
    matrix.m03 = Float(jointMatrix.columns.3.x)
    matrix.m10 = Float(jointMatrix.columns.0.y)
    matrix.m11 = Float(jointMatrix.columns.1.y)
    matrix.m12 = Float(jointMatrix.columns.2.y)
    matrix.m13 = Float(jointMatrix.columns.3.y)
    matrix.m20 = Float(jointMatrix.columns.0.z)
    matrix.m21 = Float(jointMatrix.columns.1.z)
    matrix.m22 = Float(jointMatrix.columns.2.z)
    matrix.m23 = Float(jointMatrix.columns.3.z)
    matrix.m30 = Float(jointMatrix.columns.0.w)
    matrix.m31 = Float(jointMatrix.columns.1.w)
    matrix.m32 = Float(jointMatrix.columns.2.w)
    matrix.m33 = Float(jointMatrix.columns.3.w)
    
    return matrix
}
