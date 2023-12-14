//
//  GameScene.swift
//  GameTest
//
//  Created by Luca Gargiulo on 04/12/23.
//

import SpriteKit
import GameplayKit



class GameScene: SKScene, SKPhysicsContactDelegate {

    var background = SKSpriteNode(imageNamed: "sky")
    var playerFigure = SKSpriteNode(imageNamed: "fox1")
    var player = Player(x_position: 0, y_position: 0)
    var cameraNode = SKCameraNode()
    var numeroCollisioni = 0
    let jumpSound = SKAudioNode(fileNamed: "Jump Effect.mp3")
    let backgroundSound = SKAudioNode(fileNamed: "Music.mp3")
   
    var foxTextures: [SKTexture] = []
    var onAir : Bool = false
    let playerCategory: UInt32 = 0x1 << 0
    let groundCategory: UInt32 = 0x1 << 1
    
    let terrainHeight = 38
    
    var lastXPixel = 0
    var gameRunning = true
//    var canJump = false
    
    let IS_JUMP_CHUNK = 1
    
    var terrainYOffset = 100;

    override func didMove(to view: SKView) {
            
            
            self.addChild(backgroundSound)
            
        for i in 1...8 {
             let texture = SKTexture(imageNamed: "fox\(i)")
             foxTextures.append(texture)
        }
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.81)
        physicsWorld.contactDelegate = self

        self.camera = cameraNode
        
        self.addChild(cameraNode)

        background.position = CGPoint(x: 0, y: 0)
        background.size = self.size
        background.zPosition = -1

        playerFigure.position = CGPoint(x: player.getX(), y: player.getY())
        playerFigure.size = CGSize(width: Player.PLAYER_WIDTH, height: Player.PLAYER_HEIGTH)

        playerFigure.physicsBody = SKPhysicsBody(texture: playerFigure.texture!, size: playerFigure.size)
        playerFigure.physicsBody?.affectedByGravity = true
        playerFigure.physicsBody?.allowsRotation = false // Disable rotation
        playerFigure.physicsBody?.isDynamic = true
        playerFigure.physicsBody?.categoryBitMask = playerCategory
        playerFigure.physicsBody?.collisionBitMask = groundCategory
        playerFigure.physicsBody?.contactTestBitMask = groundCategory
        playerFigure.physicsBody?.restitution = 0 // No bouncing
        playerFigure.physicsBody?.linearDamping = 0 // No linear damping
        playerFigure.physicsBody?.angularDamping = 0 // No angular damping

        playerFigure.zPosition = 1

        lastXPixel = Int(-frame.size.width)/2
        generateRandomTerrain(isStartTerrain: true)
        
        self.addChild(background)
        self.addChild(playerFigure)
        
        self.addChild(jumpSound)
        jumpSound.run(SKAction.stop())
        
        physicsWorld.contactDelegate = self
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let playerPhysicsBody = playerFigure.physicsBody {
            // Check if the player is on the ground
            if playerPhysicsBody.velocity.dy == 0 {
                jumpSound.run(SKAction.play())
                let jumpForce: CGFloat = 30.0
                playerFigure.physicsBody?.applyImpulse(CGVector(dx: 0, dy: jumpForce))
            }
        }
    }

    // Update your touchesEnded method
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let ritardo = SKAction.wait(forDuration: 1.0)
        let azioneSuccessiva = SKAction.run {
            self.jumpSound.run(SKAction.stop())
        }
        let sequenza = SKAction.sequence([ritardo, azioneSuccessiva])
        playerFigure.run(sequenza)
    }
    
    
    var frameCounter: Int = 0
    override func update(_ currentTime: TimeInterval) {
        // Increment the frame counter
        frameCounter += 1

        // Change the fox figure every 10 frames
        if frameCounter % 50 == 0 {
            // Animate the fox
            let animationAction = SKAction.animate(with: foxTextures, timePerFrame: 0.1)
            playerFigure.run(animationAction)

            // Reset the frame counter
            frameCounter = 0
        }

        let moveAction = SKAction.moveBy(x: 3.0, y: 0, duration: 0)
        playerFigure.run(moveAction)

        background.position.x = playerFigure.position.x
        cameraNode.position.x = playerFigure.position.x
        
        if Int(playerFigure.position.x + frame.width/2) > lastXPixel {
            generateRandomTerrain(isStartTerrain: false)
        }
        
        if playerFigure.position.y < -500 {
            gameRunning = false
            playerFigure.removeFromParent()
            let scores : Int = Int(playerFigure.position.x)
            UserDefaults.standard.set(scores, forKey: "Score")
            UserDefaults.standard.synchronize()
          
            if  gameRunning == false {
                let gameOverScene = GameOverScene(size: size)
                gameOverScene.scaleMode = scaleMode
                view!.presentScene(gameOverScene)
            
            }
                    
            
        }
    }
   
    func generateRandomTerrain(isStartTerrain: Bool) {
        if isStartTerrain {
            generateStartTerrain()
        } else {
            generateRegularTerrain()
        }
    }

    func generateStartTerrain() {
        let terrainTypes = ["terrain1", "terrain2", "terrain3"]
        let terrainWidths = [48, 32, 32]

        for _ in 0..<40 {
            let (randomType, randomWidth) = getRandomTerrainTypeAndWidth(types: terrainTypes, widths: terrainWidths)
            let terrain = createTerrain(imageNamed: randomType, width: randomWidth, height: terrainHeight)
            positionAndAddTerrain(terrain, yOffset: terrainYOffset)
            positionAndAddUnderground(lastWidth: randomWidth, yOffset: terrainYOffset)
        }
    }

    func generateRegularTerrain() {
        for _ in 0..<40 {
            if shouldSpawnJumpChunk() {
                generateJumpChunk()
            } else {
                let terrainTypes = ["terrain1", "terrain2", "terrain3"]
                let terrainWidths = [48, 32, 32]
                let (randomType, randomWidth) = getRandomTerrainTypeAndWidth(types: terrainTypes, widths: terrainWidths)
                let terrain = createTerrain(imageNamed: randomType, width: randomWidth, height: terrainHeight)
                positionAndAddTerrain(terrain, yOffset: terrainYOffset)
                positionAndAddUnderground(lastWidth: randomWidth, yOffset: terrainYOffset)

                if Int(arc4random_uniform(UInt32(10))) == 1 {
                    spawnTree(at: CGPoint(x: lastXPixel - 20, y: Int(-frame.size.height)/2 + 206), yOffset: terrainYOffset)
                }
            }
        }
    }
    
    func positionAndAddUnderground(lastWidth: Int, yOffset: Int) {
        let terrainHeight = 64
        var backgroundTerrainX = lastXPixel - (lastWidth) / 2
        var actualY = yOffset + 38
        var terrainName = (lastWidth == 32) ? "underground1" : "underground2"

        while actualY > -64 {
            let terrain = createTerrain(imageNamed: terrainName, width: lastWidth, height: terrainHeight)
            terrain.position = CGPoint(x: backgroundTerrainX, y: Int(-frame.size.height) / 2 + actualY)
            self.addChild(terrain)
            actualY -= terrainHeight;
        }
    }

    func generateJumpChunk() {
        let terrain = createTerrain(imageNamed: "endt2", width: 32, height: terrainHeight)
        positionAndAddTerrain(terrain, yOffset: terrainYOffset)
        positionAndAddUnderground(lastWidth: 32, yOffset: terrainYOffset)
        
        lastXPixel += 100 + Int(arc4random_uniform(UInt32(2))) * 50

        adjustTerrainYOffset()
        
        let terrain2 = createTerrain(imageNamed: "endt1", width: 32, height: terrainHeight)
        positionAndAddTerrain(terrain2, yOffset: terrainYOffset)
        positionAndAddUnderground(lastWidth: 32, yOffset: terrainYOffset)
    }

    func getRandomTerrainTypeAndWidth(types: [String], widths: [Int]) -> (String, Int) {
        let randomTerrainIndex = Int(arc4random_uniform(UInt32(types.count)))
        let randomType = types[randomTerrainIndex]
        let randomWidth = widths[randomTerrainIndex]
        return (randomType, randomWidth)
    }

    func createTerrain(imageNamed: String, width: Int, height: Int) -> SKSpriteNode {
        let terrain = SKSpriteNode(imageNamed: imageNamed)
        terrain.size = CGSize(width: width, height: height)
        terrain.physicsBody = SKPhysicsBody(rectangleOf: terrain.size)
        terrain.physicsBody?.isDynamic = false
        terrain.physicsBody?.categoryBitMask = groundCategory
        terrain.physicsBody?.contactTestBitMask = playerCategory
        terrain.physicsBody?.restitution = 0 // No bouncing
        terrain.zPosition = 1
        return terrain
    }

    func positionAndAddTerrain(_ terrain: SKSpriteNode, yOffset: Int) {
        let randomX = lastXPixel + Int(terrain.size.width) / 2
        terrain.position = CGPoint(x: randomX, y: Int(-frame.size.height)/2 + 80 + yOffset)
        lastXPixel = randomX + Int(terrain.size.width) / 2
        self.addChild(terrain)
    }

    func shouldSpawnJumpChunk() -> Bool {
        return Int(arc4random_uniform(UInt32(3))) == IS_JUMP_CHUNK
    }

    func adjustTerrainYOffset() {
        
        if(Int(arc4random_uniform(UInt32(2))) == 1)
        {
            terrainYOffset += (Int(arc4random_uniform(UInt32(2)))) * 20
            
            if terrainYOffset > 380 {
                terrainYOffset = 380;
            }
        }
        else {
            terrainYOffset += (Int(arc4random_uniform(UInt32(2))) - 2) * 20
            
            if terrainYOffset < 0 {
                terrainYOffset = 0
            }
        }
    }
    
    func spawnTree(at position: CGPoint, yOffset: Int) {
        let isMirrored = Bool.random()

        // Create a tree with a random color
        let treeColor = generateRandomTreeColor()
        let treeImageName = isMirrored ? "tree_mirrored" : "tree"
        
        let tree = SKSpriteNode(imageNamed: treeImageName)
        tree.size = CGSize(width: 123 * 2, height: 114 * 2)
        tree.position = CGPoint(x: position.x, y: position.y + CGFloat(yOffset))
        tree.zPosition = 0
        tree.color = treeColor
        tree.colorBlendFactor = 1.0

        self.addChild(tree)
    }

    func generateRandomTreeColor() -> UIColor {
        // Generate random RGB values
        let red = CGFloat.random(in: 0.5...1.0)
        let green = CGFloat.random(in: 0.3...0.7)
        let blue = CGFloat.random(in: 0.1...0.5)

        // Create a UIColor with the random RGB values
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }

    
    
//    func aggiungiPunteggio(_ nuovoPunteggio: Int) {
//        var miglioriPunteggi = UserDefaults.standard.array(forKey: "MiglioriPunteggi") as? [Int] ?? []
//
//        // Aggiungi il nuovo punteggio solo se è più grande di almeno uno dei primi 5
//        if miglioriPunteggi.isEmpty || nuovoPunteggio > miglioriPunteggi.last! {
//            miglioriPunteggi.append(nuovoPunteggio)
//            miglioriPunteggi.sort(by: >) // Ordina in ordine decrescente
//            miglioriPunteggi = Array(miglioriPunteggi.prefix(5)) // Mantieni solo i primi 5
//
//            UserDefaults.standard.set(miglioriPunteggi, forKey: "MiglioriPunteggi")
//            print("Nuovo punteggio aggiunto con successo.")
//        } else {
//            print("Il punteggio non è sufficiente per entrare nella lista dei migliori 5.")
//        }
//    }
}
