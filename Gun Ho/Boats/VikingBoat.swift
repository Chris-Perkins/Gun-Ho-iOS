//
//  VikingBoat.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 2/12/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import Foundation
import SceneKit

final class VikingBoat: Boat {
    init() {
        super.init(maxHealth: 10, floatHeight: -0.175, points: 10)
        
        guard let scene = SCNScene(named: "art.scnassets/boat-viking.scn"),
            let boatNode = scene.rootNode.childNode(withName: "boat",
                                                    recursively: true) else {
                                                        fatalError("Could not find viking boat")
        }
        addChildNode(boatNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
