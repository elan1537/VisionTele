import SwiftUI
import RealityKit
import URRobots

class RobotEntity: Entity {
    private var robot: Entity = Entity()
    
    @MainActor required init() {
        super.init()
    }
    
    init(position: SIMD3<Float> = [0, 0, 0],
         scale: SIMD3<Float> = [1, 1, 1]
    ) async {
        super.init()
        
        guard let robot = await URRobots.entity(named: "UR5") else { return }
        
        self.robot = robot
        self.addChild(robot)
    
    }
}
