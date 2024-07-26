import SwiftUI
import RealityKit
import CoreImage
import ARKit

struct CameraView: View {
    @State private var cameraModel: CameraModel?
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        RealityView {_ in}
        .onAppear() {
            cameraModel = CameraModel()
            openWindow(id: "showingCameraFrame")
        }
        .task {
            cameraModel!.run()
        }
        .task {
            await cameraModel!.processCameraFrameUpdates(withFrequency: 10)
        }
        .onDisappear() {
            print("onDisappear")
            cameraModel!.stop()
        }
    }
}

struct CameraCapture: View {
    @State private var inputImage: UIImage = UIImage(named: "no_frame")!
    
    
    var body: some View {
        VStack {
            Image(uiImage: inputImage).scaledToFit()
                
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: {_ in
                DispatchQueue.global(qos: .background).async {
                    if DataManager.shared.latestFrame.count > 0 {
                        self.inputImage = DataManager.shared.latestuiImage
                    }
                }
            })
        }
        .padding()
        .glassBackgroundEffect()
    }
}
