//
//  GameScene.swift
//  SpaceDestroyer
//
//  Created by Ohad Stavi on 12/12/17.
//  Copyright © 2017 Ohad Stavi. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

var score = 0 // Score variable declared public to all scenes
// Link plist to project
let path = Bundle.main.path(forResource: "levels", ofType: "plist")!
// Loading the levels array from the Plist
let levels = NSArray(contentsOfFile: path) as? [[String: Any]]

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bossLife = 1, targetScore = 0
    
    // Declare labels
    let infoBarlbl = Font.hebrew.labelNode // Lable that shows the life, score and weapon level (upper - right corner)
    let targetScorelbl = Font.hebrew.labelNode // Lable that shows the target score (upper - left corner)
    let goLbl = Font.hebrew.labelNode // Lable that apear before every level and show the level number
    let goalLbl = Font.hebrew.labelNode // Lable that apear before every level and show the level goal
  
    // Setting up our Level system
    var lvlNum = 0 {
        didSet { print("set level to \(lvlNum)") }
    }
    
    // Setting up our Lives system
    var didPlayerEnter = false
    var lives = 5
    
    // Defining new image object
    let player = SKSpriteNode(imageNamed: "superChicken")
    
    // Setting powerUp system
    private var weaponLevel = 1 {
        didSet {
            print("Now using \(bullet.name) Egg")
        }
    }
    
    // Return the bullet according to weapon's level
    var bullet: Bullet {
        return Bullet.forLevel(weaponLevel)
    }
    
    // Global declaring our soundeffect will prevent it from being lagged when played
    let shotSound = SKAction.playSoundFileNamed("laserbeam.wav", waitForCompletion: false)
    let explosionSound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
    let coinSound = SKAction.playSoundFileNamed("collectCoin.wav", waitForCompletion: false)
    let playsoundyay = SKAction.playSoundFileNamed("yaySound.mp3", waitForCompletion: false)
    let lifeSound = SKAction.playSoundFileNamed("lifesound.wav", waitForCompletion: false)
    let powerUpSound = SKAction.playSoundFileNamed("powerupsound.wav", waitForCompletion: false)

    // Creating an enum to present our game states
    enum GameStates {
        case startScreen // before the game
        case gameOn      // when game occurs
        case gameOver    // when game is over
        case levelUp     // when user levels up
    }
    
    var currentGameState = GameStates.startScreen // Create var that presents the currnet gameState
    
    // Defining physics categories - which physics bodies will interact with which
    // categories are ordered in numbers presented in binary (b)
    struct PhysicsCatgories {
        static let None: UInt32 = 0
        static let Player: UInt32 = 0b1 //1
        static let Bullet: UInt32 = 0b10 //2
        static let Enemies: UInt32 = 0b100 //4
        static let PowerUp: UInt32 = 0b101 //5
        static let Coin: UInt32 = 0b110 //6
        static let Boss: UInt32 = 0b111 //7
        static let EnemyAttack: UInt32 = 0b1000 //8
        static let Life: UInt32 = 0b1001 //9
    }
    
    // Next three funcs generating a random numbers
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func random(max: Int, min: Int) -> Double {
        return Double(arc4random_uniform(UInt32(max)) + UInt32(min))
    }
    
    // Defining bounds of screen
    var gameArea: CGRect

    // Initilizing screen bounds
    override init(size: CGSize) {
        // Maximal game area ratio
        let maxiAspectRatio: CGFloat = 16/9
        // Current playable width - depends on cellphone/tablet used to play
        let playableWidth = size.height / maxiAspectRatio
        // Scence width - game area's width / 2
        let playableAreaMargin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: playableAreaMargin, y: 0, width: playableWidth, height: size.height)
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Runs as soon as scene loads (equivalent to viewDidLoad)
    override func didMove(to view: SKView) {
        
        // Initialize score
        score = 0
        
        // Initiating SKPhysicsContactDelegate in our GameScene
        self.physicsWorld.contactDelegate = self
        
        // Inserting our background in a for loop will make it become scrollable
        // and will provide an illusion of it "moving"
        
        for i in 0...1 {
        // Connecting b.g img from assets
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size // Setting the b.g's size to match scene
        background.anchorPoint = CGPoint(x: 0.5, y: 0) // Defining default anchor points
        // Second b.g position in scene - top of screen (y position depends on the index position)
        background.position = CGPoint(x: self.size.width/2, y: self.size.height * CGFloat(i))
        background.zPosition = 0  // B.g position related to object
        background.name = "Background"
        self.addChild(background) // Excecute
        }
        
        player.setScale(1) // Setting our player's size
        player.position = CGPoint(x: self.size.width/2, y: 0 - player.size.height) // Player's position in background
        player.zPosition = 2 // Layering
        addPhysicsToPlayer()
        self.addChild(player) // execute
        
        // Setting up the lables
        goLbl.fontSize = 200
        goLbl.fontColor = SKColor.white
        goLbl.alpha = 0
        goLbl.zPosition = 1
        goLbl.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        self.addChild(goLbl)
        
        goalLbl.fontSize = 100
        goalLbl.fontColor = SKColor.white
        goalLbl.alpha = 0
        goalLbl.zPosition = 1
        goalLbl.position = CGPoint(x: self.size.width/2, y: self.size.height/2.2)
        self.addChild(goalLbl)
        
        targetScorelbl.fontSize = 80
        targetScorelbl.fontColor = SKColor.white
        targetScorelbl.alpha = 0
        targetScorelbl.zPosition =  100
        refreshTargetLbl()
        targetScorelbl.position = CGPoint(x: gameArea.minX + targetScorelbl.frame.size.width/2,
                                          y: self.size.height - targetScorelbl.frame.size.height)
        self.addChild(targetScorelbl)
        
        infoBarlbl.fontSize =  70
        infoBarlbl.fontColor = SKColor.white
        infoBarlbl.alpha = 0
        infoBarlbl.zPosition = 100
        refreshInfoBarLbl()
        infoBarlbl.position = CGPoint(x: gameArea.maxX - infoBarlbl.frame.size.width/2,
                                      y: self.size.height - infoBarlbl.frame.size.height)
        self.addChild(infoBarlbl)

        startGame()
    }
    
    public func addPhysicsToPlayer() {
        
        // Defining player's physicsBody
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        
        // Disabling our player's affects from gravity(that happens because of physicsBody)
        player.physicsBody!.affectedByGravity = false
        
        // Assigning our player to Player's Physics Catergory
        player.physicsBody!.categoryBitMask = PhysicsCatgories.Player
        
        // Preventing player physics to collide with other phyiscs objects
        player.physicsBody!.collisionBitMask = PhysicsCatgories.None
        
        // Defining which of our physical objects our player can be in contact with
        player.physicsBody!.contactTestBitMask = PhysicsCatgories.Enemies
        
    }
    
    var lastUpdated: TimeInterval = 0 // Storing time of last frame (will be equaled to current time)
    var deltaFrameTime: TimeInterval = 0 // Delta time between frames
    var amountToMove: CGFloat = 700 // Defining how many points background will move per second
    
    // Update func runs every frame and it will update our background's position
    override func update(_ currentTime: TimeInterval) {
        
        // When current time runs again - last updated is the last current time stored.
        if lastUpdated == 0 {
            lastUpdated = currentTime
        } else {
            deltaFrameTime = currentTime - lastUpdated
            lastUpdated = currentTime
        }
        // Background's movement - 600 * time has passed
        let amountToMoveBG = amountToMove * CGFloat(deltaFrameTime)
        self.enumerateChildNodes(withName: "Background") { background, _ in
            
            // Scroll background ONLY during game
            if self.currentGameState == GameStates.gameOn {
            background.position.y -= amountToMoveBG
            }
            
            // When background let the screen's bottom - move to top
            if background.position.y < -self.size.height {
                background.position.y += self.size.height*2
            }
        }
    }
    
    private func refreshInfoBarLbl() { // Refresh the info bar text and position
        infoBarlbl.text = "🐔\(lives)   💰\(score)   ⚡\(weaponLevel)"
        infoBarlbl.position = CGPoint(x: gameArea.maxX - infoBarlbl.frame.size.width/2,
                                      y: self.size.height - infoBarlbl.frame.size.height)
    }
    
    private func refreshBossLifeLbl() { // Refresh the boss-lifebar text and position
        (bossLife > 0) ? (targetScorelbl.text = "🚀 : \(bossLife)") : (targetScorelbl.text = "🚀 : ☠️")
        targetScorelbl.position = CGPoint(x: gameArea.minX + targetScorelbl.frame.size.width/2,
                                          y: self.size.height - targetScorelbl.frame.size.height)
    }
    
    private func refreshTargetLbl() { // Refresh the target bar text and position
        (targetScore > 0) ? (targetScorelbl.text = "🎯 : \(targetScore)") : (targetScorelbl.text = "🎯 : 👌🏻")
        targetScorelbl.position = CGPoint(x: gameArea.minX + targetScorelbl.frame.size.width/2,
                                  y: self.size.height - targetScorelbl.frame.size.height)
    }
    
    // Send to the first level
    private func startGame() {
        currentGameState = .gameOn
        didPlayerEnter = false
        weaponLevel = 1
        levelUp()
    }
    
    // Calls every time the player loses a life
    private func losingLives() {
        lives -= 1
        refreshInfoBarLbl()
        if lives < 1 {
            gameOver()
        } else {
            weaponLevel = 1 // Reset weapon level
            let ouchSound = SKAction.playSoundFileNamed("ouch.wav", waitForCompletion: false)
            let fadeOut = SKAction.fadeOut(withDuration: 0.2)
            let fadeIn = SKAction.fadeIn(withDuration: 0.2)
            let shieldOn = SKAction.run { self.player.physicsBody = nil }
            let shieldOff = SKAction.run(addPhysicsToPlayer)
            let fadeSequence = SKAction.sequence([fadeOut, fadeIn])
            let fadeAction = SKAction.repeat(fadeSequence, count: 5)
            let shieldSequence = SKAction.sequence([ouchSound, shieldOn, fadeAction, shieldOff])
            player.run(shieldSequence)
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
        refreshInfoBarLbl()
    }
    
    private func powerUp() {
        weaponLevel += 1
        refreshInfoBarLbl()
    }
    
    // Handle what happens when 2 objects collide with each other
    func didBegin(_ contact: SKPhysicsContact) {
        //Instead of defining our objects as bodyA and bodyB every time,
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

        // If the player has hit the enemy or enemy's attack
        if physBody1.categoryBitMask == PhysicsCatgories.Player &&
           (physBody2.categoryBitMask == PhysicsCatgories.Enemies ||
           physBody2.categoryBitMask == PhysicsCatgories.EnemyAttack) {
            
            // If there is a node (object) create exlposion on player's position
            if physBody1.node != nil {
                explosionIsSpawned(spawnPosition: physBody1.node!.position, chosenScale: (physBody1.node?.xScale)!)
            } // If second body is an enemy create exlposion on enemy's position
            if physBody2.node != nil && physBody2.categoryBitMask == PhysicsCatgories.Enemies {
            explosionIsSpawned(spawnPosition: physBody2.node!.position, chosenScale: (physBody2.node?.xScale)!)
            }
            
            physBody2.node?.removeFromParent() //Delete the enemy or enemy's attack
            losingLives()
            if lives < 1 {
                 physBody1.node?.removeFromParent()// Delete the player
            }
        }
        
        // If the player hit the powerUp, coin or life
        if physBody1.categoryBitMask == PhysicsCatgories.Player &&
           (physBody2.categoryBitMask == PhysicsCatgories.PowerUp ||
           physBody2.categoryBitMask == PhysicsCatgories.Coin ||
           physBody2.categoryBitMask == PhysicsCatgories.Life) {
            
            switch physBody2.categoryBitMask {
            case PhysicsCatgories.PowerUp:
                powerUp()
                run(powerUpSound)
            case PhysicsCatgories.Coin:
                scoreUp()
                run(coinSound)
            case PhysicsCatgories.Life:
                lives += 1
                run(lifeSound)
            default:
                print("Error collide player and drop ")
            }
            refreshInfoBarLbl()
            physBody2.node?.removeFromParent() //Delete the object
        }
        
        // If the bullet hits the enemy and enemy IS on the screen
        if physBody1.categoryBitMask == PhysicsCatgories.Bullet &&
            physBody2.categoryBitMask == PhysicsCatgories.Enemies &&
            (physBody2.node?.position.y)! < self.size.height {
            
            scoreUp()
            targetScore -= 1
            refreshTargetLbl()
            
            if targetScore == 0 {
                run(playsoundyay)
                checkIfStatic()
            }
            
            if physBody2.node != nil {
                // Explosion is spawned right at enemy's position
                explosionIsSpawned(spawnPosition: physBody2.node!.position, chosenScale: (physBody2.node?.xScale)!)
                randomDropSpawn(spawnPosition: physBody2.node!.position)
            }
            physBody1.node?.removeFromParent()// Delete the bullet
            physBody2.node?.removeFromParent()// Delete the enemy
            
        }
        
        // If bullet hit the boss
        if physBody1.categoryBitMask == PhysicsCatgories.Bullet &&
            physBody2.categoryBitMask == PhysicsCatgories.Boss &&
            (physBody2.node?.position.y)! < self.size.height {
            
            let bossPosition = physBody2.node!.position
            let bossWidth = physBody2.node?.frame.size.width
            let randomXPointOnBoss = random(min: bossPosition.x - (bossWidth)!/2, max: bossPosition.x + (bossWidth)!/2)
            
            bossLife -= weaponLevel // Subtract weapon level from boss HP
            refreshBossLifeLbl() // Make small explostion to show that boss is hurt
            explosionIsSpawned(spawnPosition: CGPoint(x: randomXPointOnBoss,
                                                      y: bossPosition.y),
                               chosenScale: (physBody2.node?.xScale)! / 5)
            
            for _ in 1...weaponLevel { // Drop coins acording to weapons level
                dropSpawn(spawnPosition: CGPoint(x: randomXPointOnBoss, y: bossPosition.y), type: Drop.coin)
            }
            
            if bossLife == 0 { // If boss dies drop special gift
                randomSpecialDropSpawn(spawnPosition: bossPosition)
                run(playsoundyay)
                changeMusic(fileName: "menusound", type: "wav") // Change BG music back to original
                
                if physBody2.node != nil {
                    // Explosion is spawned right at boss's position
                    explosionIsSpawned(spawnPosition: bossPosition, chosenScale: (physBody2.node?.yScale)!)
                }
                physBody2.node?.removeFromParent()// Delete the boss
                
                let endTheLevel = SKAction.run(levelUp)
                let timeForlastCoin = SKAction.wait(forDuration: 6)
                let levelSequence = SKAction.sequence([timeForlastCoin, endTheLevel])
                run(levelSequence) //!!! coin duration
            }
            physBody1.node?.removeFromParent()//delete the bullet
        }
}
    // Func spawn random drop at chosen location
    private func randomDropSpawn(spawnPosition: CGPoint) {
        
        let dropSprite = Drop.randomDrop().sprite
        dropSprite.position = spawnPosition
        let dropSpriteAction = SKAction.moveTo(y: -self.size.height, duration: 5)
        dropSprite.run(dropSpriteAction)
        self.addChild(dropSprite)
    }
    // Func spawn random special drop at chosen location
    private func randomSpecialDropSpawn(spawnPosition: CGPoint) {
        
        let dropSprite = Drop.randomSpecialDrop().sprite
        dropSprite.position = spawnPosition
        let dropSpriteAction = SKAction.moveTo(y: -self.size.height, duration: 5)
        dropSprite.run(dropSpriteAction)
        self.addChild(dropSprite)
    }
    
    // Func spawn chosen drop at chosen location
    private func dropSpawn(spawnPosition: CGPoint, type: Drop) {
        
        let dropSprite = type.sprite
        dropSprite.position = spawnPosition
        let dropSpriteAction = SKAction.moveTo(y: -self.size.height, duration: 5)
        dropSprite.run(dropSpriteAction)
        self.addChild(dropSprite)
    }
    
    // Func spawn explosion with chosen scale at chosen location
    private func explosionIsSpawned(spawnPosition: CGPoint, chosenScale: CGFloat) {
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
 
        // Give our explosion animative behaviour by using SKActions
        let scaleIn = SKAction.scale(to: chosenScale, duration: 0.1)
        let fadeOut = SKAction.scale(to: 0, duration: 0.1)
        let delete = SKAction.removeFromParent()
        let explosionSequence = SKAction.sequence([explosionSound, scaleIn, fadeOut, delete])
        explosion.run(explosionSequence)
        self.addChild(explosion)
    }
    
    // Calls when the game in on and user touches the screen, create bullet with action
    private func bulletsFired() {
        let sprite = bullet.sprite
        sprite.position = player.position
        addChild(sprite)
        // Add physics to the bullet
        let physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        physicsBody.affectedByGravity = false
        physicsBody.categoryBitMask = PhysicsCatgories.Bullet
        physicsBody.collisionBitMask = PhysicsCatgories.None
        physicsBody.contactTestBitMask = PhysicsCatgories.Enemies
        sprite.physicsBody = physicsBody
        
        // Defining the bullet's actions
        let bulletMovement = SKAction.moveTo(y: self.size.height + sprite.size.height, duration: 1)
        let bulletDeleted = SKAction.removeFromParent()
        // Defining a sequence for our bullet's actions
        let actionSequence = SKAction.sequence([shotSound, bulletMovement, bulletDeleted])
        // Execute sequence
        sprite.run(actionSequence)
    }
    
    private func checkIfStatic() {
        if levels?[lvlNum-1]["levelType"] as? String == "static" {
            let wait = SKAction.wait(forDuration: 2)
            let levelUpAction = SKAction.run(levelUp)
            let endLevelSequence = SKAction.sequence([wait, levelUpAction])
            run(endLevelSequence)
        }
    }
    
    private func spawnEnemies() {
        // Make sure game state is on
        guard currentGameState == .gameOn else {
            print("Game is not running, not spawning...")
            return }
        
        let currentLevel = levels![lvlNum-1]
        
        var startPosition = CGPoint(x: 0, y: 0), endPosition = CGPoint(x: 0, y: 0),
        // Load info from levels array
        fallingSpeed = currentLevel["fallingSpeed"] as? Int,
        spawnDirection = currentLevel["spawnDirection"] as? String
    
        switch spawnDirection {
        case "rightToLeft"?:
            startPosition = CGPoint(x: self.size.width, y: self.size.height * 1.2)
            endPosition = CGPoint(x: -self.size.width/2, y: -self.size.height)
        case "leftToRight"?:
            startPosition = CGPoint(x: 0, y: self.size.height * 1.2)
            endPosition = CGPoint(x: self.size.width * 1.5, y: -self.size.height)
        case "startRandom"?:
            startPosition = CGPoint(x: random(min: gameArea.minX, max: gameArea.maxX), y: self.size.height * 1.2)
            endPosition = CGPoint(x: startPosition.x, y: -self.size.height)
        case "allRandom"?:
            startPosition = CGPoint(x: random(min: gameArea.minX, max: gameArea.maxX), y: self.size.height * 1.2)
            endPosition = CGPoint(x: random(min: gameArea.minX, max: gameArea.maxX), y: -self.size.height)
        default:
            print("Error on loading spawnDirection")
                }
        
        // Setting up the enemy
        let Enemy = SKSpriteNode(imageNamed: "enemyShip")
        Enemy.name = "Enemy"
        Enemy.position = startPosition
        Enemy.zPosition = 2
        Enemy.setScale(1)
    
        // Rotate our enemy to face it's current course,
        // and figure out the diffrence between startPoint.x/y to endingPoint.x/y
        let deltaX = endPosition.x - startPosition.x
        let deltaY = endPosition.y - startPosition.y
        // Define amount of rotation the enemy has to do
        let amountToRotate = atan2(deltaY, deltaX)
       
        // Add phisics to the Enemy
        let physicsBody = SKPhysicsBody(rectangleOf: Enemy.size)
        physicsBody.categoryBitMask = PhysicsCatgories.Enemies
        physicsBody.contactTestBitMask = PhysicsCatgories.Player | PhysicsCatgories.Bullet
        physicsBody.affectedByGravity = false
        physicsBody.collisionBitMask = PhysicsCatgories.None
        
        Enemy.zRotation = amountToRotate
        Enemy.physicsBody = physicsBody
        self.addChild(Enemy)
        
        let enemyMove = SKAction.move(to: endPosition, duration: TimeInterval(fallingSpeed!))
        let deleteEnemy = SKAction.removeFromParent()
        let enemySequence = SKAction.sequence([enemyMove, deleteEnemy])
        Enemy.run(enemySequence)
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
        
        self.enumerateChildNodes(withName: "PowerUp") { powerUp, _ in
            powerUp.run(.fadeOut(withDuration: 0.2))
            powerUp.removeFromParent()
        }
        
        self.enumerateChildNodes(withName: "Life") { life, _ in
            life.run(.fadeOut(withDuration: 0.2))
            life.removeFromParent()
        }
        
        self.enumerateChildNodes(withName: "Bullet") { bullet, _ in
            bullet.run(.fadeOut(withDuration: 0.2))
            bullet.removeFromParent()
        }
        
        self.enumerateChildNodes(withName: "Coin") { coin, _ in
            coin.run(.fadeOut(withDuration: 0.2))
            coin.removeFromParent()
        }
        
        infoBarlbl.run(.fadeOut(withDuration: 0.2))
        targetScorelbl.run(.fadeOut(withDuration: 0.2))
        
        if didPlayerEnter {
            player.run(.fadeOut(withDuration: 0.2))
        }
        
        // Fade in level label
        goLbl.text = "שלב \(lvlNum)"
        goalLbl.text = "יעד: \(levels![lvlNum-1]["goalTxt"] ?? "BubuPooka")"
        goLbl.run(.fadeIn(withDuration: 0.3))
        goalLbl.run(.fadeIn(withDuration: 0.3))
        
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1.5) {
            if self.didPlayerEnter {
                self.loadLevel()
            } else {
                self.goLbl.run(.fadeOut(withDuration: 0.3))
                self.goalLbl.run(.fadeOut(withDuration: 0.5))
                
                let startGameSeq = SKAction.sequence([
                    .move(to: CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.1), duration: 0.5),
                    .wait(forDuration: 1.0),
                   
                    .run(self.loadLevel)
                    ])
                self.player.run(startGameSeq)
            }
        }
    }
    // Load the required level type
    private func loadLevel() {
        let levelType = levels![lvlNum-1]["levelType"]
    
        switch levelType as? String {
        case "normal"?:
            startNormalLevel()
        case "boss"?:
            startBossLevel()
        case "static"?:
            startStaticLevel()
        default:
            print("Error on loading level")
        }
    }
    // Load boss type Level
    private func startBossLevel() {
        
        didPlayerEnter = true
        currentGameState = .gameOn
        
        let currentLevel = levels![lvlNum-1]
        
        var attackDelay = currentLevel["attackDelay"] as? Double
        changeMusic(fileName: "imperial", type: "wav")
        bossLife = (currentLevel["HP"] as? Int)!
        refreshBossLifeLbl()
        
        regularLevelComponents()
        
        // Setting up the Boss
        let boss = SKSpriteNode(imageNamed: "boss")
        boss.setScale(4.7)
        boss.zPosition = 2
        boss.position = CGPoint(x: self.size.width/2, y: self.size.height + boss.size.height)
        self.addChild(boss)
        
        func addPhysicsToBoss() {
            let physicsBody = SKPhysicsBody(rectangleOf: boss.size)
            physicsBody.categoryBitMask = PhysicsCatgories.Boss
            physicsBody.contactTestBitMask = PhysicsCatgories.Bullet
            physicsBody.affectedByGravity = false
            physicsBody.collisionBitMask = PhysicsCatgories.None
            boss.physicsBody = physicsBody
        }
        
        func shotTowardsPlayer() {
            shot(startPosition: boss.position,
                 targetPosition: player.position,
                 bulletSpeed: currentLevel["attackSpeed"] as? Double ?? 1,
                 bulletScale: 0.4)
        }
    
        // Add entring to the scene
        let timeBetweenAttacks = SKAction.wait(forDuration: attackDelay!)
        let addPhysicsToBossAction = SKAction.run(addPhysicsToBoss)
        let moveDown = SKAction.moveTo(y: self.size.height - boss.size.height/2 - infoBarlbl.frame.size.height,
                                       duration: 5)
        let startFighting = SKAction.run(shotTowardsPlayer)
        let fightingActionSequence = SKAction.sequence([startFighting, timeBetweenAttacks])
        let fightforever = SKAction.repeatForever(fightingActionSequence)
        let bossSequence = SKAction.sequence([moveDown, addPhysicsToBossAction, fightforever])
        boss.run(bossSequence)
    }
    
    // Make bullet that move's from chosen position to other chosen position in chosen speed
    private func shot(startPosition: CGPoint, targetPosition: CGPoint, bulletSpeed: Double, bulletScale: CGFloat) {
        
        let aimedEnemyBullet = SKSpriteNode(imageNamed: "rocket")
        aimedEnemyBullet.position = startPosition
        aimedEnemyBullet.setScale(bulletScale)
        aimedEnemyBullet.zPosition = 1
        addChild(aimedEnemyBullet)
        // Add physics
        let physicsBody = SKPhysicsBody(rectangleOf: aimedEnemyBullet.size)
        physicsBody.affectedByGravity = false
        physicsBody.categoryBitMask = PhysicsCatgories.EnemyAttack
        physicsBody.collisionBitMask = PhysicsCatgories.None
        physicsBody.contactTestBitMask = PhysicsCatgories.Player
        aimedEnemyBullet.physicsBody = physicsBody
        
        // Defining the bullet's actions
        let bulletMovement = SKAction.move(to: targetPosition, duration: bulletSpeed)
        let bulletDeleted = SKAction.removeFromParent()
        
        // Defining a sequence for our bullet's actions
        let actionSequence = SKAction.sequence([bulletMovement, bulletDeleted])
        
        // Execute sequence
        aimedEnemyBullet.run(actionSequence)
    }
    
    //Load normal type level
    func startNormalLevel() {
        
        didPlayerEnter = true
        currentGameState = .gameOn
        
        let currentLevel = levels![lvlNum-1]
        targetScore = (currentLevel["goal"] as? Int)!
        refreshTargetLbl()
        
        let enemySpawnDelay = currentLevel["enemySpawnDelay"] as? Double
        let fallingSpeed = currentLevel["fallingSpeed"] as? Double
        let amountToKill = currentLevel["amountToKill"] as? Int
        
        regularLevelComponents()

        // Element spawned
        let makeEnemySpawn = SKAction.run(spawnEnemies)
        // Time duration between spawns"
        let enemyTimeBetweenSpawns = SKAction.wait(forDuration: TimeInterval(enemySpawnDelay!))
        // Spawn sequence - first spawn, then wait
        let enemySpawnSequence = SKAction.sequence([enemyTimeBetweenSpawns, makeEnemySpawn])
        // Reapeat the sequence
        let enemySpawnRepeat = SKAction.repeat(enemySpawnSequence, count: amountToKill!)
        // Move on to next level after last spawn has left the screen
        let endTheLevel = SKAction.run(checkTargetScore)
        let timeForlastEnemy = SKAction.wait(forDuration: TimeInterval(fallingSpeed!))
        let levelSequence = SKAction.sequence([enemySpawnRepeat, timeForlastEnemy, endTheLevel])
        
        // Execute
        self.run(levelSequence, withKey: "spawnYourFoe")
    }
    
    private func checkTargetScore() {
        (targetScore < 1) ? levelUp() : gameOver()
    }
    
    private func startStaticLevel() {
        
        didPlayerEnter = true
        currentGameState = .gameOn
        
        let currentLevel = levels![lvlNum-1]
        
        var numberOfRows = currentLevel["numberOfRows"] as? Int
        var rows: [Int] = [(currentLevel["row1"] as? Int) ?? 0,
                           (currentLevel["row2"] as? Int) ?? 0,
                           (currentLevel["row3"] as? Int) ?? 0]
        var maxRandom = currentLevel["maxRandom"] as? Int, minRandom = currentLevel["minRandom"] as? Int
        var bulletSpeed = currentLevel["bulletSpeed"] as? Int
        
        targetScore = rows[0]+rows[1]+rows[2]
        refreshTargetLbl()
        
        regularLevelComponents()
        
        // Make spriteNode just to get the size
        let tempNode = SKSpriteNode(imageNamed: "boss")
        tempNode.alpha = 0
        self.addChild(tempNode)
        
        // This loop make a row of enemies every time
        for row in 0...numberOfRows!-1 { //Its -1 just to fit the index
            
            var test = tempNode.size.width/2
            // Calculate the space between all enemies combined
            let spacesBetweenEnemies = (tempNode.size.width/2) * CGFloat(rows[row] - 1)
            // Calculates the size of the space that will make the enemy centerd
            let sideSpace = (self.size.width - (CGFloat(rows[row]) * tempNode.size.width) - spacesBetweenEnemies)/2
            
            for _ in 1...Int(rows[row]) {
                let enemy = SKSpriteNode(imageNamed: "boss")
                enemy.setScale(1)
                enemy.zPosition = 2
                enemy.position = CGPoint(x: sideSpace + test,
                                         y: self.size.height - (enemy.size.height * CGFloat(row+1)))
                
                let physicsBody = SKPhysicsBody(rectangleOf: tempNode.size)
                physicsBody.categoryBitMask = PhysicsCatgories.Enemies
                physicsBody.contactTestBitMask = PhysicsCatgories.Bullet
                physicsBody.affectedByGravity = false
                physicsBody.collisionBitMask = PhysicsCatgories.None
                enemy.physicsBody = physicsBody
                
                func aimAtThePlayer() {
                    shot(startPosition: enemy.position,
                         targetPosition: CGPoint(x: enemy.position.x,
                                                 y: -self.size.height),
                         bulletSpeed: Double(bulletSpeed!),
                         bulletScale: 0.2)
                }
                
                let timeBetweenAttacks = SKAction.wait(forDuration: random(max: maxRandom!, min: minRandom!))
                let startFighting = SKAction.run(aimAtThePlayer)
                let fightingActionSequence = SKAction.sequence([timeBetweenAttacks, startFighting])
                let fightforever = SKAction.repeatForever(fightingActionSequence)
                let bossSequence = SKAction.sequence([fightforever])
                enemy.run(bossSequence)
                
                self.addChild(enemy)
                test +=  tempNode.size.width*1.5
            }
            test = tempNode.size.width/2
        }
    }
    
    private func changeMusic(fileName: String, type: String) {
        
        backTrackAudio.stop()
        
        let filePath = Bundle.main.path(forResource: fileName, ofType: type)
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
    }

    private func regularLevelComponents() {
        
        // Move lives and score into screen
        let moveInfoBarToScreen = SKAction.moveTo(y: self.size.height - infoBarlbl.frame.size.height, duration: 0.3)
        infoBarlbl.run(moveInfoBarToScreen)
        
        let moveTargetToScreen = SKAction.move(to: CGPoint(x: gameArea.minX + targetScorelbl.frame.size.width/2,
                                                           y: self.size.height - targetScorelbl.frame.size.height),
                                               duration: 0.3)
        targetScorelbl.run(moveTargetToScreen)
        
        // Fade in all game elements
        self.enumerateChildNodes(withName: "Enemy") { enemy, _ in
            enemy.run(.fadeIn(withDuration: 0.2))
        }
        
        self.enumerateChildNodes(withName: "Bullet") { bullet, _ in
            bullet.run(.fadeIn(withDuration: 0.2))
        }
        
        let elements: [SKNode] = [infoBarlbl, player, targetScorelbl]
        for element in elements {
            element.run(.fadeIn(withDuration: 0.2))
        }
        
        // Fade out level label
        goLbl.run(.fadeOut(withDuration: 0.3))
        goalLbl.run(.fadeOut(withDuration: 0.5))
        
        // If scene has action - remove it (nececarry for leveling up)
        if self.action(forKey: "spawnYourFoe") != nil {
            self.removeAction(forKey: "spawnYourFoe")
        }
        
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

    // Effecting player's position by dragging our finger on the screen
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
