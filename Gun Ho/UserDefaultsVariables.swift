//
//  UserDefaultsVariables.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 4/8/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import Foundation

// MARK: Constant Key Strings

fileprivate let scoresKey  = "PreviousScores"
fileprivate let whalesKey  = "WhalesCount"
fileprivate let wMinesKey  = "WaterMinesCount"
fileprivate let tBirdsKey  = "TotalBirdsCount"
fileprivate let sawWarnKey = "SawWarningKey"
fileprivate let demoActKey = "DemoModeActiveKey"

// MARK: Scores Getter/Appender

public var previousScoresReference: [Int] {
    return UserDefaults.standard.object(forKey: scoresKey) as? [Int] ?? [Int]()
}

public func appendNewScore(_ score: Int) {
    var prevScores = previousScoresReference
    prevScores.append(score)
    
    UserDefaults.standard.set(prevScores, forKey: scoresKey)
    UserDefaults.standard.synchronize()
}

// MARK: Whales Count Getter/Setter

public var currentWhaleCount: Int {
    return UserDefaults.standard.object(forKey: whalesKey) as? Int ?? 0
}

public func setWhaleCount(to value: Int) {
    UserDefaults.standard.set(value, forKey: whalesKey)
    UserDefaults.standard.synchronize()
    
    NotificationCenter.default.post(Notification(name: whaleCountSet))
}

// MARK: Water Mine Getter/Setter

public var currentWaterMineCount: Int {
    return UserDefaults.standard.object(forKey: wMinesKey) as? Int ?? 0
}

public func setWaterMineCount(to value: Int) {
    UserDefaults.standard.set(value, forKey: wMinesKey)
    UserDefaults.standard.synchronize()
    
    NotificationCenter.default.post(Notification(name: waterMineCountSet))
}

// MARK: Bird Setter/Getter

public var currentBirdsCount: Int {
    return UserDefaults.standard.object(forKey: tBirdsKey) as? Int ?? 0
}

public func setBirdCount(to value: Int) {
    UserDefaults.standard.set(value, forKey: tBirdsKey)
    UserDefaults.standard.synchronize()
    
    NotificationCenter.default.post(Notification(name: birdCountSet))
}

// MARK: User Saw Buy Warning Getter/Setters

public var userSawBuyWarning: Bool {
    return UserDefaults.standard.object(forKey: sawWarnKey) as? Bool ?? false
}

public func setUserSawBuyWarning(to value: Bool) {
    UserDefaults.standard.set(value, forKey: sawWarnKey)
    UserDefaults.standard.synchronize()
}

// MARK: is Demo Mode Getter

public var demoModeIsActive: Bool {
    return UserDefaults.standard.object(forKey: demoActKey) as? Bool ?? false
}
