//
//  Animations.swift
//
//  Created by Nick Lockwood on 23/04/2019.
//  Copyright © 2019 Nick Lockwood. All rights reserved.
//

import Foundation

enum AnimationMode {
    case loop
    case reset
    case clamp
}

struct Animation {
    var duration: TimeInterval
    var mode: AnimationMode
    var frames: [Int]
    private(set) var onCompletion: () -> Void = {}

    init(duration: TimeInterval, mode: AnimationMode, frames: [Int]) {
        self.duration = duration
        self.mode = mode
        self.frames = frames
    }

    func then(_ onCompletion: @escaping () -> Void) -> Animation {
        var animation = self
        let oldCompletion = animation.onCompletion
        animation.onCompletion = {
            oldCompletion()
            onCompletion()
        }
        return animation
    }

    func frame(at time: TimeInterval) -> Int {
        guard duration > 0, frames.count > 1 else {
            return frames.first ?? 0
        }
        var t = time / duration
        if t >= 1 {
            switch mode {
            case .loop:
                t = t.truncatingRemainder(dividingBy: 1)
            case .clamp:
                t = 1
            case .reset:
                t = 0
            }
        }
        let count = frames.count
        return frames[min(Int(Double(count) * t), count - 1)]
    }
}
