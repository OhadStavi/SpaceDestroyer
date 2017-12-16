//
//  GameScene.swift
//  SpaceDestroyer
//
//  Created by Ohad Stavi on 12/12/17.
//  Copyright © 2017 Ohad Stavi. All rights reserved.
//

import SpriteKit
import GameplayKit

var score = 0 //score variable declared public to all scenes

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Setting up labels
    let scoreLbl = Font.hebrew.labelNode //SpriteKit label object
    let goLbl = Font.hebrew.labelNode
    
    // Setting up our Level system
    var lvlNum = 0 {
        didSet { print("set level to \(lvlNum)") }
    }
    
    // Setting up our Lives system
    var didPlayerEnter = false
    var lives = 3
    var livesLbl = Font.hebrew.labelNode
    
    // Connecting player image and defining it - declared globally
    // so we can work with our player in multiple methods
    let player = SKSpriteNode(imageNamed: "playerShip")
    
    // Global declaring our soundeffect will prevent it from being lagged when played
    let shotSound = SKAction.playSoundFileNamed("laserbeam.wav", waitForCompletion: false)
    let explosionSound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
    
    // Creating an enum to present our game states
    enum GameStates {
        case startScreen // before the game
        case gameOn // when game occurs
        case gameOver // when game is over
        case levelUp // when user levels up
    }
    
    var currentGameState = GameStates.startScreen
    
    // Defining physics categories - which physics bodies will interact with which
    // categories are ordered in numbers presented in binary (b)
    struct PhysicsCatgories {
        static let None: UInt32 = 0
        static let Player: UInt32 = 0b1 //1
        static let Bullet: UInt32 = 0b10 //2
        static let Enemies: UInt32 = 0b100 //4
    }
    
    // next two funcs generating a random number that our enemies will spawn from
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    //defining bounds of screen
    var gameArea: CGRect
    
    //initilizing screen bounds
    override init(size: CGSize) {
        //maximal game area ratio
        let maxiAspectRatio: CGFloat = 16/9
        
        //current playable width - depends on cellphone/tablet used to play
        let playableWidth = size.height / maxiAspectRatio
        
        //scence width - game area's width / 2
        let playableAreaMargin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: playableAreaMargin, y: 0, width: playableWidth, height: size.height)
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //runs as soon as scene loads
    override func didMove(to view: SKView) {
        //initialize score
        score = 0
        
        //initiating SKPhysicsContactDelegate in our GameScene
        self.physicsWorld.contactDelegate = self
        
        // Connecting b.g img from assets
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size //setting the b.g's size to match sence
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2) //b.g position in scene
        background.zPosition = 0  //b.g position related to object
        self.addChild(background) //excecute
        player.setScale(1) // setting our player's icon size
        player.position = CGPoint(x: self.size.width/2, y: 0 - player.size.height) //player's position in background
        player.zPosition = 2 //layering - if more than zero will be above b.g
        
        //defining player's physicsBody
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        
        //disabling our player's affects from gravity(that happens because of physicsBody)
        player.physicsBody!.affectedByGravity = false
        
        //assigning our player to Player's Physics Catergory
        player.physicsBody!.categoryBitMask = PhysicsCatgories.Player
        //preventing player physics to collide with other phyiscs objects
        player.physicsBody!.collisionBitMask = PhysicsCatgories.None
        //defining which of our physical objects our player can be in contact with
        player.physicsBody!.contactTestBitMask = PhysicsCatgories.Enemies
        self.addChild(player) // execute
        
        // Setting up our score label
        scoreLbl.text = "ניקוד: 0"
        scoreLbl.fontSize = 70
        scoreLbl.fontColor = SKColor.white
        //score label's position
        scoreLbl.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLbl.position = CGPoint(x: self.size.width*0.15, y: self.size.height + scoreLbl.frame.size.height)
        scoreLbl.zPosition = 100
        self.addChild(scoreLbl)
        
        goLbl.fontSize = 200
        goLbl.fontColor = SKColor.white
        goLbl.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        goLbl.alpha = 0
        goLbl.zPosition = 1
        self.addChild(goLbl)
        
        livesLbl.text = "❤️❤️❤️"
        livesLbl.fontSize = 70
        livesLbl.fontColor = SKColor.white
        livesLbl.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLbl.position = CGPoint(x: self.size.width*0.85, y: self.size.height + livesLbl.frame.size.height)
        livesLbl.zPosition = 100
        self.addChild(livesLbl)
        
        startGame()
    }
    
    private func startGame() {
        currentGameState = .gameOn
        didPlayerEnter = false

        levelUp()
    }
    
    private func losingLives() {
        lives -= 1
        livesLbl.text = String(repeating: "❤️", count: lives)
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let livesSequence = SKAction.sequence([scaleUp, scaleDown])
        livesLbl.run(livesSequence)
        
        // If player ran out of life - run game over
        if lives == 0 {
            gameOver()
        }
    }
    
    //setting up game over system
    private func gameOver() {
        //declaring that our game is over
        currentGameState = .gameOver
        clearGame()
        
        // change scene when game is over
        let changeSceneAction = SKAction.run(moveScene)
        let waitBeforeChange = SKAction.wait(forDuration: 1)
        let changeSeq = SKAction.sequence([waitBeforeChange, changeSceneAction])
        self.run(changeSeq)
    }
    
    private func clearGame() {
        self.removeAllActions() // stop enemies from spawning
        
        // Stop all actions related to bullet - from all over the scene
        self.enumerateChildNodes(withName: "Bullet") { bullet, _ in
            bullet.removeAllActions()
        }
        
        self.enumerateChildNodes(withName: "Enemy") { enemies, _ in
            enemies.removeAllActions()
        }
    }
    
    private func moveScene() {
        //declaring scene to move to + it's sizes and scales (equals to current)
        let sceneDestination = GameOverScene(size: self.size)
        sceneDestination.scaleMode = self.scaleMode
        //a bit of fade out between scenes
        let sceneTransition = SKTransition.fade(withDuration: 0.5)
        //present new scene with defined transition
        self.view!.presentScene(sceneDestination, transition: sceneTransition)
    }

    private func scoreUp() {
        score += 1
        scoreLbl.text = "ניקוד: \(score)"

        // Level up when score is even
        if score % 2 == 0 {
            levelUp()
        }
    }
    
    // Handle what happens when 2 objects comes collide with each other
    func didBegin(_ contact: SKPhysicsContact) {
        //instead of defining our objects as bodyA and bodyB every time,
        //we organize them with an if statement which automatically does the
        //job for us :)
        
        var physBody1 = SKPhysicsBody()
        var physBody2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            physBody1 = contact.bodyA
            physBody2 = contact.bodyB
        } else {
            physBody1 = contact.bodyB
            physBody2 = contact.bodyA
        }

        //if the player has hit the enemy
        if physBody1.categoryBitMask == PhysicsCatgories.Player &&
           physBody2.categoryBitMask == PhysicsCatgories.Enemies {
            // if there is a node (object)
            if physBody1.node != nil {
            explosionIsSpawned(spawnPosition: physBody1.node!.position)//calling the function in the player's position
            }
            if physBody2.node != nil {
            explosionIsSpawned(spawnPosition: physBody2.node!.position)//calling the function in the enemy's position
            }
            
            physBody1.node?.removeFromParent()//delete the player
            physBody2.node?.removeFromParent()//delete the enemy
            gameOver()//run game over
        }
        
        //if the bullet hits the enemy and enemy IS on the screen
        if physBody1.categoryBitMask == PhysicsCatgories.Bullet &&
           physBody2.categoryBitMask == PhysicsCatgories.Enemies &&
           (physBody2.node?.position.y)! < self.size.height {
            scoreUp()
            if physBody2.node != nil {
                //explosion is spawned right at enemy's position
                explosionIsSpawned(spawnPosition: physBody2.node!.position)
            }
            physBody1.node?.removeFromParent()//delete the bullet
            physBody2.node?.removeFromParent()//delete the enemy
        }
    }
    
    func explosionIsSpawned(spawnPosition: CGPoint) {
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
 
        // Give our explosion animative behaviour by using SKActions
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.scale(to: 0, duration: 0.1)
        let delete = SKAction.removeFromParent()
        let explosionSequence = SKAction.sequence([explosionSound, scaleIn, fadeOut, delete])
        explosion.run(explosionSequence)
        self.addChild(explosion)
    }
    
    func bulletsFired() {
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.name = "Bullet"
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 1
        self.addChild(bullet)
        
        let physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        physicsBody.affectedByGravity = false
        physicsBody.categoryBitMask = PhysicsCatgories.Bullet
        physicsBody.collisionBitMask = PhysicsCatgories.None
        physicsBody.contactTestBitMask = PhysicsCatgories.Enemies
        bullet.physicsBody = physicsBody
        
        //defining the bullet's actions
        let bulletMovement = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let bulletDeleted = SKAction.removeFromParent()
        //defining a sequence for our bullet's actions
        let actionSequence = SKAction.sequence([shotSound, bulletMovement, bulletDeleted])
        //execute sequence
        bullet.run(actionSequence)
    }

    // spawning our enemies randomly on the screen
    func enemiesSpawnedAtRandom() {
        // Make sure game state is on
        guard currentGameState == .gameOn else {
            print("Game is not running, not spawning...")
            return
        }

        // Setting up random starting and ending point for our enemies to spawn from
        let randomXStartPoint = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXEndingPoint = random(min: gameArea.minX, max: gameArea.maxX)
        
        // Setting up our enemies course on the screen after spawning
        let startPoint = CGPoint(x: randomXStartPoint, y: self.size.height * 1.2)
        let endingPoint = CGPoint(x: randomXEndingPoint, y: -self.size.height)
        
        // Setting up our enemies
        let enemies = SKSpriteNode(imageNamed: "enemyShip")
        enemies.name = "Enemy"
        enemies.setScale(1)
        enemies.position = startPoint
        enemies.zPosition = 2
        
        // Setting up enemies physics
        let physicsBody = SKPhysicsBody(rectangleOf: enemies.size)
        physicsBody.affectedByGravity = false
        physicsBody.categoryBitMask = PhysicsCatgories.Enemies
        physicsBody.collisionBitMask = PhysicsCatgories.None
        physicsBody.contactTestBitMask = PhysicsCatgories.Player | PhysicsCatgories.Bullet
        enemies.physicsBody = physicsBody
        self.addChild(enemies)
        
        // Move enemy to its end point
        let enemyEndPoint = SKAction.move(to: endingPoint, duration: 3)

        // once enemy gets to ending point - remove from screen
        let enemyDeleted = SKAction.removeFromParent()

        // If enemy passed the screen without getting shot, lose 1 life
        let missedEnemy = SKAction.run(losingLives)

        // Define enemy sequence of actions
        let enemyActionSequence = SKAction.sequence([enemyEndPoint, enemyDeleted, missedEnemy])

        // Spawn enemy
        enemies.run(enemyActionSequence)

        // Rotate our enemy to face it's current course,
        // and figure out the diffrence between startPoint.x/y to endingPoint.x/y
        let deltaX = endingPoint.x - startPoint.x
        let deltaY = endingPoint.y - startPoint.y
        
        // Define amount of rotation the enemy has to do
        let amountToRotate = atan2(deltaY, deltaX)
        
        // Rotate the enemy
        enemies.zRotation = amountToRotate
    }
    
    func levelUp() {
        lvlNum += 1
        currentGameState = .levelUp
        clearGame()
        
        // Fade out all game elements
        self.enumerateChildNodes(withName: "Enemy") { enemy, _ in
            enemy.run(.fadeOut(withDuration: 0.2))
            enemy.removeFromParent()
        }
        
        self.enumerateChildNodes(withName: "Bullet") { bullet, _ in
            bullet.run(.fadeOut(withDuration: 0.2))
            bullet.removeFromParent()
        }
        
        let elements: [SKNode] = [scoreLbl, livesLbl]
        for element in elements {
            element.run(.fadeOut(withDuration: 0.2))
        }
        
        if didPlayerEnter {
            player.run(.fadeOut(withDuration: 0.2))
        }

        // Fade in level label
        goLbl.text = "שלב \(lvlNum)"
        goLbl.run(.fadeIn(withDuration: 0.3))
        
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1.5) {
            if self.didPlayerEnter {
                self.startSpwaning()
            } else {
                self.goLbl.run(.fadeOut(withDuration: 0.3))

                let startGameSeq = SKAction.sequence([
                    .move(to: CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.1), duration: 0.5),
                    .wait(forDuration: 1.0),
                    .run(self.startSpwaning)
                    ])

                self.player.run(startGameSeq)
            }
        }
    }
    
    // Making enemies spawn by themselves
    func startSpwaning() {
        didPlayerEnter = true
        currentGameState = .gameOn
        
        // Move lives and score into screen
        let moveToScreen = SKAction.moveTo(y: self.size.height * 0.9, duration: 0.3)
        livesLbl.run(moveToScreen)
        scoreLbl.run(moveToScreen)
        
        // Fade in all game elements
        self.enumerateChildNodes(withName: "Enemy") { enemy, _ in
            enemy.run(.fadeIn(withDuration: 0.2))
        }
        
        self.enumerateChildNodes(withName: "Bullet") { bullet, _ in
            bullet.run(.fadeIn(withDuration: 0.2))
        }
        
        let elements: [SKNode] = [scoreLbl, livesLbl, player]
        for element in elements {
            element.run(.fadeIn(withDuration: 0.2))
        }
        
        // Fade out level label
        goLbl.text = "שלב \(lvlNum)"
        goLbl.fontSize = 200
        goLbl.fontColor = SKColor.white
        goLbl.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        goLbl.zPosition = 1
        goLbl.run(.fadeOut(withDuration: 0.3))

        // If scene has action - remove it (nececarry for leveling up)
        if self.action(forKey: "spawnYourFoe") != nil {
            self.removeAction(forKey: "spawnYourFoe")
        }
        
        // Dynamically calculate difficulty of level as the game progresses
        // with a hard bottom limit of 0.5
        var lvlDuration: TimeInterval = 1.8 - (Double(lvlNum - 1) * 0.5)
        lvlDuration = max(lvlDuration, 0.5)

        // Enemy spawned
        let enemiesSpawned = SKAction.run(enemiesSpawnedAtRandom)
        
        // Time duration between spawns
        let timeBetweenSpawns = SKAction.wait(forDuration: lvlDuration)
        
        // Enemy spawn sequence - first spawn, then wait
        let spawnSequence = SKAction.sequence([timeBetweenSpawns, enemiesSpawned])
        
        // Making our sequence repeat itself constantly
        let constantSpawn = SKAction.repeatForever(spawnSequence)
        
        // Execute
        self.run(constantSpawn, withKey: "spawnYourFoe")
    }
    
    // Executing bulletsFired method when touching the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch currentGameState {
        case .startScreen:
            startGame()
        case .gameOn:
            bulletsFired()
        default:
            break
        }
    }

    //effecting player's position by dragging our finger on the screen
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            // Touch positions will be in CGPoint
            let touchPosition = touch.location(in: self)
            let lastTouchPosition = touch.previousLocation(in: self)
            let amountDragged = touchPosition.x - lastTouchPosition.x
            
            // If game is on, move player by amount dragged
            if currentGameState == .gameOn {
                player.position.x += amountDragged
            }

            // Following if statements make sure that our player stays
            // in the game area's maximum and minimum x
            if player.position.x > gameArea.maxX - player.size.width / 2 {
                player.position.x = gameArea.maxX - player.size.width / 2
            } else if player.position.x < gameArea.minX + player.size.width / 2 {
                player.position.x = gameArea.minX + player.size.width/2
            }
        }
    }
}
