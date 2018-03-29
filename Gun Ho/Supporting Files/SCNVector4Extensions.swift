
//
//  SCNVector4Extensions
//  SKLinearAlgebra
//
//  Created by Cameron Little on 2/24/15.
//  Copyright (c) 2015 Cameron Little. All rights reserved.
//
// Modified by Chris Perkins on 3/18/18

import SceneKit

// Equality and equivalence
public func ==(lhs: SCNVector4, rhs: SCNVector4) -> Bool {
    return SCNVector4EqualToVector4(lhs, rhs)
}

// Dot product
public func *(left: SCNVector4, right: SCNVector4) -> Float {
    return (left.x * right.x) + (left.y * right.y) + (left.z * right.z)
}


// Scalar multiplication
public func *(left: SCNVector4, right: Float) -> SCNVector4 {
    let x = left.x * right
    let y = left.y * right
    let z = left.z * right
    
    return SCNVector4(x: x, y: y, z: z, w: left.w)
}

public func *(left: Float, right: SCNVector4) -> SCNVector4 {
    let x = right.x * left
    let y = right.y * left
    let z = right.z * left
    
    return SCNVector4(x: x, y: y, z: z, w: right.w)
}

public func *(left: SCNVector4, right: Int) -> SCNVector4 {
    return left * Float(right)
}

public func *(left: Int, right: SCNVector4) -> SCNVector4 {
    return Float(left) * right
}

public func *=(left: inout SCNVector4, right: Float) {
    left = left * right
}

public func *=(left: inout SCNVector4, right: Int) {
    left = left * right
}

// Scalar Division
public func /(left: SCNVector4, right: Float) -> SCNVector4 {
    let x = left.x / right
    let y = left.y / right
    let z = left.z / right
    
    return SCNVector4(x: x, y: y, z: z, w: left.w)
}

public func /(left: SCNVector4, right: Int) -> SCNVector4 {
    return left / Float(right)
}

public func /=(left: inout SCNVector4, right: Float) {
    left = left / right
}

public func /=(left: inout SCNVector4, right: Int) {
    left = left / right
}

// Vector subtraction
public func -(left: SCNVector4, right: SCNVector4) -> SCNVector4 {
    let x = left.x - right.x
    let y = left.y - right.y
    let z = left.z - right.z
    
    let w = left.w * right.w
    
    return SCNVector4(x: x, y: y, z: z, w: w)
}

public func -=(left: inout SCNVector4, right: SCNVector4) {
    left = left - right
}

// Vector addition
public func +(left: SCNVector4, right: SCNVector4) -> SCNVector4 {
    let x = left.x + right.x
    let y = left.y + right.y
    let z = left.z + right.z
    
    let w = left.w * right.w
    
    return SCNVector4(x: x, y: y, z: z, w: w)
}

public func +=( left: inout SCNVector4, right: SCNVector4) {
    left = left + right
}
