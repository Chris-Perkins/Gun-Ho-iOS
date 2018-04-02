//
//  BoatSpawner.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 2/27/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import Foundation
import SceneKit

public class BoatSpawner {
    // The node we spawn boats on
    private let spawningNode: SCNNode
    
    // The list of boats types we will spawn/have spawned
    private var boatsToSpawn: [Boat.Type]
    
    // The index in the spawningList we're spawning from
    private var currentSpawningIndex: Int {
        didSet {
            if currentSpawningIndex < 0 {
                currentSpawningIndex = 0
            }
        }
    }
    
    // The timer we keep reference of for spawning.
    // Invalidate to pause
    public var spawning = false {
        didSet {
            if spawning && !performingSpawnCycle {
                performSpawnCycle()
            }
        }
    }
    // Tells us if we're already performing a spawn cycle
    // Used so that we don't perform spawn cycles twice
    private var performingSpawnCycle = false
    
    public init(withPoints points: Int, andSpawningNode spawningNode: SCNNode) {
        self.spawningNode = spawningNode
        boatsToSpawn = [Boat.Type]()
        
        currentSpawningIndex = 0
        
        setSpawningList(withTotalPoints: points)
    }
    
    // Returns amount of boats that have been spawned
    public func getSpawnedBoatsCount() -> Int {
        return currentSpawningIndex
    }
    
    // Returns the amount of boats that were queued for spawning
    public func getTotalBoatsCount() -> Int {
        return boatsToSpawn.count
    }
    
    // Performs a cycle of spawning.
    // Recursively calls if there are remaining boats to spawn.
    private func performSpawnCycle() {
        // Base case: If we're out of index, then we're done.
        if currentSpawningIndex >= boatsToSpawn.count { return }
        
        performingSpawnCycle = true
        
        Timer.scheduledTimer(withTimeInterval: Double.random(min: 2, max: 4),
                             repeats: false)
        { (timer) in
            if self.spawning {
                self.spawnBoat(ofType: self.boatsToSpawn[self.currentSpawningIndex])
                self.currentSpawningIndex += 1
                
                // We finished this spawn cycle
                self.performingSpawnCycle = false
                
                // Recursively call the next cycle
                self.performSpawnCycle()
            } else {
                // Unable to spawn
                self.performingSpawnCycle = false
            }
        }
    }
    
    // Spawns a boat and gives it the proper properties for navigation
    private func spawnBoat(ofType boatType: Boat.Type) {
        let boat = boatType.init()
        let randomNum = Double(arc4random())
        let randomUnitVector = SCNVector3(sin(randomNum), 0, cos(randomNum))
        
        // Spawns the boat on a random edge of the ocean
        boat.position =
            SCNVector3(randomUnitVector.x * (GameManager.shared.worldScene.scale.x / 2) * 0.95,
                       GameManager.shared.worldScene.position.y,
                       randomUnitVector.z * (GameManager.shared.worldScene.scale.z / 2) * 0.95)
        
        // Finally, add it to the scene.
        spawningNode.addChildNode(boat)
        
        // We just created a boat; perform spawning operations
        boat.performSpawnOperations()
    }
    
    // Sets the list of boats to be spawned
    private func setSpawningList(withTotalPoints totalPoints: Int) {
        var remainingPoints = totalPoints
        
        while remainingPoints > 0 {
            let spawnableBoats = getSpawnableBoats(withPointsCount: remainingPoints)
            let randIndex = Int.random(min: 0, max: spawnableBoats.count - 1)
            let boatToAdd = spawnableBoats[randIndex]
            
            boatsToSpawn.append(boatToAdd)
            remainingPoints -= boatToAdd.pointsCount
        }
    }
    
    // Returns a list of all possible boats that we can spawn
    private func getSpawnableBoats(withPointsCount pointsCount: Int) -> [Boat.Type] {
        var possibleBoats = [Boat.Type]()
        
        if pointsCount >= SmallBoat.pointsCount {
            possibleBoats.append(SmallBoat.self)
        }
        if pointsCount >= MediumBoat.pointsCount {
            possibleBoats.append(MediumBoat.self)
        }
        if pointsCount >= VikingBoat.pointsCount {
            possibleBoats.append(VikingBoat.self)
        }
        
        return possibleBoats
    }
}
