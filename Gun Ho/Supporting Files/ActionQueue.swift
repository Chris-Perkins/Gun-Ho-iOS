//
//  ActionQueue.swift
//  Gun-Ho-iOS
//
//  Created by Christopher Perkins on 3/29/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//
/*
 USE: Any time when we want actions to follow one after another,
 we have to create a very ugly nested timer block with completion
 handlers. This lets us to perform actions after each other in a nice way.
 */

import Foundation

public final class ActionQueue {
    public var queue = [Action]()
    
    /* Allows the initialization of the class with a premade queue */
    convenience init(withActions actions: [Action]) {
        self.init()
        
        queue = actions
    }
    
    // The delegate we use to notify of the queue ending
    internal var delegate: ActionQueueDelegate?
    
    public func start() {
        performNextAction()
    }
    
    // Recursively performs the actions in the queue
    private func performNextAction() {
        guard let nextAction = queue.first else {
            delegate?.queueDidEnd(self)
            return
        }
        
        queue.remove(at: 0)
        nextAction.performActions()
        Timer.scheduledTimer(withTimeInterval: nextAction.actionTime, repeats: false) { (timer) in
            self.performNextAction()
        }
    }
}

public final class Action {
    public let actionTime: CFTimeInterval
    public let performActions: () -> Void
    
    public init(actionTime: CFTimeInterval, withActions actions: @escaping () -> Void) {
        self.actionTime     = actionTime
        self.performActions = actions
    }
}

protocol ActionQueueDelegate {
    /*
     Notifies the delegate that the animation queue ended
     */
    func queueDidEnd(_ sender: ActionQueue)
}
