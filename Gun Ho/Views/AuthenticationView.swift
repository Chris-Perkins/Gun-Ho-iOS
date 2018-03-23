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
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    
    // The toggle state button reference
    @IBOutlet weak var toggleStateButton: UIButton!
    
    // Start out on the login screen
    var isLoginState = true
    
    // MARK: Initializers
    
    private override init(frame: CGRect) {
        fatalError("Cannot initialize AuthenticationView directly!")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let authView = loadViewFromXib()
        addSubview(authView)
        NSLayoutConstraint.clingViewToView(view: authView,
                                           toView: self)
    }
    
    // Initializes the view from the xib
    private func loadViewFromXib() -> AuthenticationView {
        guard let authView = Bundle.main.loadNibNamed("AuthenticationView",
                                                      owner: nil,
                                                      options: nil)?.first as? AuthenticationView else {
                                                        fatalError("Could not get the auth view from the xib. Does it exist?")
        }
        
        return authView
    }
    
    // MARK: View actions
    
    // Called whenever the toggle button is pressed
    @IBAction func toggleStateButtonPress(_ sender: Any) {
        isLoginState = !isLoginState
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
    
    // MARK: View life-cycle
    
    override func layoutSubviews() {
        setToggleTitle()
    }
    
    // MARK: Misc helper functions
    
    // Sets the toggle button's title based on login state
    func setToggleTitle() {
        toggleStateButton.setTitle(isLoginState ?
                                    "New? Sign Up!":
                                    "I want to login",
                                   for: .normal)
    }
}
