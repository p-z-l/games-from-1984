//
//  GameScene.swift
//  Asteroids
//
//  Created by Peter Luo on 2020/8/22.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Properties
    private lazy var spaceShip = SKSpriteNode()
    private lazy var spaceShipDirection : CGFloat = 0 { // in degrees 0~360
        didSet {
            spaceShipUpdateDirection()
        }
    }
    private var asteroids: [SKSpriteNode] {
        return self.children.filter { $0.name == "asteroid" } as! [SKSpriteNode]
    }
    
    // MARK: - Life cycle
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        initializeScene()
        initializeSpaceShip()
        spaceShipUpdateDirection()
        
        for _ in 0...3 {
            generateRandomAsteroid(sizeClass: .large)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        keepNodesInsideScene()
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 49: // space
            spaceShipAccelerate()
        case 0: // a
            spaceShipLeft()
        case 2: // d
            spaceShipRight()
        default:
            break
        }
    }
    
    // MARK: - Private methods
    
    private func initializeScene() {
        self.backgroundColor = .black
        self.physicsWorld.gravity = .zero
        self.physicsWorld.contactDelegate = self
    }
    
    private func initializeSpaceShip() {
        spaceShip.name = "spaceShip"
        spaceShip.size = CGSize(width: 24, height: 24)
        spaceShip.texture = SKTexture(imageNamed: "SpaceShip")
        spaceShip.physicsBody = SKPhysicsBody(texture: spaceShip.texture!, size: spaceShip.size)
        spaceShip.physicsBody?.mass = 0.01
        spaceShip.physicsBody?.allowsRotation = false
        self.addChild(spaceShip)
    }
    
    private func spaceShipAccelerate() {
        let acceleration = CGVector(direction: spaceShipDirection, magnitude: 5.0)
        spaceShip.physicsBody?.applyForce(acceleration)
    }
    
    private func spaceShipLeft() {
        spaceShipDirection -= 10
    }
    
    private func spaceShipRight() {
        spaceShipDirection += 10
    }
    
    private func spaceShipUpdateDirection() {
        spaceShip.zRotation = -spaceShipDirection * .pi / 180
    }
    
    private func keepNodesInsideScene() {
        for child in self.children {
            if child.position.x >= self.size.width/2 {
                child.position.x = -self.size.width/2
            } else if child.position.x <= -self.size.width/2 {
                child.position.x = self.size.width/2
            }
            if child.position.y >= self.size.width/2 {
                child.position.y = -self.size.width/2
            } else if child.position.y <= -self.size.width/2 {
                child.position.y = self.size.width/2
            }
        }
    }
    
    private func generateRandomAsteroid(sizeClass: AsteroidClass) {
        let asteroidNode = SKSpriteNode()
        asteroidNode.color = .white
        asteroidNode.size = sizeClass.cgsize
        asteroidNode.texture = sizeClass.sktexture
        asteroidNode.physicsBody = SKPhysicsBody(rectangleOf: asteroidNode.size)
        asteroidNode.physicsBody?.mass = 0.1
        asteroidNode.physicsBody?.velocity = {
            let magnitude = CGFloat.random(in: 20...40)
            let dx = magnitude-CGFloat.random(in: 0...magnitude)
            let dy = magnitude-dx
            print(dx,dy)
            return CGVector(dx: dx, dy: dy)
            }()
        asteroidNode.physicsBody?.angularVelocity = .random(in: -2...2)
        asteroidNode.name = "asteroid"
        asteroidNode.position = CGPoint(
            x: .random(in: -self.size.width/2...self.size.width/2),
            y: .random(in: -self.size.height/2...self.size.height/2)
        )
        self.addChild(asteroidNode)
    }
    
}
