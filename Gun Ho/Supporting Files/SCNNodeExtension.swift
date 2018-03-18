//
//  SCNNodeExtension.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 2/14/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import SceneKit

extension SCNNode {
    var boatParent: Boat? {
        return parent as? Boat
    }
}
