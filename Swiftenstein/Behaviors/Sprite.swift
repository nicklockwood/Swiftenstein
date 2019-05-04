//
//  Sprite.swift
//
//  Created by Nick Lockwood on 28/04/2019.
//  Copyright © 2019 Nick Lockwood. All rights reserved.
//

protocol Sprite {
    var position: Vector { get }
    var texture: Int? { get }
    var scale: Double { get }
}

extension Sprite {
    var scale: Double { return 1 }
}
