//
//  Explosion.swift
//
//  Created by Nick Lockwood on 28/04/2019.
//  Copyright © 2019 Nick Lockwood. All rights reserved.
//

import Foundation

class Explosion: Entity, Animated, Sprite {
    let animation: Animation?
    var animationTime: TimeInterval

    let position: Vector
    let radius: Double = 0.0
    unowned let world: World

    init(world: World, position: Vector, animation: Animation) {
        self.world = world
        self.position = position
        self.animation = animation
        animationTime = 0
    }
}
