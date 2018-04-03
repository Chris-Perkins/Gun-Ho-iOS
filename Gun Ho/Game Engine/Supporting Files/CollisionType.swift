//
//  CollisionMasksForGame.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 3/18/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

/*
 Use bit-wise discrete integers for different collision types.
 We use this since the collision mask ends up being a bit-wise 'or'
 of the different types of collisions.
 
 Example: Collision between island and boat is
            01 | 10 = 11
 */
public class CollisionType {
    public static let boat   = 1 << 0
    public static let island = 1 << 1
    public static let whale  = 1 << 2
    public static let bird   = 1 << 3
    public static let bomb   = 1 << 4
}
