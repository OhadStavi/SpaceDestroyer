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
    case white
    case brown
    case aqua
    case iron
    case nature
    
    public static func forLevel(_ level: Int) -> Bullet {
        switch level {
        case 1: return .white
        case 2: return .brown
        case 3: return .aqua
        case 4: return .iron
        default: return .nature
        }
    }
    
    private var scale: CGFloat {
        switch self {
        case .white: return 0.1
        case .brown: return 0.2
        case .aqua: return 0.3
        case .iron: return 0.4
        case .nature: return 0.2
        }
    }
    
    private var attackPower: CGFloat {
        switch self {
        case .white: return 1
        case .brown: return 2
        case .aqua: return 3
        case .iron: return 4
        case .nature: return 5
        }
    }
    
    public var sprite: SKSpriteNode {
        var name: String
        
        switch self {
        case .white: name = "whiteEgg"
        case .brown: name = "brownEgg"
        case .aqua: name = "aquaEgg"
        case .iron: name = "ironEgg"
        case .nature: name = "natureEgg"
        }
        
        let node = SKSpriteNode(imageNamed: name)
        node.name = "Bullet"
        node.setScale(scale)
        node.zPosition = 1
        
        return node
    }
    
    public var name: String {
        switch self {
        case .white: return "White"
        case .brown: return "Brown"
        case .aqua: return "Aqua"
        case .iron: return "Iron"
        case .nature: return "Nature"
        }
    }
}
