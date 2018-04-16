//
//  Whale.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 4/2/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import SceneKit

public class Whale: GameObject {
    
    // MARK: Properties
    
    public static let longevity: CFTimeInterval = 15
    public static let birdPrice = 1
    
    // MARK: Life Cycle
    
    required public override init() {
        guard let scene = SCNScene(named: "art.scnassets/animal-whale.scn"),
              let whaleNode = scene.rootNode.childNode(withName: "whale",
                                                    recursively: false)
            else {
                fatalError("Could not find whale in provided scene")
        }
        
        super.init()
        
        addChildNode(whaleNode)
        
        guard let whalePhysicsBody = whaleNode.physicsBody else {
            fatalError("Could not get boat physics body! Does it exist?")
        }
        DispatchQueue.main.async {
            whalePhysicsBody.categoryBitMask    = CollisionType.whale
            whalePhysicsBody.collisionBitMask   = CollisionType.whale
        }
        
        // Remove the whale's tail animation (if it exists)
        if let animatedNode = whaleNode.childNodes.first?.childNodes.first,
            animatedNode.animationKeys.first != nil {
            
            animatedNode.removeAllAnimations()
        }
        
        // Destroy the whale after it's been alive for it's duration
        Timer.scheduledTimer(withTimeInterval: Whale.longevity, repeats: false) { (timer) in
            self.destroy()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: GameObject overrides
    
    // Causes boat to look at the island, pop up, then move towards the island
    override public func performSpawnOperations() {
        super.performSpawnOperations()
        
        // Causes the whale's model to look perpendicular to the island
        // This is because the whale model itself is rotated 90 degrees.
        look(at: GameManager.shared.island.worldPosition)
        
        // The amount of time it takes for the whale to shrink
        let scaleTime: CFTimeInterval = 0.5
        
        // Right before the whale is about to be destroyed, it begins to scale down
        Timer.scheduledTimer(withTimeInterval: Whale.longevity - scaleTime, repeats: false) { (timer) in
            DispatchQueue.main.async {
                // Causes the whale to "shrink" again.
                // NOTE: 0.01 is used instead of 0. 0 caused the application to crash.
                // Assuming this is a bug in Apple's code. Nothing I can do to help that.
                self.scale(fromScale: self.scale,
                           toScale: SCNVector3(0.01, 0.01, 0.01),
                           withAnimationTime: scaleTime)
            }
        }
    }
}
