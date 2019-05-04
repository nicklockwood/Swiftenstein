//
//  Player.swift
//
//  Created by Nick Lockwood on 28/04/2019.
//  Copyright © 2019 Nick Lockwood. All rights reserved.
//

import Foundation

protocol PlayerDelegate: AnyObject {
    func playerWasHurt(_ player: Player)
    func playerWasKilled(_ player: Player)
    func playerPoweredUp(_ player: Player)
}

class Player: Actor, Killable, Armed {
    let fov: Double = .pi / 2 // TODO:
    var radius = 0.2

    var eyeline = 0.5
    var position: Vector
    var direction: Vector
    var health: Double = 100

    var bobPhase = 0.0
    let bobScale = 0.025
    let weaponSway = 0.05

    var ammo: [AmmoType: Double] = [:]
    var weapons: [WeaponType] = []

    var lastFired: TimeInterval = 0
    let weapon: PlayerWeapon
    var weaponType: WeaponType? {
        return weapon.type
    }

    unowned let world: World
    weak var delegate: PlayerDelegate?

    init(world: World, delegate: PlayerDelegate, position: Vector, direction: Vector) {
        self.world = world
        self.delegate = delegate
        self.position = position
        self.direction = direction
        ammo = [.pistol: 10]
        weapons = [.pistol]
        weapon = PlayerWeapon(world: world, weapon: .pistol)
    }

    func rotate(_ radians: Double) {
        direction = direction.rotated(by: radians)
    }

    func advance(_ distance: Double) {
        bobPhase += distance
        eyeline = 0.5 + (1 + sin(bobPhase * .pi * 2)) * bobScale
        position += direction * distance
    }

    func strafe(_ distance: Double) {
        position += Vector(-direction.y, direction.x) * distance
    }

    func stagger() {
        delegate?.playerWasHurt(self)
    }

    func die() {
        radius = 0.01
        delegate?.playerWasKilled(self)
    }

    func shoot() {
        let ammoType = weapon.type?.ammoType
        if let ammoType = ammoType {
            if let ammoCount = ammo[ammoType], ammoCount > 0 {
                weapon.fire()
                ammo[ammoType] = ammoCount - 1
            } else {
                // switch to another weapon
                weapon.type = weapons.first(where: {
                    $0.ammoType.map { self.ammo[$0] ?? 0 > 0 } ?? true
                })
            }
        } else {
            // No ammo required
            weapon.fire()
        }
    }

    func powerUp(_ pickup: PickupType) {
        health += pickup.health
        for (ammoType, ammo) in pickup.ammo {
            let ammoCount = self.ammo[ammoType] ?? 0
            self.ammo[ammoType] = ammoCount + ammo
            if ammoCount == 0 {
                // switch to that weapon
                weapon.type = weapons.first(where: {
                    $0.ammoType == ammoType
                })
            }
        }
        if let weaponType = pickup.weapon, !weapons.contains(weaponType) {
            self.weapons.append(weaponType)
            weapon.type = weaponType
        }
        if weapon.type == nil {
            // switch to another weapon
            weapon.type = weapons.first(where: {
                $0.ammoType.map { self.ammo[$0] ?? 0 > 0 } ?? true
            })
        }
        delegate?.playerPoweredUp(self)
    }

    func update(dt: TimeInterval) {
        if isDead {
            eyeline = max(0.1, eyeline - dt * 0.2)
            weapon.position = position - direction
        } else {
            let (d, _) = world.hitTest(Ray(origin: position, direction: direction))
            let weaponDistance = min(d - 0.1, 0.2)
            let sway = sin(bobPhase * .pi) * weaponSway
            weapon.position = position + direction.rotated(by: sway) * weaponDistance
        }
    }
}
