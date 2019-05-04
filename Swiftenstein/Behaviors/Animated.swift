//
//  Animated.swift
//
//  Created by Nick Lockwood on 28/04/2019.
//  Copyright © 2019 Nick Lockwood. All rights reserved.
//

import Foundation

protocol Animated: AnyObject {
    var animation: Animation? { get }
    var animationTime: TimeInterval { get set }
}

extension Animated {
    var texture: Int? {
        return animation?.frame(at: animationTime)
    }

    func updateAnimation(dt: TimeInterval) {
        guard let animation = animation else {
            return
        }
        animationTime += dt
        if animationTime >= animation.duration,
            animationTime < animationTime + dt,
            animation.mode != .loop {
            animation.onCompletion()
        }
    }
}
