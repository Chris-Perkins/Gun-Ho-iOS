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
    private var currentSpawningIndex: Int
    
    // The timer we keep reference of for spawning.
    // Invalidate to pause
    private var paused = true
    
    public init(withPoints points: Int, andSpawningNode spawningNode: SCNNode) {
        self.spawningNode = spawningNode
        boatsToSpawn = [Boat.Type]()
        
        currentSpawningIndex = 0
        
        setSpawningList(withTotalPoints: points)
    }
    
    // Starts spawning boats. Can be paused
    public func startSpawning() {
        paused = false
        
        performSpawnCycle()
    }
    
    // Pauses the spawning
    public func pauseSpawning() {
        paused = true
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
        Timer.scheduledTimer(withTimeInterval: Double.random(min: 0, max: 2),
                             repeats: false)
        { (timer) in
            // This is here because the user may pause in the middle of an active cycle
            if !self.paused {
                self.spawnBoat(ofType: self.boatsToSpawn[self.currentSpawningIndex])
                self.currentSpawningIndex += 1
                
                // If we did not finish spawning, loop back around and perform another cycle
                if self.currentSpawningIndex < self.boatsToSpawn.count {
                    self.performSpawnCycle()
                }
            }
        }
    }
    
    // Spawns a boat and gives it the proper properties for navigation
    private func spawnBoat(ofType boatType: Boat.Type) {
        let boat = boatType.init()
        let randomNum = Double(arc4random())
        let randomUnitVector = SCNVector3(sin(randomNum), 0, cos(randomNum))
        
        // Spawns the boat on a random edge of the ocean
        boat.position = SCNVector3(randomUnitVector.x * 0.45,
                                   GameManager.shared.worldScene.position.y,
                                   randomUnitVector.z * 0.45)
        
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
