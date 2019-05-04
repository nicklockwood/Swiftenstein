//
//  Geometry.swift
//
//  Created by Nick Lockwood on 28/04/2019.
//  Copyright © 2019 Nick Lockwood. All rights reserved.
//

import Foundation

struct Vector: Equatable {
    var x: Double
    var y: Double

    var lengthSquared: Double {
        return x * x + y * y
    }

    var length: Double {
        return sqrt(lengthSquared)
    }

    func normalized() -> Vector {
        return self / length
    }

    var isNormalized: Bool {
        return abs(lengthSquared - 1) < 0.001
    }

    init(_ x: Double, _ y: Double) {
        self.x = x
        self.y = y
    }

    func rotated(by r: Double) -> Vector {
        return Vector(cos(r) * x - sin(r) * y, sin(r) * x + cos(r) * y)
    }

    func dot(_ rhs: Vector) -> Double {
        return x * rhs.x + y * rhs.y
    }

    func cross(_ rhs: Vector) -> Double {
        return x * rhs.y - y * rhs.x
    }

    static func + (lhs: Vector, rhs: Vector) -> Vector {
        return Vector(lhs.x + rhs.x, lhs.y + rhs.y)
    }

    static func - (lhs: Vector, rhs: Vector) -> Vector {
        return Vector(lhs.x - rhs.x, lhs.y - rhs.y)
    }

    static func * (lhs: Vector, rhs: Double) -> Vector {
        return Vector(lhs.x * rhs, lhs.y * rhs)
    }

    static func * (lhs: Double, rhs: Vector) -> Vector {
        return Vector(lhs * rhs.x, lhs * rhs.y)
    }

    static func / (lhs: Vector, rhs: Double) -> Vector {
        return Vector(lhs.x / rhs, lhs.y / rhs)
    }

    static func / (lhs: Double, rhs: Vector) -> Vector {
        return Vector(lhs / rhs.x, lhs / rhs.y)
    }

    static func += (lhs: inout Vector, rhs: Vector) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }

    static func -= (lhs: inout Vector, rhs: Vector) {
        lhs.x -= rhs.x
        lhs.y -= rhs.y
    }

    static func *= (lhs: inout Vector, rhs: Double) {
        lhs.x *= rhs
        lhs.y *= rhs
    }

    static func /= (lhs: inout Vector, rhs: Double) {
        lhs.x /= rhs
        lhs.y /= rhs
    }
}

func abs(_ v: Vector) -> Vector {
    return Vector(abs(v.x), abs(v.y))
}

func floor(_ v: Vector) -> Vector {
    return Vector(floor(v.x), floor(v.y))
}
