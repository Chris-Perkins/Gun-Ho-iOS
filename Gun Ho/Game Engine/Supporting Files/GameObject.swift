//
//  GameObject.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 2/14/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

/*
 REASON FOR CREATION:
 At time of writing, retrieving a node from a scene does not allow casting.
 For example: create a node of boat class, add to the scene, and retrieve it.
 This node will not allow casting anymore! Therefore, no boat operations can be
 performed.
 
 By creating the GameObject, we can save the class in a GameObject dictionary.
 Now, we can retrieve GameObjects and cast as normal!
 */

import SceneKit

public class GameObject: SCNNode {
    
    // MARK: Properties
    
    /* Marks the current action the boat is taking */
    private var currentMovementAction: (() -> ())?
    
    // MARK: Initializations
    
    override public init() {
        super.init()
        
        name = UUID().uuidString
        GameManager.shared.gameObjects.append(self)
        attachSpawnParticles()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Init not set up for this!")
    }
    
    // MARK: Custom functions
    
    /* NOTE: This isn't built to scale to handle multiple movement operations at one time.
     It only handles one movement operation at any given time. */
    public func performMovementOperation(movementOperation: @escaping () -> ()) {
        let transaction = {
            SCNTransaction.perform {
                movementOperation()
            }
        }
        
        self.currentMovementAction = transaction
        transaction()
    }
    
    /* Pauses movement of the object */
    public func pauseMovement() {
        /* NOTE: To understand why this works for pausing,
            You would need to understand specifically how SCNTransactions
            are performed. SCNTransactions set the position of the object
            to the end point of the movement, but simply moves the presented
            view along the path (the position, however, remains static) */
        position = presentation.position
    }
    
    /* Resumes movement after a pause */
    public func resumeMovement() {
        currentMovementAction?()
    }
    
    // Called when the object should be considered "dead"
    public func destroy() {
        removeFromParentNode()
        
        if let objectIndex = GameManager.shared.gameObjects.index(of: self) {
            GameManager.shared.gameObjects.remove(at: objectIndex)
        }
    }
    
    // Called when the object spawns
    public func performSpawnOperations() {
        scale(fromScale: SCNVector3(0, 0, 0),
              toScale: scale)
    }
    
    // Used to identify newly spawned nodes
    public func attachSpawnParticles() {
        let spawnParticles = SCNParticleSystem(named: "spawn", inDirectory: nil)!
        addParticleSystem(spawnParticles)
        
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (timer) in
            self.removeParticleSystem(spawnParticles)
        }
    }
}
