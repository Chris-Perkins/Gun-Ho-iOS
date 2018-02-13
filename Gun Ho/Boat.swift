//
//  SmallBoat.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 2/11/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import UIKit
import SceneKit

final class Boat: SCNNode {
    
    public enum type {
        case small
        case medium
        case viking
    }
    
    var boatNode: SCNNode?
    
    // MARK: - Lifecycle
    init(type: Boat.type) {
        super.init()
        
        switch (type) {
        case .small:
            guard let scene = SCNScene(named: "art.scnassets/boat-small.scn"),
                let boatNode = scene.rootNode.childNode(withName: "boat",
                                                        recursively: true) else {
                    fatalError("Could not find small boat")
            }
            addChildNode(boatNode)
        case .medium:
            guard let scene = SCNScene(named: "art.scnassets/boat-medium.scn"),
                let boatNode = scene.rootNode.childNode(withName: "boat",
                                                        recursively: true) else {
                    fatalError("Could not find medium boat")
            }
            addChildNode(boatNode)
        case .viking:
            guard let scene = SCNScene(named: "art.scnassets/boat-viking.scn"),
                let boatNode = scene.rootNode.childNode(withName: "boat",
                                                        recursively: true) else {
                    fatalError("Could not find viking boat")
            }
            addChildNode(boatNode)
        default:
            fatalError("Boat type not yet implemented")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
