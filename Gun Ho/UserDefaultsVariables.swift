//
//  UserDefaultsVariables.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 4/8/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import Foundation

private let scoresKey = "PreviousScores"

public var previousScoresReference: [Int] {
    return UserDefaults.standard.object(forKey: scoresKey) as? [Int] ?? [Int]()
}

public func appendNewScore(_ score: Int) {
    var prevScores = previousScoresReference
    prevScores.append(score)
    
    UserDefaults.standard.set(prevScores, forKey: scoresKey)
    UserDefaults.standard.synchronize()
}
