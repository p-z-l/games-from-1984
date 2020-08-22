//
//  AsteroidClass.swift
//  Asteroids
//
//  Created by Peter Luo on 2020/8/22.
//

import SpriteKit

enum AsteroidClass: Int {
    
    case small = 0, medium, large
    
    var cgsize: CGSize {
        switch self {
        case .large:
            return CGSize(width: 40, height: 40)
        case .medium:
            return CGSize(width: 25, height: 25)
        case .small:
            return CGSize(width: 10, height: 10)
        }
    }
    
    var sktexture: SKTexture? {
        return nil
    }
}
