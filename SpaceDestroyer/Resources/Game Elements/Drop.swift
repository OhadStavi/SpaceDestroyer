//
//  Drop.swift
//  SpaceDestroyer
//
//  Created by Bubu on 03/01/2018.
//  Copyright © 2018 Ohad Stavi. All rights reserved.
//

import Foundation
import SpriteKit

enum Drop {
    case coin
    case life
    case powerUp
    
    public static func randomDrop() -> Drop {
        let randomNumber: Int = Int(arc4random_uniform(100))
       
        if randomNumber <= 90 {
            return .coin
        } else if randomNumber <= 96 {
            return .powerUp
        } else {
            return .life
        }
    }
    
    public static func randomSpecialDrop() -> Drop {
        let randomNumber: Int = Int(arc4random_uniform(100))
        
        if randomNumber <= 80 {
            return .powerUp
        } else {
            return .life
        }
    }
    
    private var scale: CGFloat {
        switch self {
        case .coin: return 0.2
        case .life: return 0.1
        case .powerUp: return 0.5
        }
    }

    private var name: String {
        switch self {
        case .coin: return "Coin"
        case .life: return "Life"
        case .powerUp: return "PowerUp"
        }
    }
    
    private var imageName: String {
        switch self {
        case .coin: return "coin"
        case .life: return "life"
        case .powerUp: return "powerUp"
        }
    }
    
    public var sprite: SKSpriteNode {
        
        let dropNode = SKSpriteNode(imageNamed: self.imageName)
        dropNode.name = self.name
        dropNode.setScale(self.scale)
        dropNode.zPosition = 1
        dropNode.physicsBody = Drop.getPhysicsBody(spriteNode: dropNode, drop: self)
        
        return dropNode
    }
    
    private static func getPhysicsBody(spriteNode: SKSpriteNode, drop: Drop) -> SKPhysicsBody {
      
        let dropPhysics = SKPhysicsBody(rectangleOf: spriteNode.size)
        dropPhysics.categoryBitMask = drop.dropCategory
        dropPhysics.affectedByGravity = false
        dropPhysics.collisionBitMask = GameScene.PhysicsCatgories.None
        dropPhysics.contactTestBitMask = GameScene.PhysicsCatgories.Player

        return dropPhysics
    }
    
    private var dropCategory: UInt32 {
        
        switch self {
        case .coin: return 0b110
        case .life: return 0b1001
        case .powerUp: return  0b101
        }
    }
}
