//
//  NotificationExtensions.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 3/23/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import Foundation

protocol NotificationName {
    var name: Notification.Name { get }
}

extension RawRepresentable where RawValue == String, Self: NotificationName {
    var name: Notification.Name {
        get {
            return Notification.Name(self.rawValue)
        }
    }
}
