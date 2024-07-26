import SwiftUI

struct MainView: View {
    @State private var showCameraWindow = false
    
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    var body: some View {
        VStack {
            Toggle("Test camera feed", isOn: $showCameraWindow)
                .font(.title)
                .frame(width: 360)
                .padding(24)
                .glassBackgroundEffect()
        }.padding()
            .onChange(of: showCameraWindow, initial: false) {
                Task {
                    if showCameraWindow {
                        await openImmersiveSpace(id: "cameraSpace")
                    } else {
                        await dismissImmersiveSpace()
                    }
                }
            }
    }
}
