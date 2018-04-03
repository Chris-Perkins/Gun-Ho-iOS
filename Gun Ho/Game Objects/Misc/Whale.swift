//
//  Whale.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 4/2/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import SceneKit

public class Whale: GameObject {
    
    // MARK: Life Cycle
    
    required public override init() {
        guard let scene = SCNScene(named: "art.scnassets/animal-whale.scn"),
              let whaleNode = scene.rootNode.childNode(withName: "whale",
                                                    recursively: false)
            else {
                fatalError("Could not find small boat in provided scene")
        }
        
        super.init()
        
        addChildNode(whaleNode)
        
        guard let whalePhysicsBody = whaleNode.physicsBody else {
            fatalError("Could not get boat physics body! Does it exist?")
        }
        DispatchQueue.main.async {
            whalePhysicsBody.categoryBitMask    = CollisionType.whale | CollisionType.boat
            whalePhysicsBody.collisionBitMask   = CollisionType.whale
            whalePhysicsBody.contactTestBitMask = CollisionType.whale
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
