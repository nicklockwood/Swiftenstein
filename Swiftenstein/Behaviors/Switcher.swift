//
//  Switcher.swift
//
//  Created by Nick Lockwood on 07/05/2019.
//  Copyright © 2019 Nick Lockwood. All rights reserved.
//

protocol Switcher: Entity {
    func didActivateSwitch(_ switch: Switch)
}
