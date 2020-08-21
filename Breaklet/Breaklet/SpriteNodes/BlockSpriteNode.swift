//
//  BlockSpriteNode.swift
//  Breaklet 2020
//
//  Created by Peter Luo on 2020/5/28.
//  Copyright © 2020 Peter Luo. All rights reserved.
//

import SpriteKit
import Cocoa

class BlockSpriteNode: SKSpriteNode {
	init(xIndex: Int, yIndex: Int, parentScene: SKScene) {
		let width = parentScene.size.width/10
		let height = parentScene.size.height/20
		let size = CGSize(width: width, height: height)
		let color = NSColor.blockColors[(xIndex+yIndex) % NSColor.blockColors.count]
		super.init(texture: nil, color: color, size: size)
		self.position = CGPoint(x: width*CGFloat(xIndex)-parentScene.size.width/2+width/2,
								y: height*CGFloat(yIndex)+height/2 - 32)
		
		parentScene.addChild(self)
		
		// physics body
		self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
		self.physicsBody!.friction = 0.0
		self.physicsBody!.restitution = 1.0
		self.physicsBody!.isDynamic = false
		self.physicsBody!.usesPreciseCollisionDetection = true
		
		self.name = "brick"
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	static func blocksInScene(_ scene: SKScene) -> [SKSpriteNode] {
		var results = [SKSpriteNode]()
		
		for node in scene.children {
			guard let spriteNode = node as? SKSpriteNode else { continue }
			if spriteNode.name == "brick" {
				results.append(spriteNode)
			}
		}
		
		return results
	}
	
	func destory() {
		let particles = SKEmitterNode(fileNamed: "BreakBlockParticles.sks")!
		particles.particleColorSequence = nil
		particles.particleColorBlendFactor = 1.0
		particles.particleColor = self.color
		particles.position = self.position
		particles.zPosition = 10
		self.scene?.addChild(particles)
		particles.run(SKAction.sequence([SKAction.wait(forDuration: 1.0),
										 SKAction.removeFromParent()]))
		self.removeFromParent()
	}
}
