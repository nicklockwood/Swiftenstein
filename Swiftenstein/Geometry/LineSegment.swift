//
//  LineSegment.swift
//
//  Created by Nick Lockwood on 28/04/2019.
//  Copyright © 2019 Nick Lockwood. All rights reserved.
//

struct LineSegment {
    var start: Vector
    var end: Vector

    // Returns the distance along the ray at which the intersection occurs
    func intersection(with ray: Ray) -> Double? {
        let v1 = ray.origin - start
        let v2 = end - start
        let v3 = Vector(-ray.direction.y, ray.direction.x)

        let v2dotv3 = v2.dot(v3)
        guard abs(v2dotv3) > 0.00001 else {
            return nil // parallel
        }
        // distance along ray
        let t1 = v2.cross(v1) / v2dotv3
        guard t1 > 0 else {
            return nil
        }
        // normalized distance along partition
        let t2 = v1.dot(v3) / v2dotv3
        guard t2 >= 0, t2 <= 1 else {
            return nil
        }
        return t1
    }

    func intersection(with lineSegment: LineSegment) -> Vector? {
        let lineDelta = (lineSegment.end - lineSegment.start)
        let lineLength = lineDelta.length
        let lineDirection = lineDelta / lineLength
        let ray = Ray(origin: lineSegment.start, direction: lineDirection)
        guard let d = intersection(with: ray), d <= lineLength else {
            return nil
        }
        return ray.origin + ray.direction * d
    }
}
