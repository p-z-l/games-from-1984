//
//  BallSpriteNode.swift
//  Breaklet 2020
//
//  Created by Peter Luo on 2020/5/28.
//  Copyright © 2020 Peter Luo. All rights reserved.
//

import SpriteKit

class BallSpriteNode: SKSpriteNode {
	
	private let particleNode = SKEmitterNode(fileNamed: "BallTrail.sks")!
	
	init(parentScene: SKScene) {
		let size = CGSize(width: 16, height: 16)
		super.init(texture: nil, color: NSColor.white, size: size)
		self.alpha = 0.0
		self.position.y -= 256
		parentScene.addChild(self)
		
		self.name = "ball"
		
		self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
		self.physicsBody!.allowsRotation = false
		self.physicsBody!.usesPreciseCollisionDetection = true
		self.physicsBody!.linearDamping = 0.0
		
		particleNode.particleColorSequence = nil
		particleNode.particleColorBlendFactor = 1.0
		self.scene!.addChild(particleNode)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func update() {
		// bounce back if hit the screen edge
		if self.frame.maxY >= self.scene!.frame.height/2-32 {
			self.physicsBody!.velocity.dy = -abs(self.physicsBody!.velocity.dy)
		}
		if self.frame.minX <= -self.scene!.frame.width/2 {
			self.physicsBody!.velocity.dx = abs(self.physicsBody!.velocity.dx)
		}
		if self.frame.maxX >= self.scene!.frame.width/2 {
			self.physicsBody!.velocity.dx = -abs(self.physicsBody!.velocity.dx)
		}
		
		// update the particles
		particleNode.particleColor = self.color
		particleNode.position = self.position
		
		// if too vertical...
		if self.physicsBody!.velocity.dx == 0 {
			self.physicsBody!.velocity.dx = 200
		}
		
		// do not move if game is paused
		guard let gameScene = self.scene as? GameScene else { return }
		if gameScene.gameStatus == .running {
			self.physicsBody!.isResting = false
		} else {
			self.physicsBody!.isResting = true
		}
	}
}
