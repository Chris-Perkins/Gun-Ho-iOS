//
//  MediumBoat.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 2/12/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import SceneKit

final class MediumBoat: Boat {
    
    override class var pointsCount: Int { return  3 }
    
    required init() {
        guard let scene = SCNScene(named: "art.scnassets/boat-medium.scn"),
            let boatNode = scene.rootNode.childNode(withName: "boat",
                                                    recursively: true) else {
                                                        fatalError("Could not find medium boat")
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
