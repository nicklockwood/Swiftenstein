//
//  Entity.swift
//
//  Created by Nick Lockwood on 28/04/2019.
//  Copyright © 2019 Nick Lockwood. All rights reserved.
//

import Foundation

protocol Entity: AnyObject {
    var position: Vector { get }
    var radius: Double { get }
    var isSolid: Bool { get }
    var world: World { get }

    func update(dt: TimeInterval)
}

extension Entity {
    var isSolid: Bool { return radius > 0 }

    func update(dt _: TimeInterval) {}

    func hitTest(_ ray: Ray) -> Double? {
        return Circle(center: position, radius: radius).intersection(with: ray)
    }

    // TODO: take direction into account
    func intersection(with entity: Entity) -> Vector? {
        let circle = Circle(center: entity.position, radius: entity.radius)
        return intersection(with: circle)
    }

    func intersection(with circle: Circle) -> Vector? {
        return Circle(center: position, radius: radius).intersection(with: circle)
    }

    func intersection(with partition: Partition) -> Vector? {
        let lineSegment = LineSegment(start: partition.start, end: partition.end)
        return Circle(center: position, radius: radius).intersection(with: lineSegment)
    }

    func intersection(withTileAt x: Int, _ y: Int) -> Vector? {
        let origin = Vector(Double(x), Double(y))
        let rect = Rect(min: origin, max: origin + Vector(1, 1))
        return Circle(center: position, radius: radius).intersection(with: rect)
    }
}
