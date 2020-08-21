//
//  PaddleSpriteNode.swift
//  Breaklet 2020
//
//  Created by Peter Luo on 2020/5/28.
//  Copyright © 2020 Peter Luo. All rights reserved.
//

import SpriteKit

class PaddleSpriteNode: SKSpriteNode {
	init(parentScene: SKScene) {
		let size = CGSize(width: 128, height: 16)
		super.init(texture: nil, color: NSColor.white, size: size)
		self.position = CGPoint(x: self.position.x, y: -parentScene.size.height/2+32)
		
		parentScene.addChild(self)
		
		// Physics body
		self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
		self.physicsBody!.isDynamic = false
		self.physicsBody!.allowsRotation = false
		self.physicsBody!.friction = 0.0
		self.physicsBody!.restitution = 1.0
		
		self.name = "paddle"
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func update() {
		let screenWidth = NSScreen.main!.frame.width
		moveTo(x: NSEvent.mouseLocation.x - screenWidth/2)
	}
	
	func moveTo(x: CGFloat) {
		guard let gameScene = self.scene as? GameScene else { return }
		if gameScene.gameStatus == .running {
			self.position.x = x
		}
	}
}
