//
//  MenuView.swift
//  Gun Ho
//
//  Created by Alex Phillips on 3/28/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import UIKit

class MenuView: UIView {
    
   // MARK: View Properties
    
    @IBAction func rulesButton(_ sender: UIButton) {
        
    }
    
    @IBAction func playButton(_ sender: UIButton) {
        
    }
    
    static func loadViewFromXib() -> MenuView {
        guard let menuView = Bundle.main.loadNibNamed("MenuView",
                                                      owner: nil,
                                                      options: nil)?.first as? MenuView else {
                                                        fatalError("Could not get the auth view from the xib. Does it exist?")
        }
        
        return menuView
    }
}

