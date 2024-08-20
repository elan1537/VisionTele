import SwiftUI

@main
struct VisionTeleApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        
        ImmersiveSpace(id: "cameraSpace") {
            CameraView()
        }
        
        ImmersiveSpace(id: "robotControl") {
            RobotControlView()
        }.defaultSize(width: 2.0, height: 2.0, depth: 2.0)
        
        WindowGroup(id: "showingCameraFrame") {
            CameraCapture()
        }
    }
}
