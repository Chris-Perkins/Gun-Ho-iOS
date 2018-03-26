//
//  CDAlertViewExtensions.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 3/26/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import CDAlertView

extension CDAlertView {
    public func showAfterAddingOkayAction() {
        add(action: CDAlertViewAction(title: NSLocalizedString("Messages.Ok", comment: "")))
        
        show()
    }
}
