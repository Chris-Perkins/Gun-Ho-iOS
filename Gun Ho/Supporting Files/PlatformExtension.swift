//
//  PlatformExtension.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 2/13/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import Foundation

struct Platform {
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
}
