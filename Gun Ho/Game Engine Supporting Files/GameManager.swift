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
    
    private init() {}
    
    // MARK: Game properties
    
    // The root node for use in spawning and finding the worldScene node
    public var rootNode: SCNNode?
    
    // Stores all game objects so we can check logic for each frame
    public var gameObjects = [GameObject]()
    
    // The maximum wave we can go to
    /*
     NOTE: Make sure the summation from 0 to maxWave
     of pointsPerWave is < 2^32
     */
    private let maxWave = 100
    
    // A reference to the object that is currently spawning boats
    private var boatSpawner: BoatSpawner?
    
    // The current wave we're on
    // Nullable since we may not be in an active game
    private var curWave: Int?
    
    // The total points we've earned in this session of the game
    // Nullable since we may not be in an active game
    private var totalPoints: Int?
    
    // The current number of boats we've destroyed
    // Nullable since we may not be in an active game
    /*
     Due to the setter observer, curWave should be set
     before curPoints is set
    */
    private var curPoints: Int? {
        didSet {
            /*
             If the game started or ended, don't bother checking
             if we moved to the next level.
            */
            guard let curPoints = curPoints,
                let curWave = curWave else {
                return
            }
            
            if curPoints >= pointsPerWave(curWave) {
                performWaveCompleteSequence()
            }
        }
    }
}

// MARK: Core Game Logic

extension GameManager {
    // Gets the lights in the scene
    public var lights: [SCNLight]? {
        guard let lightsNode = worldScene.childNode(withName: "lights", recursively: true) else {
                return nil
        }
        return lightsNode.childNodes.map({ (node) -> SCNLight in
            return node.light!
        })
    }
    
    // Gets the worldScene from the rootnode
    public var worldScene: SCNNode {
        guard let worldSceneNode = rootNode?.childNode(withName: "worldScene", recursively: false) else {
            fatalError("Could not get worldScene!")
        }
        return worldSceneNode
    }
    
    // Gets the island from the worldscene
    public var island: SCNNode {
        guard let islandNode = worldScene.childNode(withName: "island", recursively: false) else {
            fatalError("Could not find island in the worldScene")
        }
        return islandNode
    }
    
    // Gets the ocean from the worldscene
    public var ocean: SCNNode {
        guard let oceanNode = worldScene.childNode(withName: "ocean", recursively: false) else {
            fatalError("Could not find ocean in the worldScene")
        }
        return oceanNode
    }
    
    // Called on every frame to update the lighting to the provided lighting intensity
    public func updateLightingIntensity(toLightIntensity lightIntensity: CGFloat) {
        if let lights = lights {
            for light in lights {
                light.intensity = lightIntensity
            }
        }
    }
    
    // Should be called to start the game
    public func performGameStartSequence(atWave wave: Int = 1) {
        if wave <= 0 {
            fatalError("Waves are 1-indexed. Please use a wave value > 0")
        }
        
        totalPoints = 0
        curPoints   = 0
        curWave     = wave
        
        createAndStartCurrentWaveBoatSpawner()
    }
    
    // Should be called whenever the game should end
    public func performGameOverSequence() {
        totalPoints = nil
        curWave     = nil
        curPoints   = nil
        
        boatSpawner?.pauseSpawning()
        boatSpawner = nil
        
        for node in gameObjects {
            node.removeFromParentNode()
        }
        gameObjects.removeAll()
        
        print("GAME OVER U LOSE")
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (timer) in
            self.performGameStartSequence()
        }
    }
    
    // Should be called whenever the user defeats a wave
    public func performWaveCompleteSequence() {
        guard let wave = curWave else {
            fatalError("Wave cannot be complete; the game was never started!")
        }
        
        // We shouldn't create the next wave is the wave was completed
        if wave >= maxWave {
            performGameOverSequence()
        }
        
        curPoints = 0
        curWave   = wave + 1
        createAndStartCurrentWaveBoatSpawner()
    }
    
    // Adds the input points to the current and totalPoints variables
    public func addPoints(_ points: Int) {
        guard let curPoints = curPoints,
            let totalPoints = totalPoints else {
            fatalError("Cannot add points; the game was never started!")
        }
        
        self.curPoints   = curPoints + points
        self.totalPoints = totalPoints + points
    }
    
    // Returns the number of points necessary to pass a wave
    private func pointsPerWave(_ wave: Int) -> Int {
        let linearFactor      = 3 * wave
        let exponentialFactor = 3^^(wave / 10 - 3)
        
        return linearFactor + exponentialFactor
    }
    
    // Creates a boat spawner from the current wave's info.
    // Requires a node to spawn on
    private func createAndStartCurrentWaveBoatSpawner() {
        guard let curWave = curWave,
            let spawnNode = rootNode else {
                fatalError("Cannot create a spawner without the wave and spawnNode")
        }
        
        boatSpawner = BoatSpawner(withPoints: pointsPerWave(curWave),
                                  andSpawningNode: spawnNode)
        boatSpawner?.startSpawning()
    }
}
