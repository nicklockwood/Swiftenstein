//
//  Behaviors.swift
//
//  Created by Nick Lockwood on 24/04/2019.
//  Copyright © 2019 Nick Lockwood. All rights reserved.
//

import Foundation

protocol Actor: Movable {
    var direction: Vector { get }
    var fov: Double { get }
}

extension Actor {
    func canSee(_ target: Entity) -> Bool {
        let relativePos = target.position - position
        let relativeDistance = relativePos.length
        let relativeDir = relativePos / relativeDistance
        let relativeRad = acos(max(-1, min(1, direction.dot(relativeDir))))
        guard relativeRad <= fov / 2 else {
            return false
        }
        let rayCount = 10
        let plane = Vector(-relativeDir.y, relativeDir.x)
        let step = plane * (radius * 2 / Double(rayCount))
        var p = target.position - plane * radius
        outer: for _ in 0 ..< rayCount {
            let ray = Ray(origin: position, direction: (p - position).normalized())
            p += step

            let d = world.map.hitTest(ray)
            if d < relativeDistance {
                continue outer
            }
            for partition in world.partitions {
                if let d = partition.hitTest(ray), d < relativeDistance {
                    continue outer
                }
            }
            return true
        }
        return false
    }
}
