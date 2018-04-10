//
//  InfoViewController.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 4/5/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    
    // MARK: Properties
    
    // Light-status bar display
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // IBOutlets
    @IBOutlet weak var emailUsButton: UIButton!
    @IBOutlet weak var githubButton: UIButton!
    
    // MARK: Actions
    
    @IBAction func buttonPress(_ sender: UIButton) {
        switch sender {
        case githubButton:
            if let url = URL(string: "https:////github.com//Chris-Perkins//Gun-Ho-iOS") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case emailUsButton:
            if let url = URL(string: "mailto:chris@chrisperkins.me") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        default:
            fatalError("Unhandled button press in InfoViewController")
        }
    }
}
