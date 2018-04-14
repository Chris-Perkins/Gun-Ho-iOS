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
    
    // MARK: Properties
    
    // The button we press to close the view
    @IBOutlet weak var closeButton: UIButton!
    // The labels which display the top scores
    @IBOutlet var scoreLabels: [UILabel]!
    
    // MARK: Life-cycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setScoreLabelsTextToTopScores()
    }
    
    // MARK: Events
    
    @IBAction func buttonPress(_ sender: UIButton) {
        switch sender {
        case closeButton:
            dismiss(animated: true)
        default:
            fatalError("Unhandled button press in GameOverViewController")
        }
    }
    
    // MARK: Custom functions
    
    // Sets the scores for the top labels
    private func setScoreLabelsTextToTopScores() {
        // Whether or not we printed " (new!)" by a score we just got.
        var printedDisplayedScore = false
        let topScores = Array(previousScoresReference.sorted().reversed())
        
        for (index, label) in scoreLabels.enumerated() {
            if index >= topScores.count {
                label.text = "--"
            } else {
                label.text = "\(topScores[index])"
                
                // If this is the score we just got...
                if topScores[index] == displayScore && !printedDisplayedScore {
                    label.text = label.text! + NSLocalizedString("GameOver.Labels.New",
                                                                 comment: "")
                    printedDisplayedScore = true
                }
            }
        }
    }
}
