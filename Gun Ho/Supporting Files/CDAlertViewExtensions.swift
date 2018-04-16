//
//  CDAlertViewExtensions.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 3/26/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import CDAlertView

extension CDAlertView {
    public static func createBuyWarningAlert() -> CDAlertView {
        let buyWarningAlert = CDAlertView(title: NSLocalizedString("Alert.BuyWarning.Title",
                                                                   comment: ""),
                                          message: NSLocalizedString("Alert.BuyWarning.Desc",
                                                                     comment: ""),
                                          type: CDAlertViewType.warning)
        buyWarningAlert.add(action: CDAlertViewAction(title: NSLocalizedString("Alert.Button.Ok",
                                                                               comment: "")))
        
        return buyWarningAlert
    }
    
    // Creates an alert to display info about the app
    public static func createInfoAlert() -> CDAlertView {
        let infoAlert = CDAlertView(title: NSLocalizedString("Alert.Info.Title",
                                                             comment: ""),
                                    message: NSLocalizedString("Alert.Info.Desc",
                                                               comment: ""),
                                    type: CDAlertViewType.custom(image: #imageLiteral(resourceName: "icon")))
        
        infoAlert.add(action: CDAlertViewAction(title: NSLocalizedString("Alert.Button.Close",
                                                                         comment: ""),
                                                font: nil,
                                                textColor: nil,
                                                backgroundColor: nil,
                                                handler: nil))
        let githubAction = CDAlertViewAction(title: NSLocalizedString("Alert.Info.Button.Site",
                                                                      comment: ""),
                                             font: nil,
                                             textColor: nil,
                                             backgroundColor: nil,
                                             handler: { (action) in
            let gitHubAddress = "https://github.com/Chris-Perkins/Gun-Ho-iOS/blob/master/README.md"
            if let url = URL(string: gitHubAddress) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })
        githubAction.shouldHideOnPress = false
        infoAlert.add(action: githubAction)
        
        
        return infoAlert
    }
    
    // Shows this alert after an OK action was added.
    public func showAfterAddingOkayAction() {
        add(action: CDAlertViewAction(title: NSLocalizedString("Alert.Button.Ok",
                                                               comment: "")))
        
        show()
    }
}
