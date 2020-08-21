//
//  ViewController.swift
//  Breaklet 2020
//
//  Created by Peter Luo on 2020/5/28.
//  Copyright © 2020 Peter Luo. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

		// Load the SKScene from 'GameScene.sks'
		if let scene = SKScene(fileNamed: "GameScene") {
			// Set the scale mode to scale to fit the window
			scene.scaleMode = .aspectFill
			// Present the scene
			skView.presentScene(scene)
		}
		skView.ignoresSiblingOrder = true
    }
}

