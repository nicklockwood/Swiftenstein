//
//  ViewController.swift
//
//  Created by Nick Lockwood on 17/04/2019.
//  Copyright © 2019 Nick Lockwood. All rights reserved.
//

import UIKit

let simulationStep = 1.0 / 120
let maxFPS = 60.0

class ViewController: UIViewController {
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var fpsLabel: UILabel!

    var walkGesture: UIPanGestureRecognizer!
    var strafeGesture: UIPanGestureRecognizer!
    var fireGesture: FireGestureRecognizer!

    var world: World!
    var timer: Timer?
    var simulationTime: TimeInterval = 0
    var runningTime: TimeInterval = 0
    var gameOver = false
    var firePressed = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // walk gesture
        walkGesture = UIPanGestureRecognizer(target: self, action: #selector(walkGestureRecognized))
        walkGesture.delegate = self
        view.addGestureRecognizer(walkGesture)

        // fire gesture
        fireGesture = FireGestureRecognizer(target: self, action: #selector(fireGestureRecognized))
        fireGesture.delegate = self
        view.addGestureRecognizer(fireGesture)

        // disable bilinear filtering
        imageView.layer.magnificationFilter = .nearest

        // set up the game
        resetGame()

        // run the game loop
        var lastFrameTime = CFAbsoluteTimeGetCurrent()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / maxFPS, repeats: true) { _ in
            let dt = CFAbsoluteTimeGetCurrent() - lastFrameTime
            lastFrameTime += dt
            self.runningTime += min(1, dt)
            self.update()
            self.fpsLabel.text = "\(Int(1 / dt))"
        }
    }

    func update() {
        let delta = walkGesture.translation(in: view)
        let length = sqrt(delta.x * delta.x + delta.y * delta.y)
        let f = length > 0 ? min(1, length / 50) / length : 0

        let turn = Double(delta.x * f) * turnSpeed
        let walk = Double(-delta.y * f) * walkSpeed

        while simulationTime < runningTime {
            simulationTime += simulationStep

            // update player orientation (allowed even after death)
            world.player.rotate(turn * simulationStep)

            if !world.player.isDead {
                // update player position
                world.player.advance(walk * simulationStep)

                // handle firing
                if firePressed || fireGesture.isAutofireEngaged {
                    firePressed = false
                    world.player.fire()
                }
            }

            world.update(dt: simulationStep)
        }

        firePressed = false

        let aspect = Double(imageView.bounds.width / imageView.bounds.height)
        let viewport = aspect > 1 ?
            Vector(resolution * aspect, resolution) :
            Vector(resolution, resolution / aspect)

        imageView.image = UIImage(bitmap: world.render(
            pos: world.player.position,
            dir: world.player.direction,
            viewport: viewport,
            eyeline: world.player.eyeline
        ))
    }

    func resetGame() {
        world = makeWorld(delegate: self)

        // Start simulation
        runningTime = 0
        simulationTime = 0
        fireGesture.timeThreshold = 0.15
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    @objc func fireGestureRecognized() {
        if gameOver {
            gameOver = false
            resetGame()
            view.backgroundColor = .black
            imageView.alpha = 1
            return
        }
        firePressed = true
    }

    @objc func walkGestureRecognized(_ gesture: UIPanGestureRecognizer) {
        if gesture.state == .ended || gesture.state == .cancelled {
            gesture.setTranslation(.zero, in: view)
        }
    }

    @objc func strafeGestureRecognized(_ gesture: UIPanGestureRecognizer) {
        if gesture.state == .ended || gesture.state == .cancelled {
            gesture.setTranslation(.zero, in: view)
        }
    }

    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension ViewController: PlayerDelegate {
    func playerWasHurt(_: Player) {
        view.backgroundColor = .red
        imageView.alpha = 0.5
        UIView.animate(withDuration: 0.5, animations: {
            self.imageView.alpha = 1
        }, completion: { finished in
            if finished {
                self.view.backgroundColor = .black
            }
        })
    }

    func playerWasKilled(_: Player) {
        view.backgroundColor = .red
        imageView.alpha = 0.5
        UIView.animate(withDuration: 0.5, animations: {
            self.imageView.alpha = 1
        }, completion: { _ in
            self.view.backgroundColor = .red
            UIView.animate(withDuration: 2, animations: {
                self.imageView.alpha = 0
            }, completion: { _ in
                self.gameOver = true
                self.fireGesture.timeThreshold = 1
            })
        })
    }

    func playerPoweredUp(_: Player) {
        view.backgroundColor = .green
        imageView.alpha = 0.5
        UIView.animate(withDuration: 0.5, animations: {
            self.imageView.alpha = 1
        }, completion: { finished in
            if finished {
                self.view.backgroundColor = .black
            }
        })
    }
}
