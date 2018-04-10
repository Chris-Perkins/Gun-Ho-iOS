//
//  CDAlertViewExtensions.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 3/26/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import CDAlertView

extension CDAlertView {
    public static func createInfoAlert() -> CDAlertView {
        let infoAlert = CDAlertView(title: NSLocalizedString("Alert.Info.Title",
                                                             comment: ""),
                                    message: NSLocalizedString("Alert.Info.Desc",
                                                               comment: ""),
                                    type: CDAlertViewType.custom(image: #imageLiteral(resourceName: "bird")))
        
        infoAlert.add(action: CDAlertViewAction(title: NSLocalizedString("Messages.Close",
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
            if let url = URL(string: "https:////github.com//Chris-Perkins//Gun-Ho-iOS") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })
        githubAction.shouldHideOnPress = false
        infoAlert.add(action: githubAction)
        
        
        return infoAlert
    }
    
    public func showAfterAddingOkayAction() {
        add(action: CDAlertViewAction(title: NSLocalizedString("Messages.Ok", comment: "")))
        
        show()
    }
}
