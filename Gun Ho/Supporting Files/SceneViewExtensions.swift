//
//  SceneViewExtensions.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 2/16/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import ARKit

extension ARSCNView {
    func getNode(withName name: String) -> SCNNode {
        guard let node = scene.rootNode.childNode(withName: name, recursively: true) else {
            fatalError("Could not find node with \(name).")
        }
        
        return node
    }
}
