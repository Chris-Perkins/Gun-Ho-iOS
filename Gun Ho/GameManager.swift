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
    
    private var gameObjectDictionary = Dictionary<String, GameObject>()
    
    public func addGameObject(_ object: GameObject) {
        guard let name = object.name else {
            fatalError("GameObject must have a name!")
        }
        
        gameObjectDictionary[name] = object
    }
    
    public func getGameObject(withName name: String) -> GameObject? {
        return gameObjectDictionary[name]
    }
    
    public func getAllGameObjects() -> [GameObject] {
        return Array(gameObjectDictionary.values)
    }
    
    private init() {
    }
}
