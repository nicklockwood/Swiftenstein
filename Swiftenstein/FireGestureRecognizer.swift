//
//  FireGestureRecognizer.swift
//  FPSControls
//
//  Created by Nick Lockwood on 09/11/2014.
//  Copyright (c) 2014 Nick Lockwood. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class FireGestureRecognizer: UIGestureRecognizer {
    var autofireThreshold: CGFloat = 0.8
    var timeThreshold: TimeInterval = 0.15
    var distanceThreshold: CGFloat = 5.0
    private var startTimes = [Int: TimeInterval]()

    private(set) var isAutofireEngaged: Bool = false

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        //record the start times of each touch
        for touch in touches {
            startTimes[touch.hash] = touch.timestamp
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        //discard any touches that have moved
        isAutofireEngaged = false
        for touch in touches {
            let newPos = touch.location(in: view)
            let oldPos = touch.previousLocation(in: view)
            let distanceDelta = max(abs(newPos.x - oldPos.x), abs(newPos.y - oldPos.y))
            if distanceDelta >= distanceThreshold {
                startTimes[touch.hash] = nil
            }
            if touch.force / touch.maximumPossibleForce >= autofireThreshold {
                isAutofireEngaged = true
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        isAutofireEngaged = false
        for touch in touches {
            let startTime = startTimes[touch.hash]
            if let startTime = startTime {
                //check if within time
                let timeDelta = touch.timestamp - startTime
                if timeDelta < timeThreshold {
                    state = .recognized
                }
            }
        }
        if state == .possible {
            state = .failed
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        isAutofireEngaged = false
        state = .failed
    }
}
