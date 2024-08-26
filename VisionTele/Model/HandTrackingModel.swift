import SwiftUI
import RealityKit
import Observation

@Observable class HandTrackingModel {
    private static let handJoints: [AnchoringComponent.Target.HandLocation.HandJoint] = [
        .wrist,
        .thumbTip,
        .indexFingerTip,
        .thumbKnuckle,
        .thumbIntermediateBase,
        .thumbIntermediateTip,
        .indexFingerMetacarpal,
        .indexFingerKnuckle,
        .indexFingerIntermediateBase,
        .indexFingerIntermediateTip,
        .middleFingerMetacarpal,
        .middleFingerKnuckle,
        .middleFingerIntermediateBase,
        .middleFingerIntermediateTip,
        .middleFingerTip,
        .ringFingerMetacarpal,
        .ringFingerKnuckle,
        .ringFingerIntermediateBase,
        .ringFingerIntermediateTip,
        .ringFingerTip,
        .littleFingerMetacarpal,
        .littleFingerKnuckle,
        .littleFingerIntermediateBase,
        .littleFingerIntermediateTip,
        .littleFingerTip,
        .forearmWrist,
        .forearmArm,
    ]
    
    private static let handJointNames: [AnchoringComponent.Target.HandLocation.HandJoint: String] = [
        .wrist: "wrist",
        .thumbTip: "thumbTip",
        .indexFingerTip: "indexFingerTip",
        .thumbKnuckle: "thumbKnuckle",
        .thumbIntermediateBase: "thumbIntermediateBase",
        .thumbIntermediateTip: "thumbIntermediateTip",
        .indexFingerMetacarpal: "indexFingerMetacarpal",
        .indexFingerKnuckle: "indexFingerKnuckle",
        .indexFingerIntermediateBase: "indexFingerIntermediateBase",
        .indexFingerIntermediateTip: "indexFingerIntermediateTip",
        .middleFingerMetacarpal: "middleFingerMetacarpal",
        .middleFingerKnuckle: "middleFingerKnuckle",
        .middleFingerIntermediateBase: "middleFingerIntermediateBase",
        .middleFingerIntermediateTip: "middleFingerIntermediateTip",
        .middleFingerTip: "middleFingerTip",
        .ringFingerMetacarpal: "ringFingerMetacarpal",
        .ringFingerKnuckle: "ringFingerKnuckle",
        .ringFingerIntermediateBase: "ringFingerIntermediateBase",
        .ringFingerIntermediateTip: "ringFingerIntermediateTip",
        .ringFingerTip: "ringFingerTip",
        .littleFingerMetacarpal: "littleFingerMetacarpal",
        .littleFingerKnuckle: "littleFingerKnuckle",
        .littleFingerIntermediateBase: "littleFingerIntermediateBase",
        .littleFingerIntermediateTip: "littleFingerIntermediateTip",
        .littleFingerTip: "littleFingerTip",
        .forearmWrist: "forearmWrist",
        .forearmArm: "forearmArm"
    ]

    
    var rootEntity: Entity!
    
    func setup(entity: Entity) {
        rootEntity = entity
        rootEntity.addChild(HandTrackingModel.makeHandTrackingEntitiesAxis())
    }
    
    private static func makeHandTrackingEntitiesAxis() -> Entity {
        let container = Entity()
        container.name = "HandTrackingEntitiesContainerAxis"
        
        let baseEntity = Entity.createAxes(axisScale: 0.02)
        
        for chirality in [AnchoringComponent.Target.Chirality.left, AnchoringComponent.Target.Chirality.right] {
            for handJoint in self.handJoints {
                let joint = AnchoringComponent.Target.HandLocation.joint(for: handJoint)
                let anchor = AnchorEntity(.hand(chirality, location: joint), trackingMode: .predicted)
                anchor.addChild(baseEntity.clone(recursive: true))
                
                if let jointName = handJointNames[handJoint] {
                    anchor.name = "\(jointName) \(chirality)"
                }
                container.addChild(anchor)
            }
        }
        
        return container
    }
}

extension Entity {
    static func createAxes(axisScale: Float, alpha: CGFloat = 1.0) -> Entity {
        let axisEntity = Entity()
        let mesh = MeshResource.generateBox(size: [1.0, 1.0, 1.0])

        let xAxis = ModelEntity(mesh: mesh, materials: [UnlitMaterial(color: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1).withAlphaComponent(alpha))])
        let yAxis = ModelEntity(mesh: mesh, materials: [UnlitMaterial(color: #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1).withAlphaComponent(alpha))])
        let zAxis = ModelEntity(mesh: mesh, materials: [UnlitMaterial(color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1).withAlphaComponent(alpha))])
        axisEntity.children.append(contentsOf: [xAxis, yAxis, zAxis])

        let axisMinorScale = axisScale / 20
        let axisAxisOffset = axisScale / 2.0 + axisMinorScale / 2.0

        xAxis.position = [axisAxisOffset, 0, 0]
        xAxis.scale = [axisScale, axisMinorScale, axisMinorScale]
        yAxis.position = [0, axisAxisOffset, 0]
        yAxis.scale = [axisMinorScale, axisScale, axisMinorScale]
        zAxis.position = [0, 0, axisAxisOffset]
        zAxis.scale = [axisMinorScale, axisMinorScale, axisScale]
        return axisEntity
    }
}
