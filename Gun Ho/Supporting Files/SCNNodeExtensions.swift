//
//  SCNNodeExtensions.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 2/14/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import SceneKit

extension SCNNode {
    var boatParent: Boat? {
        return parent?.parent as? Boat
    }
    
    /* Tells the node to remove itself after the time interval */
    public func setDecayTimer(ofTime time: CFTimeInterval, completionHandler: @escaping () -> () = { }) {
        Timer.scheduledTimer(withTimeInterval: time, repeats: false) { (timer) in
            self.removeFromParentNode()
            completionHandler()
        }
    }
}
