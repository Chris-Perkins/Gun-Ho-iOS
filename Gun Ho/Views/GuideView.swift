//
//  GuideView.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 3/22/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import UIKit

class GuideView: UIView {
    
    // MARK: View properties
    
    @IBOutlet weak var guideLabel: UILabel!

    public enum GuideType {
        case selectPlane
        case startGame
        case destroyBoat
    }
    
    // MARK: Initializers
    
    private func loadViewFromXib() -> UIView {
        guard let guideView = Bundle.main.loadNibNamed("GuideView",
                                                       owner: self,
                                                       options: nil)?.first as? UIView else {
            fatalError("Could not get the guide view from the xib. Does it exist?")
        }
        
        setLabelTextToStep(type: .selectPlane)
    
        return guideView
    }
    
    private override init(frame: CGRect) {
        fatalError("Cannot instantiate GuideView directly!")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let guideView = loadViewFromXib()
        addSubview(guideView)
        NSLayoutConstraint.clingViewToView(view: guideView,
                                           toView: self)
    }
    
    // MARK: Custom functions
    
    public func setLabelTextToStep(type: GuideView.GuideType) {
        var guideText: String?
        
        switch(type) {
        case .selectPlane:
            guideText = NSLocalizedString("Guide.SelectPlane", comment: "")
        case .startGame:
            guideText = NSLocalizedString("Guide.StartGame", comment: "")
        case .destroyBoat:
            guideText = NSLocalizedString("Guide.DestroyBoat", comment: "")
        }
        
        guideLabel.text = guideText
    }
}
