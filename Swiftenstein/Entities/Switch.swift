//
//  Switch.swift
//
//  Created by Nick Lockwood on 07/05/2019.
//  Copyright © 2019 Nick Lockwood. All rights reserved.
//

import Foundation

enum SwitchState {
    case on
    case off
}

class Switch: Trigger {
    let radius = 0.0
    unowned let world: World

    let position: Vector
    var state: SwitchState = .off

    init(world: World, x: Int, y: Int) {
        self.world = world
        position = Vector(Double(x), Double(y))
    }

    func isTouching(_ entity: Entity) -> Bool {
        return entity.intersection(withTileAt: Int(position.x), Int(position.y)) != nil
    }

    func activate(with entity: Entity) {
        guard state == .off, let switcher = entity as? Switcher else {
            return
        }
        state = .on
        if case let .switch(a, b) = world.map[position] {
            world.map[Int(position.x), Int(position.y)] = .switch(b, alt: a)
        }
        switcher.didActivateSwitch(self)
    }
}
