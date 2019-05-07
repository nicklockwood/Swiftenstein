//
//  Map.swift
//
//  Created by Nick Lockwood on 28/04/2019.
//  Copyright © 2019 Nick Lockwood. All rights reserved.
//

import Foundation

enum MapTile {
    case floor
    case wall(Int)
    case pushWall(Int)
    case door(Int, frame: Int)
    case elevator(Int)
    case `switch`(Int, alt: Int)

    var wallTexture: Int {
        switch self {
        case let .wall(texNum),
             let .pushWall(texNum),
             let .door(_, frame: texNum),
             let .elevator(texNum),
             let .switch(texNum, _):
            return texNum
        default:
            return -1
        }
    }

    var isFloorOrDoor: Bool {
        switch self {
        case .floor, .door, .elevator:
            return true
        case .wall, .pushWall, .switch:
            return false
        }
    }
}

struct Map {
    let width: Int
    let height: Int
    var tiles: [MapTile]

    subscript(x: Int, y: Int) -> MapTile {
        get {
            if x < 0 || x >= width || y < 0 || y >= width {
                return .wall(0) // TODO: sky
            }
            return tiles[y * width + x]
        }
        set {
            assert((0 ..< width).contains(x) && (0 ..< height).contains(y))
            tiles[y * width + x] = newValue
        }
    }

    subscript(v: Vector) -> MapTile {
        return self[Int(v.x), Int(v.y)]
    }

    init(width: Int, tiles: [MapTile]) {
        self.width = width
        self.tiles = tiles
        height = tiles.count / width
    }

    // See: https://lodev.org/cgtutor/raycasting.html

    func hitTest(_ ray: Ray) -> Double {
        let (pos, dir) = (ray.origin, ray.direction)
        var tile = floor(pos)
        let delta = abs(1 / dir)
        let stepX, stepY: Double
        var sideX, sideY: Double

        if dir.x < 0 {
            stepX = -1
            sideX = (pos.x - tile.x) * delta.x
        } else {
            stepX = 1
            sideX = (tile.x + 1 - pos.x) * delta.x
        }
        if dir.y < 0 {
            stepY = -1
            sideY = (pos.y - tile.y) * delta.y
        } else {
            stepY = 1
            sideY = (tile.y + 1 - pos.y) * delta.y
        }

        enum Side {
            case northSouth
            case eastWest
        }

        var side: Side = .northSouth
        while self[tile].isFloorOrDoor {
            if sideX < sideY {
                sideX += delta.x
                tile.x += stepX
                side = .northSouth
            } else {
                sideY += delta.y
                tile.y += stepY
                side = .eastWest
            }
        }

        switch side {
        case .northSouth:
            return (tile.x - pos.x + (1 - stepX) / 2) / dir.x
        case .eastWest:
            return (tile.y - pos.y + (1 - stepY) / 2) / dir.y
        }
    }
}
