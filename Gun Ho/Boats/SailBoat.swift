//
//  SailBoat.swift
//  Gun Ho
//
//  Created by Joelle Beverly on 2/15/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import Foundation
import SceneKit

final class SailBoat: Boat {
    
    override class var pointsCount: Int { return  7 }
    
    required init() {
        super.init(maxHealth: 7,
                   floatHeight: -0.175,
                   points: SailBoat.pointsCount,
                   speed: 5)
        
        guard let scene = SCNScene(named: "art.scnassets/boat-sail.scn"),
            let boatNode = scene.rootNode.childNode(withName: "boat",
                                                    recursively: true) else {
                                                        fatalError("Could not find sail boat")
        }
        addChildNode(boatNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
