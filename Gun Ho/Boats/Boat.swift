//
//  SmallBoat.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 2/11/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import UIKit
import SceneKit

class Boat: GameObject {
    var maxHealth: Int
    var floatHeight: Float
    
    var health: Int {
        didSet {
            if health <= 0 {
                destroy()
            }
        }
    }
    
    // MARK: - Lifecycle
    init(maxHealth: Int, floatHeight: Float) {
        self.maxHealth   = maxHealth
        self.floatHeight = floatHeight
        
        health = maxHealth
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func decrementHealth() {
        health -= 1
    }
    
    override func performLogicForFrame() {
        if position.length() < 0.1 {
            print("AHHHHHHHHH")
        }
    }
    
    public func destroy() {
        removeFromParentNode()
    }
}
