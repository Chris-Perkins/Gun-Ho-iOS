//
//  SmallBoat.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 2/11/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import UIKit
import SceneKit

class Boat: SCNNode {
    var maxHealth: Int
    var floatHeight: Float
    
    // MARK: - Lifecycle
    init(maxHealth: Int, floatHeight: Float) {
        self.maxHealth   = maxHealth
        self.floatHeight = floatHeight
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
