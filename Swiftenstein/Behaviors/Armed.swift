//
//  Armed.swift
//
//  Created by Nick Lockwood on 28/04/2019.
//  Copyright © 2019 Nick Lockwood. All rights reserved.
//

import Foundation

protocol Armed: Actor {
    var lastFired: TimeInterval { get set }
    var weaponType: WeaponType? { get }

    func shoot()
}

extension Armed {
    var canFire: Bool {
        guard let weaponType = weaponType else {
            return false
        }
        return world.time - lastFired >= weaponType.cooldown
    }

    func fire() {
        guard canFire, let weaponType = weaponType else {
            return
        }
        shoot()
        lastFired = world.time
        let spread = Double.random(in: -weaponType.spread ... weaponType.spread)
        let direction = self.direction.rotated(by: spread)
        let (distance, entity) = world.hitTest(Ray(
            origin: position,
            direction: direction
        ))
        if let killable = entity as? Killable {
            killable.hurt(weaponType.damage)
            return
        }
        if let movable = entity as? Movable {
            movable.position += direction * 0.02 / movable.mass
        }
        // draw impact
        if let impact = weaponType.impact {
            var explosion: Explosion!
            func cleanup() {
                explosion.world.remove(explosion)
            }
            explosion = Explosion(
                world: world,
                position: position + direction * (distance - 0.02),
                animation: impact.then(cleanup)
            )
            world.entities.append(explosion)
        }
    }
}
