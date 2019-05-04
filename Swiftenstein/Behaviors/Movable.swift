//
//  Movable.swift
//
//  Created by Nick Lockwood on 28/04/2019.
//  Copyright © 2019 Nick Lockwood. All rights reserved.
//

protocol Movable: Entity {
    var position: Vector { get set }
    var mass: Double { get }
}

extension Movable {
    var mass: Double { return radius * radius * .pi }

    func avoidWalls(attempts: Int = 3) -> Bool {
        var intersecting = true
        var attempts = attempts
        while intersecting, attempts > 0 {
            intersecting = false
            attempts -= 1
            for y in Int(position.y - radius) ... Int(position.y + radius) {
                for x in Int(position.x - radius) ... Int(position.x + radius) {
                    if !world.map[x, y].isFloorOrDoor, let v = intersection(withTileAt: x, y) {
                        position -= v * 1.01
                        intersecting = true
                    }
                }
            }
            for partition in world.partitions {
                if let v = intersection(with: partition) {
                    position -= v * 1.01
                    intersecting = true
                }
            }
        }
        return !intersecting
    }
}
