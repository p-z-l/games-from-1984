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
    
    // objects
    private lazy var spaceShip = SKSpriteNode()
    private lazy var spaceShipDirection : CGFloat = 0 { // in degrees 0~360
        didSet {
            spaceShipUpdateDirection()
        }
    }
    private var asteroids: [SKSpriteNode] {
        return self.children.filter { $0.name == "asteroid" } as! [AsteroidNode]
    }
    private var bullets: [SKSpriteNode] {
        return self.children.filter { $0.name == "bullet" } as! [SKSpriteNode]
    }
    private lazy var levelLabel = self.childNode(withName: "LevelField") as! SKLabelNode
    // spaceship motions
    private var isAccelerating      = false
    private var isFiring            = false
    private var isTurningLeft       = false
    private var isTurningRight      = false
    private var framesSinceLastFire = 0
    private let spaceShipFireTimeInterval = 20
    // bitmasks
    private let spaceShipCatagory : UInt32 = 0x1 << 0
    private let asteroidsCatagory : UInt32 = 0x1 << 1
    private let bulletsCatagory   : UInt32 = 0x1 << 2
    // game & levels
    private lazy var gameLevel : Int = 0 {
        didSet {
            updateLevelLabel()
        }
    }
    
    // MARK: - Life cycle
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        initializeScene()
        initializeSpaceShip()
        initializeLevelLabel()
        
        spaceShipUpdateDirection()
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        keepNodesInsideScene()
        updateSpaceShipMotion()
        
        levelUpIfNeeded()
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.characters {
        case " ": // space
            isAccelerating = true
        case "a": // a
            isTurningLeft = true
        case "d": // d
            isTurningRight = true
        case "j": // j
            isFiring = true
        default:
            break
        }
        #if DEBUG // debug keys
        switch event.characters {
        case ",":
            self.physicsWorld.speed -= 0.5
        case ".":
            self.physicsWorld.speed += 0.5
        case "/":
            self.physicsWorld.speed = 1
        case "x":
            for asteroid in asteroids {
                asteroid.removeFromParent()
            }
        default:
            break
        }
        #endif
    }
    
    override func keyUp(with event: NSEvent) {
        switch event.characters {
        case " ":
            isAccelerating = false
        case "a": // a
            isTurningLeft = false
        case "d": // d
            isTurningRight = false
        case "j": // j
            isFiring = false
        default:
            break
        }
    }
    
    // MARK: - SKPhysicsContactDelegate
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // if a bullet hits an asteroid...
        if firstBody.node?.name == "bullet" && secondBody.node?.name == "asteroid" {
            splitAsteroid(asteroid: secondBody.node as! AsteroidNode, bulletVelocity: firstBody.velocity)
            firstBody.node?.removeFromParent()
            secondBody.node?.removeFromParent()
        }
        
        // if the space ship hits an asteroid...
        if firstBody.node?.name == "spaceShip" && secondBody.node?.name == "asteroid" {
            NSApp.terminate(self)
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
        spaceShip.physicsBody?.categoryBitMask = spaceShipCatagory
        spaceShip.physicsBody?.collisionBitMask = asteroidsCatagory
        spaceShip.physicsBody?.contactTestBitMask = asteroidsCatagory
        self.addChild(spaceShip)
    }
    
    private func initializeLevelLabel() {
        levelLabel.fontName = NSFont.systemFont(ofSize: 0).fontName
        levelLabel.fontSize = 24
    }
    
    private func updateLevelLabel() {
        levelLabel.text = "Level: \(gameLevel)"
    }
    
    private func levelUp() {
        gameLevel += 1
        
        for _ in 0...gameLevel {
            generateRandomAsteroid(sizeClass: .large)
        }
    }
    
    private func levelUpIfNeeded() {
        if asteroids.isEmpty {
            levelUp()
        }
    }
    
    private func updateSpaceShipMotion() {
        if isAccelerating {
            spaceShipAccelerate()
        }
        if isTurningRight {
            spaceShipRight()
        }
        if isTurningLeft {
            spaceShipLeft()
        }
        if isFiring && framesSinceLastFire >= spaceShipFireTimeInterval {
            spaceShipFireBullet()
            framesSinceLastFire = 0
        } else {
            framesSinceLastFire += 1
        }
    }
    
    private func spaceShipAccelerate() {
        let acceleration = CGVector(direction: spaceShipDirection, magnitude: 5.0)
        spaceShip.physicsBody?.applyForce(acceleration)
    }
    
    private func spaceShipLeft() {
        spaceShipDirection -= 3
    }
    
    private func spaceShipRight() {
        spaceShipDirection += 3
    }
    
    private func spaceShipFireBullet() {
        let bulletNode = SKSpriteNode()
        bulletNode.color = .white
        bulletNode.size = CGSize(width: 2, height: 2)
        bulletNode.physicsBody = SKPhysicsBody(rectangleOf: bulletNode.size)
        bulletNode.physicsBody?.velocity = spaceShip.physicsBody?.velocity ?? .zero
        bulletNode.position = spaceShip.position
        bulletNode.physicsBody?.usesPreciseCollisionDetection = true
        bulletNode.physicsBody?.categoryBitMask = bulletsCatagory
        bulletNode.physicsBody?.collisionBitMask = asteroidsCatagory
        bulletNode.physicsBody?.contactTestBitMask = asteroidsCatagory
        bulletNode.name = "bullet"
        self.addChild(bulletNode)
        bulletNode.physicsBody?.applyForce(CGVector(direction: spaceShipDirection, magnitude: 10))
        spaceShip.physicsBody?.applyForce(CGVector(direction: spaceShipDirection, magnitude: -1.85))
    }
    
    private func spaceShipUpdateDirection() {
        spaceShip.zRotation = -spaceShipDirection * .pi / 180
    }
    
    private func keepNodesInsideScene() {
        for child in self.children {
            guard child.name != "bullet" else {
                if !child.frame.intersects(self.frame) {
                    child.removeFromParent()
                }
                continue
            }
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
    
    private func addAsteroid(
        sizeClass: AsteroidClass,
        position: CGPoint,
        velocity: CGVector,
        angularVelocity: CGFloat
    ) {
        let asteroidNode = AsteroidNode()
        asteroidNode.color = .white
        asteroidNode.size = sizeClass.cgsize
        asteroidNode.texture = sizeClass.sktexture
        asteroidNode.physicsBody = SKPhysicsBody(rectangleOf: asteroidNode.size)
        asteroidNode.physicsBody?.mass = 0.1
        asteroidNode.physicsBody?.velocity = velocity
        asteroidNode.physicsBody?.angularVelocity = angularVelocity
        asteroidNode.physicsBody?.restitution = 0
        asteroidNode.physicsBody?.angularDamping = 0
        asteroidNode.physicsBody?.linearDamping = 0
        asteroidNode.sizeClass = sizeClass
        asteroidNode.name = "asteroid"
        asteroidNode.position = position
        self.addChild(asteroidNode)
    }
    
    private func generateRandomAsteroid(sizeClass: AsteroidClass) {
        addAsteroid(
            sizeClass: sizeClass,
            position: CGPoint(
                x: .random(in: -self.size.width/2...self.size.width/2),
                y: .random(in: -self.size.height/2...self.size.height/2)
            ),
            velocity: {
                let magnitude = CGFloat.random(in: 20...40)
                let dx = magnitude-CGFloat.random(in: 0...magnitude)
                let dy = magnitude-dx
                return CGVector(dx: dx, dy: dy)
                }(),
            angularVelocity: .random(in: -2...2)
        )
    }
    
    private func splitAsteroid(asteroid: AsteroidNode, bulletVelocity: CGVector) {
        guard asteroid.physicsBody != nil,
              let sizeClass = asteroid.sizeClass.lowerClass else { return }
        for _ in 0...4 {
            addAsteroid(
                sizeClass: sizeClass,
                position: {
                    let x = asteroid.position.x
                    let y = asteroid.position.y
                    let width = asteroid.size.width
                    let height = asteroid.size.height
                    return CGPoint(
                        x: x + .random(in: -width/2...width/2),
                        y: y + .random(in: -height/2...height/2)
                    )
                }(),
                velocity: {
                    let baseDx = asteroid.physicsBody!.velocity.dx
                    let baseDy = asteroid.physicsBody!.velocity.dy
                    let xRandomOffset: CGFloat = .random(in: -100...100)
                    let yRandomOffset: CGFloat = .random(in: -100...100)
                    return CGVector(
                        dx: baseDx + xRandomOffset,
                        dy: baseDy + yRandomOffset
                    )
                }(),
                angularVelocity: .random(in: -2...2)
            )
        }
    }
    
}
