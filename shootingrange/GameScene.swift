//
//  GameScene.swift
//  shootingrange
//
//  Created by Kristoffer Eriksson on 2020-10-24.
//

import SpriteKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
    var timeLabel: SKLabelNode!
    var count = 30 {
        didSet{
            timeLabel.text = "\(count)"
        }
    }
    var reloadLabel: SKLabelNode!
    
    var spawnTimer: Timer?
    
    var possibleTargets = ["target", "hardtarget", "woodtarget"]
    var bullets = 6
    var bulletArray = [SKSpriteNode]()
    var gameoverArray = [SKLabelNode]()
    
    var timeTimer: Timer?
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        addLine(from: CGPoint(x: 150, y: 100), to: CGPoint(x: 600, y: 100))
        addLine(from: CGPoint(x: 150, y: 200), to: CGPoint(x: 600, y: 200))
        addLine(from: CGPoint(x: 150, y: 300), to: CGPoint(x: 600, y: 300))
        
        //add scorelabel
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel?.fontSize = 20
        scoreLabel?.text = "Score: 0"
        scoreLabel.position = CGPoint(x: 368, y: 30)
        addChild(scoreLabel)
        
        //reload button
        reloadLabel = SKLabelNode(fontNamed: "Chalkduster")
        reloadLabel?.fontSize = 30
        reloadLabel?.text = "Reload!"
        reloadLabel?.name = "reload"
        reloadLabel.position = CGPoint(x: 564, y: 30)
        addChild(reloadLabel)
        
        // Countdown
        timeLabel = SKLabelNode(fontNamed: "Chalkduster")
        timeLabel?.fontSize = 20
        timeLabel?.text = "30"
        timeLabel.position = CGPoint(x: 564, y: 350)
        addChild(timeLabel)
        
        // add bullets nodes
        for i in 1...bullets{ createBullets(at: CGPoint(x: 150 + (i * 20), y: 40), count: i)}
        
        // add timer
        spawnTimer = Timer.scheduledTimer(timeInterval: 0.45, target: self, selector: #selector(createTarget), userInfo: nil, repeats: true)
        timeTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdownTimer), userInfo: nil, repeats: true)
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
    }
    
    func addLine(from: CGPoint, to: CGPoint){
        let line = SKShapeNode()
        let path = CGMutablePath()
        
        path.addLines(between: [from, to])
        line.path = path
        line.fillColor = .black
        line.strokeColor = .systemPink
        line.lineWidth = 2
        addChild(line)
    }
    
    @objc func countdownTimer(){
        
        if count < 1 {
            let gameOver = SKLabelNode(fontNamed: "chalkduster")
            gameOver.zPosition = 1
            gameOver.text = "Game Over"
            gameOver.position = CGPoint(x: 374, y: 240)
            gameOver.fontSize = 40
            gameoverArray.append(gameOver)
            addChild(gameOver)
            
            let endScore = SKLabelNode(fontNamed: "chalkduster")
            endScore.text = "Endscore is : \(score)"
            endScore.zPosition = 1
            endScore.position = CGPoint(x: 374, y: 175)
            endScore.fontSize = 30
            gameoverArray.append(endScore)
            addChild(endScore)
            
            let restart = SKLabelNode(fontNamed: "chalkduster")
            restart.text = "Restart?"
            restart.name = "restart"
            restart.zPosition = 1
            restart.position = CGPoint(x: 400, y: 120)
            restart.fontSize = 20
            gameoverArray.append(restart)
            addChild(restart)
            
        } else {
            count -= 1
        }
    }
    
    @objc func createTarget(){
        guard let target = possibleTargets.randomElement() else {return}
        
        let randomY = [100, 200, 300]
        let y = randomY.randomElement()
        
        let randomX = [0, 800]
        let x = randomX.randomElement()
        
        var directionVel: Int
        if x == 0 {
            directionVel = 200
            if target == "hardtarget"{
                directionVel = 400
            }
        } else {
            directionVel = -200
            if target == "hardtarget"{
                directionVel = -400
            }
        }
        
        let sprite = SKSpriteNode(imageNamed: target)
        sprite.position = CGPoint(x: x ?? 0, y: y ?? 230)
        sprite.size = CGSize(width: 50, height: 50)
        sprite.name = target
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.velocity = CGVector(dx: directionVel, dy: 0)
        sprite.physicsBody?.angularVelocity = 3
        sprite.physicsBody?.collisionBitMask = 0
        
        addChild(sprite)
        
    }
    
    func createBullets(at position: CGPoint, count: Int){
        
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.position = position
        bullet.size = CGSize(width: 15, height: 30)
        bullet.name = "bullet\(count)"
        bullet.physicsBody = SKPhysicsBody(texture: bullet.texture!, size: bullet.size)
        bulletArray.append(bullet)
        addChild(bullet)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        let tappedNode = nodes(at: location)
        
        for node in tappedNode{
            
            if node.name == "reload"{
                
                removeChildren(in: bulletArray)
                run(SKAction.playSoundFileNamed("reload.m4a", waitForCompletion: false))
                bullets = 7
                for i in 1...bullets{ createBullets(at: CGPoint(x: 150 + (i * 20), y: 40), count: i)}
                
            } else if node.name == "restart" {
                
                    removeChildren(in: bulletArray)
                    removeChildren(in: gameoverArray)
                    score = 0
                    count = 30
                    bullets = 6
                    spawnTimer?.invalidate()
                    timeTimer?.invalidate()
                    spawnTimer = Timer.scheduledTimer(timeInterval: 0.45, target: self, selector: #selector(createTarget), userInfo: nil, repeats: true)
                    timeTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdownTimer), userInfo: nil, repeats: true)
                    for i in 1...bullets{ createBullets(at: CGPoint(x: 150 + (i * 20), y: 40), count: i)}
                    
                
            } else {
                
                // disable touch if no ammo
                if bullets < 1 {
                    return
                }
                
                if node.name == "woodtarget"{
                    score -= 5
                    node.removeFromParent()
                    run(SKAction.playSoundFileNamed("shootingwood.m4a", waitForCompletion: false))
                } else if node.name == "target"{
                    score += 1
                    node.removeFromParent()
                    run(SKAction.playSoundFileNamed("shootingtarget.m4a", waitForCompletion: false))
                } else if node.name == "hardtarget"{
                    score += 3
                    node.removeFromParent()
                    run(SKAction.playSoundFileNamed("shootingtarget.m4a", waitForCompletion: false))
                }
                
            }
            
        }
        
        //remove single bullet
        for node in children{
            if node.name == "bullet\(bullets)"{
                node.removeFromParent()
            }
        }
        bullets -= 1
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        for node in children{
            if node.position.x < -20 || node.position.x > 800{
                node.removeFromParent()
            }
        }
        if count < 1 {
            
            spawnTimer?.invalidate()
        }
    }
}
