//
//  Trigger.swift
//
//  Created by Nick Lockwood on 28/04/2019.
//  Copyright © 2019 Nick Lockwood. All rights reserved.
//

protocol Trigger: Entity {
    func isTouching(_ entity: Entity) -> Bool
    func activate(with entity: Entity)
}

extension Trigger {
    func isTouching(_ entity: Entity) -> Bool {
        return intersection(with: entity) != nil
    }
}
