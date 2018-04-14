//
//  GameOverViewController.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 4/14/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//
/* NOTE: If the application is running in `demo` mode,
    This view controller is not the one that is shown on game over.
    Look at AuthenticationViewController instead. */

import UIKit

public class GameOverViewController: ScoreDisplayViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    
    
    @IBAction func buttonPress(_ sender: UIButton) {
        switch sender {
        case closeButton:
            dismiss(animated: true)
        default:
            fatalError("Unhandled button press")
        }
    }
}
