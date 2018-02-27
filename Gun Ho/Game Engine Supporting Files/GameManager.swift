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
    
    // Gets the y-position of the ocean's top
    public var rootNode: SCNNode?
    
    // Stores all game objects so we can check logic for each frame
    public var gameObjects = [GameObject]()
    
    // The maximum wave we can go to
    /*
     NOTE: Make sure the summation from 0 to maxWave
     of pointsPerWave is < 2^32
     */
    private let maxWave = 100
    
    private var requiredPointsForWaveComplete: Int?
    
    // The current wave we're on
    // Nullable since we may not be in an active game
    private var curWave: Int?
    
    // The current number of boats we've destroyed
    // Nullable since we may not be in an active game
    /*
     Due to the setter observer, curWave should be set
     before curPoints is set
    */
    private var curPoints: Int? {
        didSet {
            guard let curPoints = curPoints,
                let reqPoints = requiredPointsForWaveComplete else {
                return
            }
            
            if curPoints >= reqPoints {
                performWaveCompleteSequence()
            }
        }
    }
}

// MARK: Core Game Logic

extension GameManager {
    // Gets the lights in the scene
    private var lights: [SCNLight]? {
        guard let lightsNode = worldScene.childNode(withName: "lights", recursively: true) else {
                return nil
        }
        return lightsNode.childNodes.map({ (node) -> SCNLight in
            return node.light!
        })
    }
    
    private var worldScene: SCNNode {
        guard let worldSceneNode = rootNode?.childNode(withName: "worldScene", recursively: false) else {
            fatalError("Could not get worldScene!")
        }
        return worldSceneNode
    }
    
    // Gets the island from the worldscene
    private var island: SCNNode {
        guard let islandNode = worldScene.childNode(withName: "island", recursively: false) else {
            fatalError("Could not find island in the worldScene")
        }
        return islandNode
    }
    
    // Gets the ocean from the worldscene
    private var ocean: SCNNode {
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
        
        curWave   = wave
        curPoints = 0
        
        spawn(waveNumber: curWave!)
    }
    
    // Should be called whenever the game should end
    public func performGameOverSequence() {
        requiredPointsForWaveComplete = nil
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
        
        // We shouldn't create the next wave is the wave was completed
        if wave >= maxWave {
            performGameOverSequence()
        }
        
        curWave = wave + 1
        spawn(waveNumber: curWave!)
    }
    
    public func addPoints(_ points: Int) {
        guard let curPoints = curPoints else {
            fatalError("Cannot add points; the game was never started!")
        }
        
        self.curPoints = curPoints + points
    }
}

// MARK: Spawning logic

extension GameManager {
    
    // Returns the number of points necessary to pass a wave
    func pointsPerWave(_ wave: Int) -> Int {
        let linearFactor      = 3 * wave
        let exponentialFactor = 3^^(wave / 10 - 3)
        return linearFactor + exponentialFactor
    }
    
    // Starts spawning for a given wave number
    func spawn(waveNumber: Int) {
        let waveRequiredPoints = pointsPerWave(waveNumber)
        
        if let reqPoints = requiredPointsForWaveComplete {
            requiredPointsForWaveComplete = reqPoints + waveRequiredPoints
        } else {
            requiredPointsForWaveComplete = waveRequiredPoints
        }
        
        spawnBoats(withRemainingPoints: waveRequiredPoints)
    }
    
    // Spawns boats and recursively spawns more boats again
    func spawnBoats(withRemainingPoints remainingPoints: Int) {
        // Recursive definition ended; we can no longer spawn boats
        if remainingPoints <= 0 {
            return
        }
        
        let spawnableBoats = getSpawnableBoats(withPointsCount: remainingPoints)
        let randIndex = Int.random(min: 0, max: spawnableBoats.count - 1)
        let boat = spawnableBoats[randIndex].init()
        
        let randomNum = Double(arc4random())
        let randomUnitVector = SCNVector3(sin(randomNum), 0, cos(randomNum))
        
        boat.position = SCNVector3(randomUnitVector.x * 0.45,
                                   self.worldScene.position.y,
                                   randomUnitVector.z * 0.45)
        boat.look(at: island.position)
        rootNode?.addChildNode(boat)
        
        SCNTransaction.perform {
            SCNTransaction.animationDuration = 5
            boat.position = SCNVector3(0, boat.position.y, 0)
        }
        
        Timer.scheduledTimer(withTimeInterval: Double.random(min: 0, max: 2), repeats: false) { (timer) in
            self.spawnBoats(withRemainingPoints: remainingPoints - boat.pointValue)
        }
    }
    
    // Returns a list of all possible boats that we can spawn
    func getSpawnableBoats(withPointsCount pointsCount: Int) -> [Boat.Type] {
        var possibleBoats = [Boat.Type]()
        
        // TODO: Make this nicer if possible.
        if pointsCount >= SmallBoat.pointsCount {
            possibleBoats.append(SmallBoat.self)
        }
        if pointsCount >= MediumBoat.pointsCount {
            possibleBoats.append(MediumBoat.self)
        }
        if pointsCount >= VikingBoat.pointsCount {
            possibleBoats.append(VikingBoat.self)
        }
        if pointsCount >= SailBoat.pointsCount {
            //possibleBoats.append(SailBoat.self)
        }
        
        return possibleBoats
    }
}
