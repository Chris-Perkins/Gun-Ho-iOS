//
//  ScoreDisplayViewController.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 4/14/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import UIKit

public class ScoreDisplayViewController: BlurredViewController {
    
    // MARK: Properties
    
    // The label which displays the application's score
    @IBOutlet weak var scoreLabel: UILabel!
    
    // The score we're displaying in the score label
    public var displayScore: Int = 0 {
        didSet {
            setScoreLabelTitle()
        }
    }
    
    // MARK: Life-cycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setScoreLabelTitle()
    }
    
    // MARK: Custom functions
    
    // Sets the score label's title to the displayScore
    private func setScoreLabelTitle() {
        let scoreString = NSLocalizedString("Authentication.ScoreLabel.Text", comment: "")
        
        scoreLabel?.text = scoreString.replacingOccurrences(of: "{0}",
                                                            with: "\(displayScore)")
    }
}
