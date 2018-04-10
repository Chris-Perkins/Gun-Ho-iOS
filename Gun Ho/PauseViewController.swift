//
//  PauseViewController.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 4/10/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import UIKit

class PauseViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var quitButton: UIButton!
    
    // MARK: Actions
    
    @IBAction func buttonPress(_ sender: UIButton) {
        switch sender {
        case resumeButton:
            GameManager.shared.togglePauseState()
            dismiss(animated: true, completion: nil)
        case quitButton:
            GameManager.shared.forceQuitSession()
            dismiss(animated: true, completion: nil)
        default:
            fatalError("Unhandled button press in PauseViewController")
        }
    }
}
