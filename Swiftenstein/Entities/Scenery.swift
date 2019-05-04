//
//  Scenery.swift
//
//  Created by Nick Lockwood on 28/04/2019.
//  Copyright © 2019 Nick Lockwood. All rights reserved.
//

class Scenery: Movable, Sprite {
    var position: Vector
    var radius: Double
    var mass: Double
    var texture: Int?

    unowned var world: World

    init(world: World, position: Vector, radius: Double, mass: Double, texture: Int) {
        self.world = world
        self.position = position
        self.radius = radius
        self.mass = mass
        self.texture = texture
    }
}
