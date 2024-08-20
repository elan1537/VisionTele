import SwiftUI
import RealityKit
import ARKit
import simd
import URRobots

struct RobotControlView: View {
    private let devicePosition = DevicePositionModel()
    private let socketService = WebsocketService(url: URL(string: "ws://loctalhost:8000")!)
    
    @State var ctrIP: String = "ws://localhost:8000"
    @State var virtualtcpPosition: SIMD3<Float> = [0.0, 0.0, 0.0]
    @State var realtcpPosition: SIMD3<Float> = [0.0, 0.0, 0.0]
    @State var unmatchedPos: SIMD3<Float> = [0.0, 0.0, 0.0]
    @State var avpPosition: SIMD3<Float> = [0.0, 0.0, 0.0]
    @State var avpRotation: SIMD3<Float> = [0.0, 0.0, 0.0]
    
    @State var timer = Timer.publish(every: 0.011, on: .main, in: .common).autoconnect()
    @State var robot = Entity()
    @State var virtualTarget = Entity()
    @State private var isDragging = false
    @State private var initialOrientation: simd_quatf?
    @State private var preserveOrientationOnPivotDrag: Bool = true
    
    @State var headTrackedEntity: Entity = {
        let headAnchor = AnchorEntity(.head)
        headAnchor.position = [0, -0.15, -1]
        return headAnchor
    }()
        
    var body: some View {
        ZStack {
            RealityView { content, attachments in
                print("RobotControlView initialized")
                
                let robotEntity = await RobotEntity()
                
                robotEntity.position = [0.0, 1.0, -1.0]
                robotEntity.transform.rotation = .init(angle: -0.5 * .pi, axis: [0, 1, 0])
                updateRobotMotion(socketService.robotJoints)
                robot = robotEntity
            
                let fixedPoint = ModelEntity(mesh: .generateBox(size: 0.03), materials: [SimpleMaterial(color: .blue, isMetallic: false)])
                fixedPoint.setPosition([0.0, 0.0, 0.0], relativeTo: nil)
                
                
                virtualTarget = ModelEntity(
                    mesh: .generateBox(size: [0.03, 0.03, 0.03]),
                    materials: [
                        SimpleMaterial(color: .red, isMetallic: false)
                    ]
                )
                virtualTarget.components.set(InputTargetComponent(allowedInputTypes: .indirect))
                virtualTarget.generateCollisionShapes(recursive: true)
                virtualTarget.setPosition([-0.6354, 0.149, -0.002], relativeTo: robotEntity)
                
                if let serverAttachment = attachments.entity(for: "serverAddress") {
                    serverAttachment.position = [0.0, -0.05, 0.3]
                    serverAttachment.transform.rotation = .init(angle: 0.5 * .pi, axis: [0, 1, 0])
                    robot.addChild(serverAttachment)
                }
                
                if let virtualTCPAttachment = attachments.entity(for: "virtualTargetPos") {
                    virtualTCPAttachment.position = [0.0, -0.03, 0.0]
                    virtualTarget.addChild(virtualTCPAttachment)
                }
                
                
                if let hudAttachment = attachments.entity(for: "HUD") {
                    hudAttachment.position = [0.25, 0.0, 0.4]
                    headTrackedEntity.addChild(hudAttachment)
                }

                content.add(headTrackedEntity)
                content.add(virtualTarget)
                content.add(robot)
                content.add(fixedPoint)
                
            } update: { content, attachments in
                
            } attachments: {
                Attachment(id: "serverAddress") {
                    VStack {
                        Text("Hi.\n connected to \(ctrIP)")
                            .fontWeight(.bold)
                        
                        TextField("Enter the control server address...", text: $ctrIP)
                            .autocorrectionDisabled()
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.URL)
                            .onSubmit {
                                socketService.setUrl(url: URL(string: ctrIP)!)
                            }
                    }
                    .padding()
                    .glassBackgroundEffect()
                    .frame(width: 500, height: 300)
                }
                Attachment(id: "virtualTargetPos") {
                    let formatted = String(format: "%.4f, %.4f, %.4f", virtualtcpPosition[0],
                                           virtualtcpPosition[1],
                                           virtualtcpPosition[2])
                    VStack {
                        Text(formatted).fontWeight(.bold)
                    }
                    .padding()
                    .glassBackgroundEffect()
                    .frame(width: 500, height: 100)
                }
                
                Attachment(id: "HUD") {
                    let formatted = String(
                        format: "avpPos: %.4f, %.4f, %.4f\navpRot: %.4f, %.4f, %.4f\nrTCP: %.4f, %.4f, %.4f\nvirTCP: %.4f, %.4f, %.4f",
                            avpPosition.x, avpPosition.y, avpPosition.z,
                            avpRotation.x, avpRotation.y, avpRotation.z,
                            realtcpPosition.x, realtcpPosition.y, realtcpPosition.z,
                            virtualTarget.position(relativeTo: robot).x, virtualTarget.position(relativeTo: robot).y, virtualTarget.position(relativeTo: robot).z
                        )
                    VStack {
                        Text("Your Pos\n\(formatted)")
                            .fontWeight(.bold)
                            .font(.system(size: 24))
                    }
                    .padding()
                    .glassBackgroundEffect()
                }
            }
            .onReceive(timer) { _ in
                devicePosition.queryPosition()
                updateRobotMotion(socketService.robotJoints)
            
                avpPosition = devicePosition.position
                avpRotation = devicePosition.rotation
                
                realtcpPosition = socketService.tcpPos
                virtualtcpPosition = virtualTarget.position
            }
            .gesture(DragGesture().targetedToEntity(virtualTarget)
                .onChanged { value in
                    initialOrientation = value.entity.orientation(relativeTo: nil)
                    
                    var targetdPivotTransform = Transform()
                    if let inputDevicePose = value.inputDevicePose3D {
                        
                        targetdPivotTransform.scale = .one
                        targetdPivotTransform.translation = value.convert(inputDevicePose.position, from: .local, to: robot)
                        targetdPivotTransform.rotation = value.convert(
                            AffineTransform3D(rotation: inputDevicePose.rotation),
                            from: .local, to: robot).rotation
                    } else {
                        targetdPivotTransform.translation = value.convert(value.location3D, from: .local, to: robot)
                    }
                    
                    if !isDragging {
                        let pivotEntity = Entity()
                        guard let parent = virtualTarget.parent else { fatalError("Non-root entity is missing a parent.")}
                        parent.addChild(pivotEntity)
                        pivotEntity.move(to: targetdPivotTransform, relativeTo: robot)
                        pivotEntity.addChild(virtualTarget, preservingWorldTransform: true)
                        
                        isDragging = true
                    } else {
                        virtualTarget.move(to: targetdPivotTransform, relativeTo: robot)
                    }
                    
                    if preserveOrientationOnPivotDrag, let initialOrientation = initialOrientation {
                        virtualTarget.setOrientation(initialOrientation, relativeTo: robot)
                    }
                    
                    socketService.sendVirtualTCP(position: virtualTarget.position(relativeTo: robot))
                    
                }
                .onEnded { _ in isDragging = false }
            )
            .onDisappear {
                socketService.disconnect()
            }
        }
    }
    
    private func updateRobotMotion(_ joints: [Float]) {
        
        // 각 관절의 엔터티를 찾아서 orientation 업데이트
        if let r1Entity = robot.findEntity(named: "R1") {
            r1Entity.orientation = .init(angle: joints[0], axis: [0, 1, 0])
        }
        
        if let r2Entity = robot.findEntity(named: "R2") {
            r2Entity.orientation = .init(angle: joints[1], axis: [0, 0, 1])
        }
        
        if let r3Entity = robot.findEntity(named: "R3") {
            r3Entity.orientation = .init(angle: joints[2], axis: [0, 0, 1])
        }
        
        if let r4Entity = robot.findEntity(named: "R4") {
            r4Entity.orientation = .init(angle: joints[3], axis: [0, 0, 1])
        }
        
        if let r5Entity = robot.findEntity(named: "R5") {
            r5Entity.orientation = .init(angle: joints[4], axis: [0, -1, 0])
        }
        
        if let r6Entity = robot.findEntity(named: "R6") {
            r6Entity.orientation = .init(angle: joints[5], axis: [0, 0, 1])
        }
    }
}
