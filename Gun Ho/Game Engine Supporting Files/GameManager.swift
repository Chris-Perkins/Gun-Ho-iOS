//
//  GameManager.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 2/14/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

/*
 REASON FOR CREATION:
 At time of writing, there is no easy way to update logic every frame
 The GameManager takes care of this.
 */

import SceneKit
import ARKit

// MARK: Singleton logic

public class GameManager {
    
    private static var activeInstance: GameManager?
    
    // Returns or creates and returns the shared instance
    public static var shared: GameManager {
        if let instance = activeInstance {
            return instance
        } else {
            activeInstance = GameManager()
            return activeInstance!
        }
    }
    
    private init() {
    }
    
    // MARK: Game logic
    
    // Gets the y-position of the ocean's top
    public var worldScene: SCNNode?
    
    // Stores all game objects so we can check logic for each frame
    public var gameObjects = [GameObject]()
    
    // The current wave we're on
    // Nullable since we may not be in an active game
    private var curWave: Int?
    
    // The current number of boats we've destroyed
    // Nullable since we may not be in an active game
    private var curPoints: Int?
}

// MARK: Core Game Logic

extension GameManager {
    // Gets the lights in the scene
    private var lights: [SCNLight]? {
        guard let worldScene = worldScene,
            let lightsNode = worldScene.childNode(withName: "lights", recursively: true) else {
                return nil
        }
        return lightsNode.childNodes.map({ (node) -> SCNLight in
            return node.light!
        })
    }
    
    private var island: SCNNode {
        guard let islandNode = worldScene?.childNode(withName: "island", recursively: false) else {
            fatalError("Could not find island in the worldScene")
        }
        
        return islandNode
    }
    
    public func updateLightingIntensity(toLightIntensity lightIntensity: CGFloat) {
        if let lights = lights {
            for light in lights {
                light.intensity = lightIntensity
            }
        }
    }
    
    // Should be called to start the game
    public func performGameStartSequence(atWave wave: Int = 0) {
        curWave   = wave
        curPoints = 0
        
        spawn(waveNumber: curWave!)
    }
    
    // Should be called whenever the game should end
    public func performGameOverSequence() {
        curWave   = nil
        curPoints = nil
        
        for node in gameObjects {
            node.removeFromParentNode()
        }
        gameObjects.removeAll()
    }
    
    // Should be called whenever the user defeats a wave
    public func performWaveCompleteSequence() {
        guard let wave = curWave else {
            fatalError("Wave cannot be complete; the game was never started!")
        }
        curWave = wave + 1
        
        spawn(waveNumber: curWave!)
    }
    
    public func addPoints(_ points: Int) {
        guard var curPoints = curPoints else {
            fatalError("Cannot add points; the game was never started!")
        }
        
        curPoints += points
    }
}

// MARK: Spawning logic

extension GameManager {
    func spawn(waveNumber: Int) {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (timer) in
            let boat = MediumBoat()
            
            let randomNum = Double(arc4random())
            let randomUnitVector = SCNVector3(sin(randomNum), 0, cos(randomNum))
            
            boat.position = SCNVector3(randomUnitVector.x * 0.45, -1, randomUnitVector.z * 0.45)
            self.worldScene!.addChildNode(boat)
            boat.look(at: self.island.position)
            
            SCNTransaction.perform {
                SCNTransaction.animationDuration = 5
                boat.position = SCNVector3(0, -1, 0)
            }
        }
    }
}
