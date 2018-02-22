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
    override public init() {
        super.init()
        
        name = UUID().uuidString
        GameManager.shared.gameObjects.append(self)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Init not set up for this!")
    }
    
    public func performLogicForFrame() {
        
    }
}
