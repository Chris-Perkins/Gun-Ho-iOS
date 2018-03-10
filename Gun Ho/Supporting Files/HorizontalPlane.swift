//
//  MathExpressionExtensions.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 2/25/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import SceneKit
import ARKit

// Used in helping the user place their AR anchor

final class HorizontalPlane: SCNNode {
    
    let planeGeometry: SCNPlane
    let material = SCNMaterial()
    let anchor: ARPlaneAnchor
    
    init(anchor: ARPlaneAnchor) {
        planeGeometry = SCNPlane(width: CGFloat(anchor.extent.x),
                                 height: CGFloat(anchor.extent.z))
        
        let hue        = Double(arc4random() % 255)
        let saturation = Double(arc4random() % 255)
        let brightness = Double(arc4random() % 255)
        
        material.diffuse.contents = UIColor(hue: CGFloat(hue / 255.0),
                                            saturation: CGFloat(saturation / 255.0),
                                            brightness: CGFloat(brightness / 255.0),
                                            alpha: 1.0)
        self.anchor = anchor
        
        super.init()
        
        material.isDoubleSided = true
        planeGeometry.firstMaterial = material
        
        geometry = planeGeometry
        position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        transform = SCNMatrix4MakeRotation(-Float.pi / 2, // Flattens the object
                                           1.0,
                                           0.0,
                                           0.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    func update(for anchor: ARPlaneAnchor) {
        planeGeometry.height = CGFloat(anchor.extent.z)
        planeGeometry.width = CGFloat(anchor.extent.x)
        geometry = planeGeometry
        position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
    }
    
}
