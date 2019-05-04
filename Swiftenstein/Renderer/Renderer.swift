//
//  Renderer.swift
//
//  Created by Nick Lockwood on 17/04/2019.
//  Copyright © 2019 Nick Lockwood. All rights reserved.
//

import Foundation

// See: https://lodev.org/cgtutor/raycasting.html

extension World {
    func render(pos: Vector, dir: Vector, viewport size: Vector, eyeline: Double) -> Bitmap {
        assert(dir.isNormalized)

        let aspect = size.x / size.y
        let hscale = max(aspect, 1) / 2
        let vscale = min(1, aspect)

        let width = Int(size.x), height = Int(size.y)
        var zBuffer = [Double](repeating: 0, count: width)
        var framebuffer = Bitmap(width: width, height: height, color: .black)
        let plane = Vector(-dir.y, dir.x) * hscale
        for x in 0 ..< width {
            let cameraX = 2 * Double(x) / Double(width) - 1
            let rayDir = dir + plane * cameraX

            var tile = Vector(floor(pos.x), floor(pos.y))
            let delta = abs(1 / rayDir)
            let stepX, stepY: Double
            var sideX, sideY: Double

            // WALLS

            if rayDir.x < 0 {
                stepX = -1
                sideX = (pos.x - tile.x) * delta.x
            } else {
                stepX = 1
                sideX = (tile.x + 1 - pos.x) * delta.x
            }
            if rayDir.y < 0 {
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

            // perform DDA
            var doorFrameTexture: Int?
            var side: Side = .northSouth
            while case let mapTile = map[tile], mapTile.isFloorOrDoor {
                if case let .door(_, frameTexNum) = mapTile {
                    doorFrameTexture = frameTexNum
                } else {
                    doorFrameTexture = nil
                }
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

            var z: Double
            var wallX: Double
            switch side {
            case .northSouth:
                z = (tile.x - pos.x + (1 - stepX) / 2) / rayDir.x
                wallX = pos.y + z * rayDir.y
            case .eastWest:
                z = (tile.y - pos.y + (1 - stepY) / 2) / rayDir.y
                wallX = pos.x + z * rayDir.x
            }
            wallX -= floor(wallX) // TODO: is there a better way to do this? e.g. fmod?

            // flip texture
            if (side == .northSouth && rayDir.x < 0) || (side == .eastWest && rayDir.y > 0) {
                wallX = 1 - wallX
            }

            // PARTITIONS

            var hits = [(Partition, Double, Double)]()
            for partition in partitions {
                let v1 = pos - partition.start
                let v2 = partition.end - partition.start
                let v3 = Vector(-rayDir.y, rayDir.x)

                let v2dotv3 = v2.dot(v3)
                guard abs(v2dotv3) > 0.00001 else {
                    continue // parallel
                }
                // distance along ray
                let t1 = v2.cross(v1) / v2dotv3
                guard t1 > 0, t1 < z else {
                    continue
                }
                // normalized distance along partition
                let t2 = v1.dot(v3) / v2dotv3
                guard t2 >= 0, t2 <= 1 else {
                    continue
                }
                hits.append((partition, t2, t1))
            }
            hits.sort(by: { $0.2 < $1.2 })

            let texNum: Int
            if let (partition, t2, t1) = hits.first {
                z = t1
                texNum = partition.texture
                wallX = t2
                side = (partition.start.x == partition.end.x) ? .northSouth : .eastWest
            } else {
                texNum = doorFrameTexture ?? map[tile].wallTexture
            }

            let lineHeight = Double(height) * vscale / z
            let drawStart = -Int(lineHeight * (1 - eyeline)) + height / 2
            let drawEnd = Int(lineHeight * eyeline) + height / 2 + 1

            let texture = textures[texNum]
            let texX = Int(wallX * Double(texture.width))

            let yStep = Double(texture.height) / Double(drawEnd - drawStart)
            for y in max(drawStart, 0) ..< min(drawEnd, height) {
                let texY = Int(Double(y - drawStart) * yStep)
                var color = texture[texX, texY]

                if side == .eastWest {
                    color = color.with(brightness: 0.75)
                }

                framebuffer[x, y] = color
            }

            // set zbuffer to use later when drawing sprites
            zBuffer[x] = z

            // FLOOR & CEILING

            let mapPos = pos + rayDir * z

            let ceilTex = textures[6]
            for y in min(height, height - drawStart) ..< height {
                let currentDist = (1 - eyeline) * 2 * Double(height) * vscale / Double(2 * y - height)
                let weight = currentDist / z
                let floorPos = weight * mapPos + (1 - weight) * pos
                framebuffer[x, height - y] = ceilTex[floorPos]
            }

            let floorTex = textures[3]
            for y in min(height, drawEnd) ..< height {
                let currentDist = eyeline * 2 * Double(height) * vscale / Double(2 * y - height)
                let weight = currentDist / z
                let floorPos = weight * mapPos + (1 - weight) * pos
                framebuffer[x, y] = floorTex[floorPos]
            }
        }

        // SPRITES

        var spritesByDistance = [(Double, Sprite)]()
        for case let sprite as Sprite in entities {
            let distance = (pos - sprite.position).lengthSquared // sqrt not taken, unneeded
            spritesByDistance.append((distance, sprite))
        }
        spritesByDistance.sort(by: { $0.0 > $1.0 })

        for (_, sprite) in spritesByDistance {
            guard let texNum = sprite.texture else {
                continue
            }

            let spritePos = sprite.position - pos
            let invDet = 1.0 / (plane.x * dir.y - dir.x * plane.y)

            let transformX = invDet * (dir.y * spritePos.x - dir.x * spritePos.y)
            let transformY = invDet * (-plane.y * spritePos.x + plane.x * spritePos.y)
            guard transformY > 0 else {
                continue
            }

            let spriteScreenX = Int(Double(width / 2) * (1 + transformX / transformY))

            let spriteHeight = abs(Double(height) * vscale * sprite.scale / transformY)
            let drawStartY = -Int(spriteHeight * (1 - eyeline)) + height / 2
            let drawEndY = Int(spriteHeight * eyeline) + height / 2 + 1

            let spriteWidth = abs(Int(Double(height) * vscale * sprite.scale / transformY))
            let drawStartX = -spriteWidth / 2 + spriteScreenX
            let drawEndX = spriteWidth / 2 + spriteScreenX

            let texture = textures[texNum]
            let xStep = Double(texture.width) / Double(drawEndX - drawStartX)
            let yStep = Double(texture.height) / Double(drawEndY - drawStartY)
            for x in min(max(drawStartX, 0), width) ..< min(max(drawEndX, 0), width) {
                let texX = Int(Double(x - drawStartX) * xStep)
                guard transformY < zBuffer[x] else {
                    continue
                }
                for y in max(drawStartY, 0) ..< min(drawEndY, height) {
                    let texY = Int(Double(y - drawStartY) * yStep)
                    let color = texture[texX, texY]
                    if color.a == 255 {
                        // fast path for opaque pixels
                        framebuffer[x, y] = color
                    } else if color.a > 0 {
                        // blend sprite color into framebuffer
                        let c = framebuffer[x, y]
                        let destAlpha = 1 - Double(color.a) / 255
                        framebuffer[x, y] = Color(
                            r: UInt8(Double(c.r) * destAlpha) + color.r,
                            g: UInt8(Double(c.g) * destAlpha) + color.g,
                            b: UInt8(Double(c.b) * destAlpha) + color.b
                        )
                    }
                }
            }
        }
        return framebuffer
    }
}
