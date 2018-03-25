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
    private var isLoginState: Bool = true {
        didSet {
            setToggleTitle()
            
            if isLoginState {
                // Resign since we are no longer logging in (hidden text field)
                passwordConfirmTextField.resignFirstResponder()
            }
            
            for constraint in loginConstraints {
                constraint.isActive = isLoginState
            }
            
            for constraint in signupConstraints {
                constraint.isActive = !isLoginState
            }
            
            // Animates constraint changes
            UIView.animate(withDuration: 0.25) {
                self.layoutIfNeeded()
            }
        }
    }
    
    public var displayScore: Int = 0 {
        didSet {
            let scoreString = NSLocalizedString("AuthenticationView.ScoreLabel.Text", comment: "")
            
            scoreLabel.text = scoreString.replacingOccurrences(of: "{0}",
                                                               with: "\(displayScore)")
        }
    }
    
    // MARK: Computed variables
    
    // Determines if we can login based on username textfield & password textfield
    private var canLogin: Bool {
        if let userText = usernameTextField.text,
            let passwordText = passwordTextField.text {
            
            return userText.count > 0 && passwordText.count > 0
        }
        return false
    }
    
    // Determines if we can sign up based on canLogin & confirmPasswordField
    private var canSignup: Bool {
        if let passwordText = passwordTextField.text,
            let passwordConfirmText = passwordConfirmTextField.text {
            
            return canLogin && passwordText == passwordConfirmText
        }
        return false
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
            let postScoreHandler: (Bool) -> () = { (success) in
                print("WOOHOO!")
            }
            
            if isLoginState {
                if canLogin {
                    let username = usernameTextField.text!
                    let password = passwordTextField.text!
                    WebRequestHandler.shared.attemptLogin(withUsername: username,
                                                          andPassword: password)
                    { (success) in
                        if success {
                            WebRequestHandler.shared.attemptPostScore(toUsername: username,
                                                                      andScore: self.displayScore, actionOnCompleteWithSuccess: postScoreHandler)
                        } else {
                            // TODO: Handler
                        }
                    }
                    
                } else {
                    // TODO: Handler
                }
            } else {
                if canSignup {
                    let username = usernameTextField.text!
                    let password = passwordTextField.text!
                    WebRequestHandler.shared.attemptSignUp(withUsername: username,
                                                           andPassword: password)
                    { (success) in
                        if success {
                            WebRequestHandler.shared.attemptPostScore(toUsername: username,
                                                                      andScore: self.displayScore, actionOnCompleteWithSuccess: postScoreHandler)
                        } else {
                            // TODO: HANDLER
                        }
                    }
                } else {
                    // TODO: Handler
                }
            }
        case closeButton:
            removeFromSuperview()
        default:
            fatalError("Unhandled button pressed in authentication view")
        }
        
    }
    
    // MARK: View life-cycle
    
    override func layoutSubviews() {
        // TODO: Can we do these elsewhere?
        // Works for now, but is bad practice.
        setToggleTitle()
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        passwordConfirmTextField.delegate = self
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

extension AuthenticationView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case usernameTextField:
            return true
        case passwordTextField:
            if isLoginState {
                textField.resignFirstResponder()
                return false
            }
            return true
        case passwordConfirmTextField:
            textField.resignFirstResponder()
            return false
        default:
            fatalError("Error: unhandled text field")
        }
    }
}
