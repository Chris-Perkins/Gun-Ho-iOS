//
//  SmallBoat.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 2/12/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import Foundation
import SceneKit

final class SmallBoat: Boat {
    
    public static let pointsCount = 1
    
    required init() {
        super.init(maxHealth: 1, floatHeight: -0.05, points: SmallBoat.pointsCount)
        
        guard let scene = SCNScene(named: "art.scnassets/boat-small.scn"),
            let boatNode = scene.rootNode.childNode(withName: "boat",
                                                    recursively: true) else {
                                                        fatalError("Could not find small boat")
        }
        addChildNode(boatNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

