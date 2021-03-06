//
//  MediumBoat.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 2/12/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import SceneKit

final class MediumBoat: Boat {
    
    // MARK: Properties
    
    override class var pointsCount: Int { return  3 }
    
    // MARK: Life Cycle
    
    required init() {
        guard let scene = SCNScene(named: "art.scnassets/boat-medium.scn"),
            let boatNode = scene.rootNode.childNode(withName: "boat",
                                                    recursively: false)
            else {
                fatalError("Could not find medium boat in provided scene")
        }
        
        super.init(maxHealth: 3,
                   floatHeight: -0.05,
                   points: MediumBoat.pointsCount,
                   speed: 3,
                   withNode: boatNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
