//
//  GameScene.swift
//  Breaklet 2020
//
//  Created by Peter Luo on 2020/5/28.
//  Copyright © 2020 Peter Luo. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
	
	// nodes
	private lazy var scoreLabel = SKLabelNode(text: "Score: \(score)")
	private lazy var titleLabel = SKLabelNode(text: "Press SPACE to start game")
	private lazy var paddle     = PaddleSpriteNode(parentScene: self)
	private lazy var ball       = BallSpriteNode(parentScene: self)
    private lazy var scoreBoard = ScoreBoardNode(parentScene: self)
	// bitmasks
	private let paddleCatagory : UInt32 = 0x1 << 0
	private let ballCatagory   : UInt32 = 0x1 << 1
	private let blockCatagory  : UInt32 = 0x1 << 2
	// game status
	private(set) var gameStatus = GameStatus.new {
		didSet {
			switch gameStatus {
			case .gameOver:
				for block in BlockSpriteNode.blocksInScene(self) {
					block.removeFromParent()
				}
				generateBlocks()
				ball.position = CGPoint(x: 0, y: -256)
				ball.color = .white
				titleLabel.isHidden = false
				titleLabel.text = "Game Over"
                updateScoreBoardIfNeeded()
			case .running:
				score = 0
				ball.physicsBody?.velocity = CGVector(dx: 40, dy: 200)
				titleLabel.isHidden = true
			case .new:
				titleLabel.isHidden = false
				titleLabel.text = "Press SPACE to start game"
			}
		}
	}
	// score
	private var score = 0 {
		didSet {
			scoreLabel.text = "Score: \(score)"
		}
	}
	
	override func didMove(to view: SKView) {
		super.didMove(to: view)
		
		self.backgroundColor = .black
		
		// Physics world
		self.physicsWorld.contactDelegate = self
		self.physicsWorld.gravity = .zero
		
		// Bitmasks
		ball.physicsBody?.categoryBitMask = ballCatagory
		ball.physicsBody?.contactTestBitMask = blockCatagory
		paddle.physicsBody?.categoryBitMask = paddleCatagory
		paddle.physicsBody?.contactTestBitMask = ballCatagory
		
		// text labels
		let fontName = NSFont.systemFont(ofSize: 0, weight: .medium).fontName
		scoreLabel.position.x = -self.frame.width/2+150
		scoreLabel.position.y = self.frame.height/2-26
		scoreLabel.fontSize = 24
		scoreLabel.fontName = fontName
		self.addChild(scoreLabel)
		titleLabel.position.y -= 128
		titleLabel.fontName = fontName
		self.addChild(titleLabel)
		
		// generateBlocks on game start
		generateBlocks()
        
        // listen to scoreboard toggle
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(toggleScoreBoard),
            name: NSNotification.Name(rawValue: "Toggle Score Board"),
            object: nil
        )
	}
	
	override func update(_ currentTime: TimeInterval) {
		// update nodes
		paddle.update()
		ball.update()
		
		// ball touches bottom of the screen...
		if ball.frame.minY <= -self.frame.height/2 {
			gameStatus = .gameOver
		}
	}
	
	override func keyDown(with event: NSEvent) {
		switch event.keyCode {
		case 49:
			// space key pressed
			if gameStatus == .new || gameStatus == .gameOver {
				gameStatus = .running
			}
		default:
			break
		}
	}
	
	private func generateBlocks() {
		// add the blocks
		for x in 0..<10 {
			for y in 0..<10 {
				let _ = BlockSpriteNode(xIndex: x, yIndex: y, parentScene: self)
			}
		}
		// set bitmasks
		for brick in BlockSpriteNode.blocksInScene(self) {
			brick.physicsBody?.categoryBitMask = blockCatagory
			brick.physicsBody?.collisionBitMask = ballCatagory
		}
	}
    
    private func updateScoreBoardIfNeeded() {
        let scores = ScoreBoard.shared.scores
        let lastScore = (scores.last?.value) ?? 0
        guard (scores.count < 10) || (lastScore <= score) else {
            return
        }
        let playerName: String = {
            let alert = NSAlert()
            alert.addButton(withTitle: "OK")      // 1st button
            alert.addButton(withTitle: "Cancel")  // 2nd button
            alert.messageText = "You have reached the score board"
            alert.informativeText = "Please enter the player name"

            let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
            textField.placeholderString = "Player name..."

            alert.accessoryView = textField
            let response: NSApplication.ModalResponse = alert.runModal()

            if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
                return textField.stringValue
            } else {
                return ""
            }
        }()
        let score = Score(name: playerName, value: self.score)
        ScoreBoard.shared.insert(score)
    }
    
    private func showScoreBoard() {
        scoreBoard.updateData()
        scoreBoard.isHidden = false
        self.physicsWorld.speed = 0
    }
    
    private func hideScoreBoard() {
        scoreBoard.isHidden = true
        self.physicsWorld.speed = 1
    }
    
    @objc private func toggleScoreBoard() {
        if scoreBoard.isHidden {
            showScoreBoard()
        } else {
            hideScoreBoard()
        }
    }
	
	func didBegin(_ contact: SKPhysicsContact) {
		// first&second body
		var firstBody: SKPhysicsBody
		var secondBody: SKPhysicsBody
		if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
			firstBody = contact.bodyA
			secondBody = contact.bodyB
		} else {
			firstBody = contact.bodyB
			secondBody = contact.bodyA
		}
		
		// if the ball hits the brick...
		if firstBody.node?.name == "ball" && secondBody.node?.name == "brick" {
			// destory the ball
			let block = secondBody.node as! BlockSpriteNode
			block.destory()
			// set the ball to the color of the block
			ball.color = block.color
			// add 1 point
			score += 1
			
			// accelerate the ball
			var dy : CGFloat = CGFloat(200 + score*3)
			if dy > 2000 {
				dy = 2000
			}
			if ball.physicsBody!.velocity.dy >= 0 {
				ball.physicsBody!.velocity.dy = dy
			} else {
				ball.physicsBody!.velocity.dy = -dy
			}
		}
		
		// if the ball hits the paddle
		if firstBody.node?.name == "paddle" && secondBody.node?.name == "ball" {
			// set x speed according to where the ball hit on
			let dx = (ball.frame.midX - paddle.frame.midX)*4
			ball.physicsBody?.velocity.dx = dx
			
			// re-generate blocks if needed
			if BlockSpriteNode.blocksInScene(self).isEmpty {
				generateBlocks()
			}
		}
	}
}
