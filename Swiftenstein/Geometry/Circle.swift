//
//  Circle.swift
//
//  Created by Nick Lockwood on 28/04/2019.
//  Copyright © 2019 Nick Lockwood. All rights reserved.
//

import Foundation

struct Circle {
    var center: Vector
    var radius: Double

    func intersection(with ray: Ray) -> Double? {
        let hypotenuse = center - ray.origin
        let hypotenuseLength = hypotenuse.length
        let targetDirection = hypotenuse / hypotenuseLength
        let cosAngle = targetDirection.dot(ray.direction)
        if cosAngle < 0 {
            return nil
        }
        let adjacentLength = cosAngle * hypotenuseLength
        let adjacent = ray.direction * adjacentLength
        let opposite = hypotenuse - adjacent
        let oppositeLength = opposite.length
        guard oppositeLength < radius else {
            return nil
        }
        let d = sqrt(radius * radius - oppositeLength * oppositeLength)
        return adjacentLength - d
    }

    func intersection(with circle: Circle) -> Vector? {
        let relativePosition = circle.center - center
        let distance = relativePosition.length
        let overlap = distance - radius - circle.radius
        if overlap < 0 {
            return relativePosition / distance * -overlap
        }
        return nil
    }

    func intersection(with lineSegment: LineSegment) -> Vector? {
        var relativePosition = center - lineSegment.start
        let startEnd = lineSegment.end - lineSegment.start
        let lengthSquared = startEnd.lengthSquared
        if lengthSquared > 0 {
            let cosa = relativePosition.dot(startEnd)
            let t = max(0, min(1, cosa / lengthSquared))
            let nearestPoint = lineSegment.start + startEnd * t
            relativePosition = nearestPoint - center
        }
        let distance = relativePosition.length
        let overlap = distance - radius
        if overlap < 0 {
            return relativePosition / distance * -overlap
        }
        return nil
    }

    func intersection(with rect: Rect) -> Vector? {
        let (min, max) = (rect.min, rect.max)
        let left = center.x + radius - min.x
        if left <= 0 {
            return nil
        }
        let up = center.y + radius - min.y
        if up <= 0 {
            return nil
        }
        let right = -(center.x - radius - max.x)
        if right < 0 {
            return nil
        }
        let down = -(center.y - radius - max.y)
        if down < 0 {
            return nil
        }
        if up < down {
            if up < left {
                return up < right ? Vector(0, up) : Vector(-right, 0)
            }
        } else if down < left {
            return down < right ? Vector(0, -down) : Vector(-right, 0)
        }
        return left < right ? Vector(left, 0) : Vector(-right, 0)
    }
}
