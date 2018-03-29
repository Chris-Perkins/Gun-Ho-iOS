//
//  Bird.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 3/29/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import SceneKit

public class Bird: GameObject {
    required public override init() {
        guard let scene = SCNScene(named: "art.scnassets/bird.scn"),
            let birdNode = scene.rootNode.childNode(withName: "bird",
                                                    recursively: true) else {
            fatalError("Could not find small boat")
        }
        
        super.init()
        
        addChildNode(birdNode)
        
        guard let birdPhysicsBody = birdNode.physicsBody else {
            fatalError("Could not get bird's physics body! Does it exist?")
        }
        birdPhysicsBody.categoryBitMask  = CollisionType.bird
        birdPhysicsBody.collisionBitMask = CollisionType.bird
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
