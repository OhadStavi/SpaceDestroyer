//
//  Font.swift
//  SpaceDestroyer
//
//  Created by Ohad Stavi on 12/16/17.
//  Copyright © 2017 Ohad Stavi. All rights reserved.
//

import Foundation
import SpriteKit

enum Font: String {
    case hebrew = "Abraham"
    case english = "theboldfont"
    
    var labelNode: SKLabelNode {
        return SKLabelNode(fontNamed: rawValue)
    }
}
