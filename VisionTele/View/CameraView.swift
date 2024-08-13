import SwiftUI
import RealityKit
import CoreImage
import ARKit
import Foundation
import UIKit
import Vision

struct Detection {
    let box: CGRect
    let confidence: Float
    let label: String?
    let color: UIColor
}


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
            cameraModel!.startserver()
        }
        .task {
            await cameraModel!.processDeviceAnchorUpdates(withFrequency: 30)
        }
        .task {
            await cameraModel!.processCameraFrameUpdates(withFrequency: 30)
        }
        .onDisappear() {
            print("onDisappear")
            cameraModel!.stop()
        }
    }
}

struct CameraCapture: View {
    @State private var frameImage: UIImage = UIImage(named: "no_frame")!

    var body: some View {
        HStack {
            Image(uiImage: frameImage).scaledToFit()
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: {_ in
                DispatchQueue.global(qos: .background).async {
                    if DataManager.shared.latestFrame.count > 0 {
                        let uiImage = DataManager.shared.latestuiImage
                        self.frameImage = uiImage
                    }
                }
            })
        }
        .padding()
        .glassBackgroundEffect()
    }
    
}
