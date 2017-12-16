//
//  MainMenuScene.swift
//  SpaceDestroyer
//
//  Created by Ohad Stavi on 12/15/17.
//  Copyright © 2017 Ohad Stavi. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenuScene: SKScene {
    let startBtn = Font.hebrew.labelNode

    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)

        let gameTtl = Font.english.labelNode
        gameTtl.text = "Space"
        gameTtl.fontSize = 200
        gameTtl.fontColor = SKColor.white
        gameTtl.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.9)
        gameTtl.zPosition = 1
        self.addChild(gameTtl)

        let gameTtl2 = Font.english.labelNode
        gameTtl2.text = "Destroyer"
        gameTtl2.fontSize = 200
        gameTtl2.fontColor = SKColor.white
        gameTtl2.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.8)
        gameTtl2.zPosition = 1
        self.addChild(gameTtl2)

        let credTtl = Font.hebrew.labelNode
        credTtl.text = "אוהד סתוי, אלפי נעים ודניאל קפלן"
        credTtl.fontSize = 60
        credTtl.fontColor = SKColor.white
        credTtl.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.75)
        credTtl.zPosition = 1
        self.addChild(credTtl)

        startBtn.text = "התחל משחק"
        startBtn.fontSize = 150
        startBtn.fontColor = SKColor.white
        startBtn.position = CGPoint(x: self.size.width/2, y: self.size.height*0.5)
        startBtn.zPosition = 1
        self.addChild(startBtn)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let touchPoints = touch.location(in: self)

            if startBtn.contains(touchPoints) {
                let sceneDestination = GameScene(size: self.size)
                sceneDestination.scaleMode = self.scaleMode
                let sceneTransition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneDestination, transition: sceneTransition)
            }
        }
    }
}
