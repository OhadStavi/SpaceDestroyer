//
//  GameOverScene.swift
//  SpaceDestroyer
//
//  Created by Ohad Stavi on 12/15/17.
//  Copyright © 2017 Ohad Stavi. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    let gameOverSound = SKAction.playSoundFileNamed("gameover.mp3", waitForCompletion: false)

    //playing game over sound
    func playSound(sound: SKAction) {
        run(sound)
    }
    
    let backToMainLbl = Font.hebrew.labelNode
    let restartLbl = Font.hebrew.labelNode
    let shareLbl = Font.hebrew.labelNode
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        playSound(sound: gameOverSound)
    
        let headerLbl = Font.hebrew.labelNode
        headerLbl.text = "המשחק נגמר!"
        headerLbl.fontSize = 180
        headerLbl.fontColor = SKColor.white
        headerLbl.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.7)
        headerLbl.zPosition = 1
        self.addChild(headerLbl)
        
        let scoreLbl = Font.hebrew.labelNode
        scoreLbl.text = "ניקוד: \(score)"
        scoreLbl.fontSize = 110
        scoreLbl.fontColor = SKColor.white
        scoreLbl.position = CGPoint(x: self.size.width/2, y: self.size.height*0.55)
        scoreLbl.zPosition = 1
        self.addChild(scoreLbl)
        
        // Setting up high score system - see info saved and save new info
        let defaults = UserDefaults.standard //define UserDefaults
        var highScore = defaults.integer(forKey: "highScoreSaved") //save high score by key
        
        // if score is higher than current high score - store and change
        if score > highScore {
            highScore = score //update new high score = current highest score achived
            defaults.set(highScore, forKey: "highScoreSaved") //store
        }
        
        let highScoreLbl = Font.hebrew.labelNode
        highScoreLbl.text = "שיא: \(highScore)"
        highScoreLbl.fontSize = 110
        highScoreLbl.fontColor = SKColor.white
        highScoreLbl.position = CGPoint(x: self.size.width/2, y: self.size.height*0.45)
        highScoreLbl.zPosition = 1
        self.addChild(highScoreLbl)
        
        restartLbl.text = "נסה שנית"
        restartLbl.fontSize = 60
        restartLbl.fontColor = SKColor.white
        restartLbl.position = CGPoint(x: self.size.width/2, y: self.size.height*0.35)
        restartLbl.zPosition = 1
        self.addChild(restartLbl)
        
        backToMainLbl.text = "חזרה לתפריט הראשי"
        backToMainLbl.fontSize = 60
        backToMainLbl.fontColor = SKColor.white
        backToMainLbl.position = CGPoint(x: self.size.width/2, y: self.size.height*0.25)
        backToMainLbl.zPosition = 1
        self.addChild(backToMainLbl)
        
        shareLbl.text = "שתף ניקוד"
        shareLbl.fontSize = 60
        shareLbl.fontColor = SKColor.white
        shareLbl.position = CGPoint(x: self.size.width/2, y: self.size.height*0.15)
        shareLbl.zPosition = 1
        self.addChild(shareLbl)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Defining touch points on screen
        for touch: AnyObject in touches {
            let touchPoints = touch.location(in: self)
            
            // Turning our label into a button
            // if label is in given position - execute following:
            if restartLbl.contains(touchPoints) {
                let destination = GameScene(size: self.size)
                destination.scaleMode = self.scaleMode
                let transition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(destination, transition: transition)
            }
            
            if backToMainLbl.contains(touchPoints) {
                let destination = MainMenuScene(size: self.size)
                destination.scaleMode = self.scaleMode
                let transition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(destination, transition: transition)
            }
          
            if shareLbl.contains(touchPoints) {
                let alert = UIAlertController(title: "אל תשמור הכל לעצמך,",
                                              message: "שתף את תוצאתך אונליין עכשיו!",
                                              preferredStyle: UIAlertControllerStyle.alert)
                let fbAction = UIAlertAction(title: "Facebook", style: .default, handler: nil)
                let twAction = UIAlertAction(title: "Twitter", style: .default, handler: nil)
                let gpAction = UIAlertAction(title: "Google+", style: .default, handler: nil)
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alert.addAction(fbAction)
                alert.addAction(twAction)
                alert.addAction(gpAction)
                alert.addAction(cancel)
                self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
            }
        }
    }
}
