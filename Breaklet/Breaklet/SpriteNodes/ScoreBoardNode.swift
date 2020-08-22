//
//  ScoreBoardNode.swift
//  Breakout
//
//  Created by Peter Luo on 2020/8/21.
//  Copyright © 2020 Peter Luo. All rights reserved.
//

import SpriteKit

class ScoreBoardNode: SKSpriteNode {
    
    init(parentScene: SKScene) {
        super.init(
            texture: nil,
            color: .black,
            size: CGSize(
                width: parentScene.frame.width-64,
                height: parentScene.frame.height-64
            )
        )
        self.isHidden = true
        self.drawBorder(color: .white, width: 5)
        
        parentScene.addChild(self)
        self.zPosition = 200
    }
    
    private var rowNodes: [SKShapeNode] {
        return self.children.filter { $0.name == "rowNode" } as! [SKShapeNode]
    }
    
    func updateData() {
        for rowNode in rowNodes {
            rowNode.removeFromParent()
        }
        let scores = ScoreBoard.shared.scores
        drawRow(index: 0, scoreText: "Score", nameText: "PlayerName")
        for i in 0..<scores.count {
            let score = scores[i]
            drawRow(index: i+1, scoreText: String(score.value), nameText: score.name)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func drawRow(index: Int, scoreText: String, nameText: String) {
        let rowNode = SKShapeNode(
            rect: CGRect(
                x: -self.frame.width/2,
                y: -CGFloat(index+1)*(self.frame.height/11)+self.frame.height/2,
                width: self.frame.width,
                height: self.frame.height/11
            )
        )
        rowNode.name = "rowNode"
        rowNode.strokeColor = .white
        rowNode.lineWidth = 1.0
        let indexLabel = SKLabelNode(text: String(index))
        indexLabel.position = CGPoint(
            x: -rowNode.frame.width/2+32,
            y: rowNode.frame.midY-20
        )
        let fontName = NSFont.systemFont(ofSize: 0, weight: .medium).fontName
        indexLabel.fontSize = 24
        indexLabel.fontName = fontName
        switch index {
        case 1:
            indexLabel.fontColor = .systemRed
        case 2:
            indexLabel.fontColor = .systemYellow
        case 3:
            indexLabel.fontColor = .systemBlue
        default:
            indexLabel.fontColor = .white
        }
        let scoreLabel = SKLabelNode(text: scoreText)
        scoreLabel.position = CGPoint(
            x: rowNode.frame.minX+256,
            y: rowNode.frame.midY-20
        )
        scoreLabel.fontSize = 24
        scoreLabel.fontName = fontName
        let nameLabel = SKLabelNode(text: nameText)
        nameLabel.position = CGPoint(
            x: rowNode.frame.maxX-256,
            y: rowNode.frame.midY-20
        )
        nameLabel.fontSize = 24
        nameLabel.fontName = fontName
        rowNode.addChild(indexLabel)
        rowNode.addChild(scoreLabel)
        rowNode.addChild(nameLabel)
        self.addChild(rowNode)
    }
    
}
