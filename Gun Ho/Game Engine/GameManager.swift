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

// MARK: Main declaration (Singleton / Properties)

public class GameManager: NSObject {
    
    // MARK: Singleton logic
    
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
    
    override private init() {}
    
    // MARK: Game properties
    
    // The delegate we inform of game state changes
    internal var delegate: GameManagerDelegate?
    
    // Stores all game objects so we can check logic for each frame
    public var gameObjects = [GameObject]()
    
    // Whether or not the game has started
    private var gameLogicActive = false
    
    // Returns whether or not the game is active
    public var inActiveGame: Bool {
        return gameLogicActive
    }
    
    // Whether or not the game is paused
    private var paused = false {
        didSet {
            if paused {
                pauseGameMovement()
            } else {
                resumeGameMovement()
            }
            delegate?.gamePauseStateChanged?(toState: paused)
        }
    }
    
    // The maximum wave we can go to
    /* NOTE: Make sure maxWave's point value is < 2^32 */
    private let maxWave = 100
    
    /* A reference to the object that is currently spawning boats
        Nullable since we may not be in an active game */
    private var boatSpawner: BoatSpawner?
    
    /* The current wave we're on
        Nullable since we may not be in an active game */
    private var curWave: Int?
    
    /* The total points we've earned in this session of the game
        Nullable since we may not be in an active game */
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
    
    // The scene that we'll be displaying. Set up in GameViewController
    public var scene: SCNScene? {
        didSet {
            // Done so we immediately set the island up for collisions
            guard let islandEnvironment = island.childNode(withName: "environment",
                                                           recursively: false),
                let islandPhysicsBody = islandEnvironment.physicsBody else {
                    fatalError("Could not get island/it's physics body!")
            }
            islandPhysicsBody.categoryBitMask    = CollisionType.island
            islandPhysicsBody.collisionBitMask   = CollisionType.island | CollisionType.boat
        }
    }
    
    // The root node for use in spawning and finding the worldScene node
    lazy public var rootNode: SCNNode = {
        guard let scene = scene else {
            fatalError("Scene is nil! Could not get the rootnode.")
        }
        
        return scene.rootNode
    }()
    
    /* The object which holds all objects relevant to the game
        Throws if the gameNode cannot be retrieved */
    lazy public var gameNode: SCNNode = {
        guard let gameNode = rootNode.childNode(withName: "gameNode", recursively: false) else {
            fatalError("Could not get gameNode!")
        }
        return gameNode
    }()
    
    /* Gets the lights in the scene
        Throws if the lights cannot be retrieved */
    lazy public var lightParentNode: SCNNode = {
        guard let lightParentNode = gameNode.childNode(withName: "lights", recursively: true) else {
            fatalError("Could not get Light Node!")
        }
        return lightParentNode
    }()
    
    /* Gets the center light of the scene */
    lazy public var centerLightNode: SCNNode = {
        guard let centerLightNode = self.lightParentNode.childNode(withName: "center-light",
                                                                   recursively: true) else {
            fatalError("Could not get center light!")
        }
        
        return centerLightNode
    }()
    
    /* Gets the spotlight node */
    lazy public var spotlightNode: SCNNode = {
        guard let spotlightNode = self.lightParentNode.childNode(withName: "spotlight",
                                                                 recursively: true) else {
            fatalError("Could not get center light!")
        }
        
        return spotlightNode
    }()
    
    /* Gets the worldScene from the rootnode
        Throws if the worldScene cannot be retrieved */
    lazy public var worldScene: SCNNode = {
        guard let worldSceneNode = gameNode.childNode(withName: "worldScene", recursively: false) else {
            fatalError("Could not get worldScene!")
        }
        return worldSceneNode
    }()
    
    /* Gets the island from the worldscene
        Throws if the island cannot be retrieved*/
    lazy public var island: SCNNode = {
        guard let islandNode = worldScene.childNode(withName: "island", recursively: false) else {
            fatalError("Could not find island in the worldScene")
        }
        return islandNode
    }()
    
    /* Gets the ocean from the worldscene
        Throws if the ocean cannot be retrieved */
    lazy public var ocean: SCNNode = {
        guard let oceanNode = worldScene.childNode(withName: "ocean", recursively: false) else {
            fatalError("Could not find ocean in the worldScene")
        }
        return oceanNode
    }()
}

// MARK: Core Game Logic

extension GameManager {
    
    // Called on every frame to update the lighting to the provided lighting intensity
    public func updateLightingIntensity(toLightIntensity lightIntensity: CGFloat) {
        for lightNode in lightParentNode.childNodes {
            lightNode.light?.intensity = lightIntensity
        }
    }
    
    /* Starts the game if it hasn't been started
        Throws if the game was already started */
    public func startGame() {
        if !gameLogicActive {
            // The game should not be paused at the start
            paused = false
            
            // While seemingly arbitrary, this timer prevents an asynchronous crash
            // caused by objects still deleting in a previous game's thread.
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (timer) in
                self.performGameStartSequence(atWave: 1)
            }
            gameLogicActive = true
        } else {
            fatalError("Game was declared to start twice, but this cannot happen.")
        }
    }
    
    /* Note: logic for pausing is handled by the didSet handler */
    public func setPauseState(to state: Bool) {
        /* NOTE: reasoning for this line seems dumb.
            If we unpause all objects if they're already unpaused,
            then they will attempt to perform their movement operations
            TWICE. This causes issues with birds since they'll look
            like spazzy gremlins. */
        if paused != state {
            paused = state
        }
    }
    
    // Toggles the pause state
    public func togglePauseState() {
        paused = !paused
    }
    
    // Returns the pause state
    public func getPauseState() -> Bool {
        return paused
    }
    
    /* Pauses the game movement; all objects stop moving.
        NOTE: This does not stop active timers or non-movement animations */
    private func pauseGameMovement() {
        for object in gameObjects {
            object.pauseMovement()
        }
        
        boatSpawner?.spawning = false
    }
    
    /* Resumes the game; all objects resume their original movement */
    private func resumeGameMovement() {
        for object in gameObjects {
            object.resumeMovement()
        }
        
        boatSpawner?.spawning = true
    }
    
    /* Should be called to start the game
        Throws if wave is < 0 */
    private func performGameStartSequence(atWave wave: Int = 1) {
        if wave <= 0 {
            fatalError("Waves are 1-indexed. Please use a wave value > 0")
        }
        
        totalPoints = 0
        curPoints   = 0
        curWave     = wave
        
        paused = false
        startCurrentWave()
        delegate?.gameDidStart?()
    }
    
    // Called by interfaces to force a game quit
    public func forceQuitSession() {
        if gameLogicActive {
            performGameOverSequence()
        }
    }
    
    // Should be called whenever the game should end
    private func performGameOverSequence() {
        appendNewScore(totalPoints ?? 0)
        
        gameLogicActive = false
        totalPoints = nil
        curWave     = nil
        curPoints   = nil
        
        boatSpawner?.spawning = false
        boatSpawner = nil
        
        for object in gameObjects {
            object.destroy()
        }
        
        delegate?.gameDidEnd?()
    }
    
    // Starts the current wave
    private func startCurrentWave() {
        createAndStartCurrentWaveBoatSpawner()
    }
    
    /* Should be called whenever the user defeats a wave */
    private func performWaveCompleteSequence() {
        guard let wave = curWave else {
            /* Not an error; we may have asynchronously ended the wave
                after the game was quit. */
            return
        }
        
        // Inform the delegate that we completed the wave
        delegate?.waveDidComplete?(waveNumber: wave)
        
        // We shouldn't create the next wave is the wave was completed
        if wave >= maxWave {
            performGameOverSequence()
            return
        }
        
        // Spawn a bird just for minor aesthetics
        spawnBird()
        
        // Reset the points since we use this to check against current wave requirements
        curPoints = 0
        curWave   = wave + 1
        
        // Give the user some time before the next wave
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (timer) in
            self.startCurrentWave()
        }
    }
    
    /* Adds the input points to the current and totalPoints variables */
    public func addPoints(_ points: Int) {
        guard let curPoints = curPoints,
            let totalPoints = totalPoints
            else {
                // Chances are that we got here from the mainqueue after a game over sequence was called.
                // This isn't necessarily an error.
                return
        }
        
        self.curPoints   = curPoints + points
        self.totalPoints = totalPoints + points
    }
    
    // Returns the number of points necessary to pass a wave
    private func pointsPerWave(_ wave: Int) -> Int {
        let constantFactor    = 10
        let linearFactor      = 3 * wave
        let exponentialFactor = 3^^(wave / 10 - 3)
        
        return exponentialFactor + linearFactor + constantFactor
    }
    
    /* Creates a boat spawner from the current wave's info.
        Requires a node to spawn on */
    private func createAndStartCurrentWaveBoatSpawner() {
        guard let curWave = curWave else {
            print("Possible error: could not get curWave in boatSpawner start?")
            return
        }
        
        boatSpawner = BoatSpawner(withPoints: pointsPerWave(curWave),
                                  andWave: curWave,
                                  onSpawningNode: gameNode)
        boatSpawner?.spawning = true
    }
    
    // Creates a bird that flies around
    // Should be called when wave completes
    private func spawnBird() {
        let bird = Bird()
        worldScene.addChildNode(bird)
        bird.startFlying()
    }
    
    // Spawns a whale that grows, stays a bit, then shrinks
    public func spawnWhale(atWorldScenePosition spawnPosition: SCNVector3 = SCNVector3(0, 0, 0)) {
        let whale = Whale()
        whale.position = spawnPosition
        worldScene.addChildNode(whale)
        
        // Causes the whale to scale up and look perpendicular to the island
        whale.performSpawnOperations()
    }
    
    public func spawnWaterMine(atWorldScenePosition spawnPosition: SCNVector3 = SCNVector3(0, 0, 0)) {
        let waterMine = WaterMine()
        waterMine.position = spawnPosition
        worldScene.addChildNode(waterMine)
        
        // Causes the watermine to scale up
        waterMine.performSpawnOperations()
    }
}

// MARK: Physics delegate

extension GameManager: SCNPhysicsContactDelegate {
    public func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let collisionMask = contact.nodeA.physicsBody!.collisionBitMask | contact.nodeB.physicsBody!.collisionBitMask
        
        switch collisionMask {
        case CollisionType.boat | CollisionType.island:
            // If the game is currently active...
            // NOTE: Done due to asynchronous calls messing this up.
            if gameLogicActive {
                // Then set the game to currently ended.
                gameLogicActive = false
                
                DispatchQueue.main.async {
                    // Get the boat of contact
                    let boat = (contact.nodeA.parent as? Boat) ?? (contact.nodeB.parent as? Boat) ?? Boat()
                    
                    // Stop all node movement
                    self.pauseGameMovement()
                    
                    // Turn off the center light
                    self.centerLightNode.isHidden = true
                    
                    // Turn on the center light and reposition it
                    self.spotlightNode.isHidden = false
                    self.spotlightNode.worldPosition = boat.worldPosition + SCNVector3(0, 0.1, 0)
                    
                    Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (timer) in
                        // Turn the lights back on
                        self.centerLightNode.isHidden = false
                        
                        // Turn on the center light and reposition it
                        self.spotlightNode.isHidden = true
                        
                        OperationQueue.main.addOperation {
                            // Finally, end the game
                            self.performGameOverSequence()
                        }
                    }
                }
            }
        case CollisionType.boat | CollisionType.boat:
            OperationQueue.main.addOperation {
                /* The 'parent' is here since the physicsbody of the boat
                    is attached to the immediate child of the boat object */
                (contact.nodeA.parent as? Boat)?.destroy()
                (contact.nodeB.parent as? Boat)?.destroy()
            }
        case CollisionType.boat | CollisionType.whale:
            OperationQueue.main.addOperation {
                (contact.nodeA.parent as? Boat)?.destroy()
                (contact.nodeB.parent as? Boat)?.destroy()
            }
        case CollisionType.boat | CollisionType.bomb:
            OperationQueue.main.addOperation {
                (contact.nodeA.parent as? GameObject)?.destroy()
                (contact.nodeB.parent as? GameObject)?.destroy()
            }
        default:
            // Unhandled collision, but not necessarily an error.
            break
        }
    }
}
