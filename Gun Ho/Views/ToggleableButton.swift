//
//  ToggleableButton.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 4/6/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//
// Adapted and re-used from my old "Lifting Buddy" project

import UIKit

public class ToggleableButton: UIButton {
    
    // MARK: View properties
    
    // Whether or not the button is toggled (default false)
    @IBInspectable public var isToggled: Bool = false {
        didSet {
            backgroundColor = isToggled ? toggleViewColor : defaultViewColor
            setTitleColor(isToggled ? toggleTextColor : defaultTextColor, for: .normal)
            
            // If we toggled to a state that has non-nil text
            if (!isToggled && defaultText != nil) || (isToggled && toggleText != nil) {
                setTitle(isToggled ? toggleText : defaultText, for: .normal)
            }
        }
    }
    
    // Toggle text (string)
    @IBInspectable public var toggleText: String? {
        didSet {
            if isToggled {
                setTitle(toggleText, for: .normal)
            }
        }
    }
    // The color when toggled
    @IBInspectable public var toggleViewColor: UIColor? {
        didSet {
            if isToggled {
                backgroundColor = toggleViewColor
            }
        }
    }
    // The text color when toggled
    @IBInspectable public var toggleTextColor: UIColor? {
        didSet {
            if isToggled {
                setTitleColor(toggleTextColor, for: .normal)
            }
        }
    }
    
    // Sets default text (untoggled)
    @IBInspectable public var defaultText: String? {
        didSet {
            if !isToggled {
                setTitle(defaultText, for: .normal)
            }
        }
    }
    // The default color (untoggled)
    @IBInspectable public var defaultViewColor: UIColor? {
        didSet {
            if !isToggled {
                backgroundColor = defaultViewColor
            }
        }
    }
    // The default text color (untoggled)
    @IBInspectable public var defaultTextColor: UIColor? {
        didSet {
            if !isToggled {
                setTitleColor(defaultTextColor, for: .normal)
            }
        }
    }
    // The time between transition animations
    @IBInspectable public var transitionTime: CFTimeInterval = 0.25
    
    // MARK: Inits
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
    }
    
    // MARK: Event functions
    
    @objc public func buttonPress(sender: UIButton) {
        UIView.animate(withDuration: transitionTime, animations: {
            self.isToggled = !self.isToggled
        })
    }
}
