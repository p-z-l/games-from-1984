//
//  SKSpriteNode+Extension.swift
//  Breakout
//
//  Created by Peter Luo on 2020/8/21.
//  Copyright © 2020 Peter Luo. All rights reserved.
//

import SpriteKit

extension SKSpriteNode {
    func drawBorder(color: NSColor, width: CGFloat) {
        let borderNode = SKShapeNode(rect: frame)
        borderNode.fillColor = .clear
        borderNode.strokeColor = color
        borderNode.lineWidth = width
        borderNode.name = "borderNode"
        addChild(borderNode)
    }
}
