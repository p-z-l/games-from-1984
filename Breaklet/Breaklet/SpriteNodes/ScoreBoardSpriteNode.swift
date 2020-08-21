//
//  ScoreBoardSpriteNode.swift
//  Breakout
//
//  Created by Peter Luo on 2020/8/21.
//  Copyright © 2020 Peter Luo. All rights reserved.
//

import SpriteKit

class ScoreBoardNode: SKShapeNode {
    
    init(scores: [Score], parentScene: SKScene) {
        super.init(
            texture: nil,
            color: .black,
            size: CGSize(
                width: parentScene.frame.width-64,
                height: parentScene.frame.height-64
            )
        )
        self.position = CGPoint(x: 32, y: 32)
        self.isHidden = true
        
        parentScene.addChild(self)
    }
    
    func updateData(_ scores: [Score]) {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
