//
//  SmallBoat.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 2/11/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import UIKit
import SceneKit

class Boat: GameObject {
    
    class var pointsCount: Int { return  0 }
    
    var maxHealth: Int
    
    // How high the boat floats (negative is sync)
    var floatHeight: Float
    
    // How many points the boat is worth
    let pointValue: Int
    
    // The speed of our boat in m/s
    let speed: Int
    
    var health: Int {
        didSet {
            if health <= 0 {
                destroy()
            }
        }
    }
    
    // MARK: - Lifecycle
    init(maxHealth: Int, floatHeight: Float, points: Int, speed: Int) {
        self.maxHealth   = maxHealth
        self.floatHeight = floatHeight
        self.pointValue  = points
        self.speed       = speed
        
        health = maxHealth
        
        super.init()
    }
    
    required override init() {
        fatalError("Cannot initialize a boat directly!")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: GameObject operations
    
    override func performLogicForFrame() {
        if position.length() < 0.1 {
            print("AHHHHHHHHH")
        }
    }
    
    // MARK: Boat operations
    
    public func decrementHealth() {
        health -= 1
    }
    
    // Should be called whenever the boat should be deleted
    public func destroy() {
        GameManager.shared.addPoints(pointValue)
        removeFromParentNode()
    }
    
    // Should be called when the boat is spawned
    // Causes boat to look at the island, pop up, then move towards the island
    public func performSpawnOperations() {
        // Keep a reference to the original scale for popping boat up
        let originalScale = scale
        
        // Set the boat to be invisble and then "pop" it out.
        scale = SCNVector3(0, 0, 0)
        // The boat looks at the island on spawn for realistic movement
        look(at: GameManager.shared.island.position)
        
        /*
         Springs the boat up. After the boat is at the original scale,
         it moves towards the island.
         */
        SCNTransaction.perform {
            SCNTransaction.animationDuration = 1
            self.scale = originalScale
        }
        
        SCNTransaction.perform {
            // Move linearly (default is ease in/out)
            SCNTransaction.animationTimingFunction =
                CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear)
            
            let distanceToCenter = GameManager.shared.ocean.scale.x / 2.0
            let timeToCenter = distanceToCenter / Float(self.speed)
            
            SCNTransaction.animationDuration = CFTimeInterval(timeToCenter)
            self.position = SCNVector3(0, self.position.y, 0)
        }
    }
}
