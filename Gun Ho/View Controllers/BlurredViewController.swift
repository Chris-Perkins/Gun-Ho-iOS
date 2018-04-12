//
//  BlurredViewController.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 4/10/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import UIKit

public class BlurredViewController: UIViewController {
    
    // MARK: Properties
    
    private var blurView: UIVisualEffectView!
    
    // MARK: Life-cycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Creates a blur and sends it to the back
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.light))
        blurView.alpha = 0.5
        view.addSubview(blurView)
        NSLayoutConstraint.clingViewToView(view: blurView,
                                           toView: view)
        view.sendSubview(toBack: blurView)
    }
    
    override public func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if flag {
            UIView.animate(withDuration: 0.25) {
                self.blurView.alpha = 0
            }
        }
        
        super.dismiss(animated: flag, completion: completion)
    }
}
