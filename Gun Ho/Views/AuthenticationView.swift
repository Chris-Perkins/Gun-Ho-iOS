//
//  AuthenticationView.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 3/22/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import UIKit

class AuthenticationView: UIView {
    
    // MARK: View Properties
    
    // Constraints active when the login state is toggled
    @IBOutlet var loginConstraints: [NSLayoutConstraint]!
    // Constraints active when the signup state is toggled
    @IBOutlet var signupConstraints: [NSLayoutConstraint]!
    
    // Username/Password/Confirm fields; just references for validation.
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    
    // The toggle state button reference
    @IBOutlet weak var toggleStateButton: UIButton!
    @IBOutlet weak var postScoreButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    // Start out on the login screen
    var isLoginState: Bool = true {
        didSet {
            setToggleTitle()
            
            for constraint in loginConstraints {
                constraint.isActive = isLoginState
            }
            
            for constraint in signupConstraints {
                constraint.isActive = !isLoginState
            }
            
            UIView.animate(withDuration: 0.25) {
                self.layoutIfNeeded()
            }
        }
    }
    
    // MARK: Initializers
    
    private override init(frame: CGRect) {
        fatalError("Cannot initialize AuthenticationView directly!")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Initializes the view from the xib
    static func loadViewFromXib() -> AuthenticationView {
        guard let authView = Bundle.main.loadNibNamed("AuthenticationView",
                                                      owner: nil,
                                                      options: nil)?.first as? AuthenticationView else {
                                                        fatalError("Could not get the auth view from the xib. Does it exist?")
        }
        
        return authView
    }
    
    // MARK: View actions
    
    // Called whenever the toggle button is pressed
    @IBAction func buttonPress(_ sender: Any) {
        switch sender as? UIButton {
        case toggleStateButton:
            isLoginState = !isLoginState
        case postScoreButton:
            print("LOGIN/VALIDATE/POST SCORE HERE")
        case closeButton:
            removeFromSuperview()
        default:
            fatalError("Unhandled button pressed in authentication view")
        }
        
    }
    
    // MARK: View life-cycle
    
    override func layoutSubviews() {
        setToggleTitle()
    }
    
    // MARK: Misc helper functions
    
    func toggleLoginState() {
        
    }
    
    // Sets the toggle button's title based on login state
    func setToggleTitle() {
        toggleStateButton.setTitle(isLoginState ?
                                    "New? Sign Up!":
                                    "I want to login",
                                   for: .normal)
    }
}
