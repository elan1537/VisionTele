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
        
        WindowGroup(id: "showingCameraFrame") {
            CameraCapture()
        }
    }
}
