//
//  CGVector+Extension.swift
//  Asteroids
//
//  Created by Peter Luo on 2020/8/22.
//

import Foundation

extension CGVector {
    
    init(direction: CGFloat, magnitude: CGFloat) {
        let radian = direction * .pi / 180
        self.init(
            dx: sin(radian)*magnitude,
            dy: cos(radian)*magnitude
        )
    }
    
}
