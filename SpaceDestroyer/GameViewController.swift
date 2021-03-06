//
//  GameViewController.swift
//  SpaceDestroyer
//
//  Created by Ohad Stavi on 12/12/17.
//  Copyright © 2017 Ohad Stavi. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation//audio foundation

var backTrackAudio = AVAudioPlayer()

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // which audio track should we play
        let filePath = Bundle.main.path(forResource: "menusound", ofType: "wav")
        let audioURL = URL(fileURLWithPath: filePath!)
        
        // if can play - prepare to play, if can't, print "can't"
        do {
            backTrackAudio = try AVAudioPlayer(contentsOf: audioURL)
            backTrackAudio.numberOfLoops = -1
            backTrackAudio.volume = 1
            backTrackAudio.play()
        } catch {
            print("Couldn't get audio track")
        }

        // Set our game to fit every device - the hard coded way
        let scene = MainMenuScene(size: CGSize(width: 1536, height: 2048))

        // Configure our view
        guard let skView = self.view as? SKView else { fatalError("Can't cast view to SKView") }

        skView.showsFPS = false
        skView.showsNodeCount = false

        //Sprite Kit applies additional optimizations to improve rendering performance
        skView.ignoresSiblingOrder = true

        //set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill

        //present scene
        skView.presentScene(scene)
    }
    
    public func changeBGSound(soundName: String, soundType: String) {
       
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
