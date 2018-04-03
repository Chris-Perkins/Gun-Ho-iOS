//
//  WaterMine.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 4/3/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import SceneKit

public class WaterMine: SCNNode {
    // MARK: Life Cycle
    
    required public override init() {
        guard let scene = SCNScene(named: "art.scnassets/watermine.scn"),
            let bombNode = scene.rootNode.childNode(withName: "watermine",
                                                     recursively: false)
            else {
                fatalError("Could not find watermine in provided scene")
        }
        
        super.init()
        
        addChildNode(bombNode)
        
        guard let bombPhysicsBody = bombNode.physicsBody else {
            fatalError("Could not get boat physics body! Does it exist?")
        }
        DispatchQueue.main.async {
            bombPhysicsBody.categoryBitMask    = CollisionType.bomb
            bombPhysicsBody.collisionBitMask   = CollisionType.bomb
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
