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
		super.init(texture: nil, color: NSColor.random, size: size)
		self.name = "brick"
		parentScene.addChild(self)
		self.position = CGPoint(x: width*CGFloat(xIndex)-parentScene.size.width/2+width/2,
								y: height*CGFloat(yIndex)-32)
		
		self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
		self.physicsBody?.friction = 0.0
		self.physicsBody?.restitution = 1.0
		self.physicsBody?.isDynamic = false
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	static func bricksInScene(_ scene: SKScene) -> [SKSpriteNode] {
		var results = [SKSpriteNode]()
		
		for node in scene.children {
			guard let spriteNode = node as? SKSpriteNode else { continue }
			if spriteNode.name == "brick" {
				results.append(spriteNode)
			}
		}
		
		return results
	}
}
