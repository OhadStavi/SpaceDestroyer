//
//  Bullet.swift
//  SpaceDestroyer
//
//  Created by Ohad Stavi on 12/25/17.
//  Copyright © 2017 Ohad Stavi. All rights reserved.
//

import Foundation
import SpriteKit

enum Bullet {
    case regular
    case metal
    case saber
    
    public static func forLevel(_ level: Int) -> Bullet {
        switch level {
        case 1: return .regular
        case 2: return .metal
        default: return .saber
        }
    }
    
    private var scale: CGFloat {
        switch self {
        case .regular: return 1.0
        case .metal: return 2.5
        case .saber: return 0.25
        }
    }
    
    public var sprite: SKSpriteNode {
        var name: String
        
        switch self {
        case .regular: name = "bullet1"
        case .metal: name = "bullet2"
        case .saber: name = "bullet3"
        }
        
        let node = SKSpriteNode(imageNamed: name)
        node.name = "Bullet"
        node.setScale(scale)
        node.zPosition = 1
        
        return node
    }
    
    public var name: String {
        switch self {
        case .regular: return "Regular"
        case .metal: return "Metal"
        case .saber: return "Saber"
        }
    }
}
