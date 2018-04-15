//
//  PauseViewController.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 4/10/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import UIKit

class PauseViewController: BlurredViewController{
    
    // MARK: Properties
    
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var quitButton: UIButton!
    
    // MARK: Actions
    
    @IBAction func buttonPress(_ sender: UIButton) {
        switch sender {
        case resumeButton:
            dismiss(animated: false) {
                GameManager.shared.setPauseState(to: false)
            }
        case quitButton:
            dismiss(animated: false) {
                GameManager.shared.forceQuitSession()
            }
        default:
            fatalError("Unhandled button press in PauseViewController")
        }
    }
}
