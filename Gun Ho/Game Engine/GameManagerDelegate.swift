//
//  GameManagerDelegate.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 3/23/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import Foundation

@objc protocol GameManagerDelegate {
    @objc optional func gameDidStart()
    @objc optional func gamePauseStateChanged(toState state: Bool)
    @objc optional func waveDidComplete(waveNumber: Int)
    @objc optional func gameDidEnd()
}
