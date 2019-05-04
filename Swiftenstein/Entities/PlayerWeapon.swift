//
//  Weapons.swift
//
//  Created by Nick Lockwood on 25/04/2019.
//  Copyright © 2019 Nick Lockwood. All rights reserved.
//

import Foundation

struct AmmoType: Hashable {
    private let uuid = UUID()
}

struct WeaponType: Equatable {
    private let uuid = UUID()

    var ammoType: AmmoType?
    var idle: Animation?
    var firing: Animation?
    var impact: Animation?
    var cooldown: TimeInterval
    var damage: Double
    var spread: Double

    static func == (lhs: WeaponType, rhs: WeaponType) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}

class PlayerWeapon: Entity, Animated, Sprite {
    let radius: Double = 0
    let scale = 0.2

    unowned let world: World
    var type: WeaponType? {
        didSet {
            animation = type?.idle
        }
    }

    var animation: Animation? {
        didSet {
            animationTime = 0
        }
    }

    var animationTime: TimeInterval = 0
    var position = Vector(0, 0)

    init(world: World, weapon: WeaponType) {
        self.world = world
        type = weapon
        animation = weapon.idle
    }

    func fire() {
        animation = type?.firing?.then { [unowned self] in
            self.animation = self.type?.idle
        }
    }
}
