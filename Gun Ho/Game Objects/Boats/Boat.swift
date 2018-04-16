//
//  Boat.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 2/11/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import SceneKit

class Boat: GameObject {
    
    // MARK: Properties
    
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
    
    /* REASONING: Due to some asynchronous calls, we may call
     `destroy()` twice. This causes points to be added twice, which is no good!
     This flag simply makes sure we don't add points twice. */
    var didDie: Bool = false
    
    // MARK: Life Cycle
    
    init(maxHealth: Int, floatHeight: Float, points: Int, speed: Int, withNode node: SCNNode) {
        self.maxHealth   = maxHealth
        self.floatHeight = floatHeight
        self.pointValue  = points
        self.speed       = speed
        
        health = maxHealth
        
        super.init()
        
        addChildNode(node)
        
        guard let boatPhysicsBody = node.physicsBody else {
            fatalError("Could not get boat physics body! Does it exist?")
        }
        boatPhysicsBody.categoryBitMask    = CollisionType.boat | CollisionType.whale | CollisionType.bomb
        boatPhysicsBody.collisionBitMask   = CollisionType.boat
    }
    
    required override init() {
        fatalError("Cannot initialize a boat directly!")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: GameObject overrides
    
    // Should be called whenever the boat should be deleted
    override public func destroy() {
        // Check if the boat was previously marked as dead...
        if !didDie {
            // Pause the moment so the gameobject doesn't asynchronously collide
            pauseMovement()
            
            // Add the value for killing to boat to GameManager
            GameManager.shared.addPoints(pointValue)
            
            // Memory leak prevention...
            removeAllParticleSystems()
            
            // Mark this boat as "dead" so this function isn't called twice accidentally.
            didDie = true
            
            // Add a signifier to the user that the boat died
            attachBoatDestroyedParticleToWorld()
            
            super.destroy()
        }
    }
    
    // Should be called when the boat is spawned
    // Causes boat to look at the island, pop up, then move towards the island
    override public func performSpawnOperations() {
        // The boat looks at the island on spawn for realistic movement
        look(at: GameManager.shared.island.worldPosition)
        
        // Causes the boat to "pop" out of the ocean
        scale(fromScale: SCNVector3(0, 0, 0),
              toScale: scale)
        
        // Move the boat towards the ocean
        performMovementOperation {
            // Move linearly (default is ease in/out)
            SCNTransaction.animationTimingFunction =
                CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            
            // The 69 just says that the island has a radius of 60 (chosen arbitrarily).
            // Note: It doesn't a radius of 60
            let distanceToCenter = 60 * self.position.distance(vector: GameManager.shared.island.position)
            let timeToCenter = distanceToCenter / Float(self.speed)
            
            SCNTransaction.animationDuration = CFTimeInterval(timeToCenter)
            self.position = SCNVector3(0, self.position.y, 0)
        }
    }
    
    // MARK: Boat operations
    
    public func decrementHealth() {
        health -= 1
        attachWoodRemoveParticle()
    }
    
    // Does nothing besides shake the boat object. called on boat tap.
    public func shake() {
        // FURTHER TODO: What the heck is up with gimbal lock?
        // Can we mathematically make this rotate nicely?
        // Is this even worth doing?
        
        let shakeTime = 0.2
        let shakeMax  = (10 / 180) * 3.14159
        let shakeAmount = SCNVector3(Double.random * shakeMax * 1/2,
                                     Double.random * shakeMax * 1/2,
                                     Double.random * shakeMax)
        
        ActionQueue(withActions: [
            // Tip the boat
            Action(actionTime: shakeTime,
                            withActions: {
                                SCNTransaction.perform {
                                    SCNTransaction.animationDuration = shakeTime
                                    self.eulerAngles += shakeAmount
                                }
            }),
            // Tip the boat back to the other side
            // * 2 as we have 2 times the distance to cover
            Action(actionTime: shakeTime * 2,
                   withActions: {
                        SCNTransaction.perform {
                            SCNTransaction.animationDuration = shakeTime * 2
                            self.eulerAngles -= shakeAmount * 2
                        }
            }),
            // Bring back to neutral position
            Action(actionTime: shakeTime,
                   withActions: {
                        SCNTransaction.perform {
                            SCNTransaction.animationDuration = shakeTime
                            self.eulerAngles += shakeAmount
                        }
            })
        ]).start()
    }
    
    // MARK: Particle adding
    
    // Used to let the user know that the boat was destroyed
    private func attachBoatDestroyedParticleToWorld() {
        // Retrieves the particle system
        let boatExplosionParticle = SCNParticleSystem(named: "boat-explosion", inDirectory: nil)!
        
        // Adds the particle system to the scene
        GameManager.shared.scene?.addParticleSystem(boatExplosionParticle,
                                                    transform: presentation.worldTransform)
        
        // Retrieves the time the particle system displays for
        let totalParticleTime = boatExplosionParticle.particleLifeSpan +
            boatExplosionParticle.emissionDuration
        
        // removes the particle system after this time
        Timer.scheduledTimer(withTimeInterval: TimeInterval(totalParticleTime), repeats: false) {
            (timer) in
            GameManager.shared.scene?.removeParticleSystem(boatExplosionParticle)
        }
    }
    
    // Used intuitively to denote that the boat took damage
    private func attachWoodRemoveParticle() {
        let woodParticles = SCNParticleSystem(named: "boat-damage", inDirectory: nil)!
        addParticleSystem(woodParticles)
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
            self.removeParticleSystem(woodParticles)
        }
    }
}
