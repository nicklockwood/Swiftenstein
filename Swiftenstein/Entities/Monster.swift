//
//  Monster.swift
//
//  Created by Nick Lockwood on 28/04/2019.
//  Copyright © 2019 Nick Lockwood. All rights reserved.
//

import Foundation

private let monsterWalkSpeed = 1.0

struct MonsterType {
    var idle: Animation
    var walking: Animation
    var aiming: Animation
    var shooting: Animation
    var staggering: Animation
    var death: Animation
}

enum MonsterState {
    case idle
    case staggering
    case dead
    case pursuit
    case aiming
}

class Monster: Actor, Killable, Armed, Sprite, Animated {
    let fov: Double = .pi * 2 // 360 deg

    let type: MonsterType
    var position: Vector
    var direction: Vector
    var health: Double = 50
    var animationTime: TimeInterval = 0
    var lastKnownPlayerPosition: Vector?

    unowned var world: World

    var radius: Double {
        switch state {
        case .idle, .pursuit, .aiming, .staggering:
            return 0.2
        case .dead:
            return 0
        }
    }

    var animation: Animation? {
        didSet {
            animationTime = 0
        }
    }

    var lastFired: TimeInterval = 0
    let weaponType: WeaponType? = WeaponType(
        ammoType: .pistol,
        idle: nil,
        firing: nil,
        impact: .impact,
        cooldown: 1.5,
        damage: 20,
        spread: 0.2
    )

    var state: MonsterState = .idle {
        didSet {
            switch state {
            case _ where oldValue == state:
                break
            case .staggering:
                animation = type.staggering.then {
                    self.state = .idle
                }
            case .dead:
                animation = type.death
            case .idle:
                animation = type.idle
            case .pursuit:
                animation = type.walking
            case .aiming:
                animation = type.aiming
            }
        }
    }

    func stagger() {
        state = .staggering
    }

    func die() {
        state = .dead
    }

    func shoot() {
        animation = .guardShoot
    }

    init(type: MonsterType, world: World, position: Vector) {
        self.type = type
        self.world = world
        self.position = position
        animation = type.idle
        direction = Vector(0, -1)
    }

    func update(dt: TimeInterval) {
        switch state {
        case .dead, .staggering:
            break
        case _ where world.player.isDead && world.time - lastFired > 1:
            state = .idle
        case .idle:
            if canSee(world.player) {
                state = .pursuit
                lastKnownPlayerPosition = world.player.position
            }
        case .pursuit:
            let canSeePlayer = canSee(world.player)
            if canSeePlayer {
                lastKnownPlayerPosition = world.player.position
            }
            guard let playerPosition = lastKnownPlayerPosition else {
                state = .idle
                break
            }
            let relativePosition = playerPosition - position
            let distance = relativePosition.length
            direction = relativePosition / distance
            if !canSeePlayer || distance > 1 {
                position += direction * (monsterWalkSpeed * dt)
                break
            }
            state = .aiming
        case .aiming:
            if !canSee(world.player) {
                state = .idle
                break
            }
            let relativePosition = world.player.position - position
            let distance = relativePosition.length
            direction = relativePosition / distance
            if distance > 2 {
                state = .pursuit
                break
            }
            if canFire {
                fire()
            }
        }
    }
}
