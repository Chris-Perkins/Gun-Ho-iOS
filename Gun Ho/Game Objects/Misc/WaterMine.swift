//
//  WaterMine.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 4/3/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import SceneKit

public class WaterMine: GameObject {
    
    // MARK: Properties
    
    public static let birdPricePerFive = 1
    
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
            fatalError("Could not get bomb physics body! Does it exist?")
        }
        DispatchQueue.main.async {
            bombPhysicsBody.categoryBitMask    = CollisionType.bomb
            bombPhysicsBody.collisionBitMask   = CollisionType.bomb
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Game Object overrides
    
    override public func destroy() {
        // Used to notify the user that the watermine was destroyed
        attachWatermineDestroyedParticleToWorld()
        
        super.destroy()
    }
    
    // MARK: Custom functions
    
    // Used to let the user know that the boat was destroyed
    private func attachWatermineDestroyedParticleToWorld() {
        // Retrieves the particle system
        let wmExplosionParticle = SCNParticleSystem(named: "watermine-explosion", inDirectory: nil)!
        
        // Adds the particle system to the scene
        GameManager.shared.scene?.addParticleSystem(wmExplosionParticle,
                                                    transform: presentation.worldTransform)
        
        // Retrieves the time the particle system displays for
        let totalParticleTime = wmExplosionParticle.particleLifeSpan +
            wmExplosionParticle.emissionDuration
        
        // removes the particle system after this time
        Timer.scheduledTimer(withTimeInterval: TimeInterval(totalParticleTime), repeats: false) {
            (timer) in
            GameManager.shared.scene?.removeParticleSystem(wmExplosionParticle)
        }
    }
}
