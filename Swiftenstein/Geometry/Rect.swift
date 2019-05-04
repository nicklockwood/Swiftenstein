//
//  Rect.swift
//
//  Created by Nick Lockwood on 28/04/2019.
//  Copyright © 2019 Nick Lockwood. All rights reserved.
//

struct Rect {
    var min: Vector
    var max: Vector

    init(min: Vector, max: Vector) {
        assert(max.x >= min.x && max.y >= min.y)
        self.min = min
        self.max = max
    }
}
