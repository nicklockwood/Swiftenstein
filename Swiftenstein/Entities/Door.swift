//
//  Door.swift
//
//  Created by Nick Lockwood on 28/04/2019.
//  Copyright © 2019 Nick Lockwood. All rights reserved.
//

import Foundation

enum DoorState {
    case closed
    case opening
    case closing
    case open
}

class Door: Trigger {
    let radius = 0.0
    private let partition: Partition
    unowned let world: World

    let openingTime = 1.0
    let closeDelay = 5.0

    let position: Vector
    var state: DoorState = .closed
    var startTime: TimeInterval = 0

    init(world: World, texture: Int, x: Int, y: Int) {
        self.world = world
        position = Vector(Double(x), Double(y))
        partition = Partition(texture: texture, start: Vector(0, 0), end: Vector(0, 0))
        updatePartition(0)
        world.partitions.append(partition)
    }

    private func updatePartition(_ progress: Double) {
        let start: Vector, end: Vector
        if case .floor = world.map[Int(position.x) - 1, Int(position.y)] {
            start = position + Vector(0.5, progress)
            end = position + Vector(0.5, 1 + progress)
        } else {
            start = position + Vector(progress, 0.5)
            end = position + Vector(1 + progress, 0.5)
        }
        partition.start = start
        partition.end = end
    }

    func isTouching(_ entity: Entity) -> Bool {
        return entity.intersection(with: partition) != nil
    }

    func activate(with _: Entity) {
        if state == .closed {
            state = .opening
            startTime = world.time
        }
    }

    func update(dt _: TimeInterval) {
        switch state {
        case .closed:
            break
        case .open:
            if world.time - startTime > closeDelay {
                state = .closing
                startTime = world.time
            }
        case .opening:
            let progress = min(1, (world.time - startTime) / openingTime)
            updatePartition(progress)
            if progress >= 1 {
                state = .open
                startTime = world.time
            }
        case .closing:
            let progress = min(1, (world.time - startTime) / openingTime)
            updatePartition(1 - progress)
            if progress >= 1 {
                state = .closed
            }
        }
    }
}
