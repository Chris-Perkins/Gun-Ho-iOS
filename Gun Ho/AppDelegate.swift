//
//  AppDelegate.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 2/6/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // For custom keyboard view beautifying
        IQKeyboardManager.sharedManager().enable = true
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        if GameManager.shared.inActiveGame {
            GameManager.shared.setPauseState(to: true)
        }
    }
}

