//
//  World.swift
//
//  Created by Nick Lockwood on 23/04/2019.
//  Copyright © 2019 Nick Lockwood. All rights reserved.
//

import Foundation

class World {
    var map: Map
    var player: Player!
    var entities: [Entity] = []
    var partitions: [Partition] = []
    var time: TimeInterval = 0

    init(map: Map) {
        self.map = map
    }

    func remove(_ entity: Entity) {
        entities.removeAll(where: { $0 === entity })
    }

    func remove(_ partition: Partition) {
        partitions.removeAll(where: { $0 === partition })
    }

    func update(dt: TimeInterval) {
        time += dt

        // update entities
        for entity in entities {
            entity.update(dt: dt)
        }

        // update triggers
        for case let trigger as Trigger in entities {
            for case let movable as Movable in entities {
                if trigger.isTouching(movable) {
                    trigger.activate(with: movable)
                }
            }
        }

        // update animations
        for case let animated as Animated in entities {
            animated.updateAnimation(dt: dt)
        }

        // prevent interpenetration between entities
        let bounce = 1.1
        for case let a as Movable in entities where a.isSolid {
            for b in entities where a !== b && b.isSolid {
                if let v = a.intersection(with: b) {
                    if let b = b as? Movable {
                        let ratio: Double
                        switch (a.mass.isFinite, b.mass.isFinite) {
                        case (true, true):
                            ratio = a.mass / (a.mass + b.mass)
                        case (false, false):
                            continue
                        case (true, false):
                            ratio = 0
                        case (false, true):
                            ratio = 1
                        }
                        a.position -= v * bounce * (1 - ratio)
                        b.position += v * bounce * ratio
                    } else {
                        a.position -= v * bounce
                    }
                }
            }
        }

        // prevent interpenetration between entities and walls
        for case let movable as Movable in entities {
            _ = movable.avoidWalls()
        }
    }

    func hitTest(_ ray: Ray) -> (Double, Entity?) {
        var distance = map.hitTest(ray)

        for partition in partitions {
            if let d = partition.hitTest(ray), d < distance {
                distance = d
            }
        }

        var hits = [(Entity, Double)]()
        for entity in entities where entity.isSolid && entity.position != ray.origin {
            if let d = entity.hitTest(ray), d < distance {
                hits.append((entity, d))
            }
        }
        hits.sort(by: { $0.1 < $1.1 })

        return hits.first.map { ($0.1, $0.0) } ?? (distance, nil)
    }
}
