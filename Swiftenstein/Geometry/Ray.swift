//
//  Ray.swift
//
//  Created by Nick Lockwood on 28/04/2019.
//  Copyright © 2019 Nick Lockwood. All rights reserved.
//

import Foundation

struct Ray {
    var origin: Vector
    var direction: Vector {
        didSet { assert(direction.isNormalized) }
    }

    init(origin: Vector, direction: Vector) {
        assert(direction.isNormalized)
        self.origin = origin
        self.direction = direction
    }
}
