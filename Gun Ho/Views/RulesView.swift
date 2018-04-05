//
//  RulesView.swift
//  Gun Ho
//
//  Created by Alex Phillips on 4/4/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import UIKit

class RulesView: UIView {
    
    // MARK: View Properties
   
    @IBAction func backButton(_ sender: UIButton) {
        
    }
    
    static func loadViewFromXib() -> UIView {
        guard let rulesView = Bundle.main.loadNibNamed("RulesView",
                                                      owner: self,
                                                      options: nil)?.first as? UIView else {
                                                        fatalError("Could not get the guide view from the xib. Does it exist?")
        }
        return rulesView
    }
}
