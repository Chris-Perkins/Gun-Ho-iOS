//
//  Bird.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 3/29/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import SceneKit

public class Bird: GameObject {
    
    // MARK: Initializations
    
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
    
    // MARK: Custom functions
    
    /* Starts the bird flying cycle */
    public func startFlying() {
        flyToRandomPoint(andRepeat: true)
    }
    
    /* Flies the bird to a random point within the ocean's bounds.
     May repeat this action by setting the */
    private func flyToRandomPoint(andRepeat repeatAnimation: Bool) {
        let destinationPoint = SCNVector3(Float.random(min: -GameManager.shared.ocean.scale.x / 2,
                                                       max: GameManager.shared.ocean.scale.x / 2),
                                          // Chosen arbitrarily; I just found 0.25 and 0.3 look nice.
                                          Float.random(min: 0.25,
                                                       max: 0.3),
                                          Float.random(min: -GameManager.shared.ocean.scale.z / 2,
                                                       max: GameManager.shared.ocean.scale.z / 2))
        
        // Get the position the bird is flying to relative to the world's terms
        look(at: GameManager.shared.gameNode.worldPosition + destinationPoint)
        
        // The bird should be strolling, not flying like its tail is on fire.
        let flySpeed = Double.random(min: 0.05,
                                     max: 0.15)
        
        // Flies the bird to the destination
        performMovementOperation {
            let flyTime = Double(destinationPoint.distance(vector: self.position)) / flySpeed
            
            SCNTransaction.animationDuration = flyTime
            self.position = destinationPoint
            
            SCNTransaction.completionBlock = {
                if repeatAnimation && !GameManager.shared.paused {
                    self.flyToRandomPoint(andRepeat: repeatAnimation)
                }
            }
        }
    }
}
