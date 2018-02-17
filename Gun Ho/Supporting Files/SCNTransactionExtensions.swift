//
//  SCNTransactionExtensions.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 2/16/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import SceneKit

extension SCNTransaction {
    public static func perform(transactionAction action: () -> Void) {
        SCNTransaction.begin()
        action()
        SCNTransaction.commit()
        SCNTransaction.flush()
    }
}
