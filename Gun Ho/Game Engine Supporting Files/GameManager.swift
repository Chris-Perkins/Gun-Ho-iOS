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
    
    public func updateLightingIntensity(toLightIntensity lightIntensity: CGFloat) {
        if let lights = lights {
            for light in lights {
                light.intensity = lightIntensity
            }
        }
    }
    
    // Should be called to start the game
    public func performGameStartSequence(atWave wave: Int = 0) {
        curWave = wave
        
        spawn(waveNumber: curWave!)
    }
    
    // Should be called whenever the game should end
    public func performGameOverSequence() {
        curWave = nil
    }
    
    // Should be called whenever the user defeats a wave
    public func performWaveCompleteSequence() {
        guard let wave = curWave else {
            fatalError("Wave cannot be complete; the game was never started!")
        }
        curWave = wave + 1
    }
}

// MARK: Spawning logic

extension GameManager {
    func spawn(waveNumber: Int) {
        
    }
}
