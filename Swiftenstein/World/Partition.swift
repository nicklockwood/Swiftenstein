//
//  Partition.swift
//
//  Created by Nick Lockwood on 28/04/2019.
//  Copyright © 2019 Nick Lockwood. All rights reserved.
//

class Partition {
    var texture: Int
    var start: Vector
    var end: Vector

    init(texture: Int, start: Vector, end: Vector) {
        self.texture = texture
        self.start = start
        self.end = end
    }

    func hitTest(_ ray: Ray) -> Double? {
        return LineSegment(start: start, end: end).intersection(with: ray)
    }
}
