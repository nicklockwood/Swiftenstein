//
//  Entities.swift
//
//  Created by Nick Lockwood on 24/04/2019.
//  Copyright © 2019 Nick Lockwood. All rights reserved.
//

import Foundation

class PushWall: Trigger {
    unowned let world: World
    var position: Vector
    let texture: Int
    let radius = 0.0

    private var partitions: [Partition] = []
    private var isMoving = false
    private var direction = Vector(0, 0)
    private var progress = 0.0

    init(world: World, texture: Int, x: Int, y: Int) {
        self.world = world
        position = Vector(Double(x), Double(y))
        self.texture = texture
    }

    private func updatePartitions() {
        partitions[0].start = position
        partitions[0].end = position + Vector(0, 1)
        partitions[1].start = position + Vector(0, 1)
        partitions[1].end = position + Vector(1, 1)
        partitions[2].start = position + Vector(1, 1)
        partitions[2].end = position + Vector(1, 0)
        partitions[3].start = position + Vector(1, 0)
        partitions[3].end = position
    }

    func isTouching(_ entity: Entity) -> Bool {
        guard entity is Player else {
            return false
        }
        return entity.intersection(withTileAt: Int(position.x), Int(position.y)) != nil
    }

    func activate(with entity: Entity) {
        guard !isMoving else {
            return
        }
        // remove wall
        world.map[Int(position.x), Int(position.y)] = .floor
        // add partitions
        let p = position
        for _ in 0 ..< 4 {
            partitions.append(Partition(texture: texture, start: p, end: p))
            world.partitions.append(partitions.last!)
        }
        updatePartitions()
        // start moving
        direction = position + Vector(0.5, 0.5) - entity.position
        if abs(direction.x) > abs(direction.y) {
            direction.x = direction.x > 0 ? 1 : -1
            direction.y = 0
        } else {
            direction.x = 0
            direction.y = direction.y > 0 ? 1 : -1
        }
        isMoving = true
    }

    private func stopMoving() {
        isMoving = false
        position = Vector(floor(position.x), floor(position.y))
        // update map
        world.map[Int(position.x), Int(position.y)] = .pushWall(texture)
        // remove partitions
        for partition in partitions {
            world.remove(partition)
        }
        partitions.removeAll()
    }

    private var forwardWall: Partition {
        if direction.x < 0 {
            return partitions[0]
        } else if direction.y > 0 {
            return partitions[1]
        } else if direction.x > 0 {
            return partitions[2]
        } else {
            return partitions[3]
        }
    }

    func update(dt: TimeInterval) {
        guard isMoving else {
            return
        }
        let oldPos = position
        position += direction * dt * 0.2
        if direction.x < 0 || direction.y < 0 {
            if world.map[Int(position.x), Int(position.y)] != .floor {
                position = oldPos
                stopMoving()
                return
            }
        } else if world.map[Int(ceil(position.x)), Int(ceil(position.y))] != .floor {
            stopMoving()
            return
        }
        updatePartitions()
        for case let movable as Movable in world.entities {
            guard movable.intersection(with: forwardWall) != nil else {
                continue
            }
            if !movable.avoidWalls() {
                // cause damage
                if let killable = movable as? Killable {
                    killable.hurt(20)
                }
                // stuck
                position = oldPos
                updatePartitions()
                return
            }
        }
    }
}
