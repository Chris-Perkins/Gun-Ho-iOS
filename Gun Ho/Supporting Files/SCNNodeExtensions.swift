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
    
    /* Used to help us make objects grow or shrink with some transition time */
    public func scale(fromScale: SCNVector3,
                      toScale: SCNVector3,
                      withAnimationTime animationTime: CFTimeInterval = 0.5) {
        
        // Set the scale to whatever scale we want to start from
        scale = fromScale
        
        // Causes the object to scale appropriately
        SCNTransaction.perform {
            SCNTransaction.animationDuration = animationTime
            scale = toScale
        }
    }
}
