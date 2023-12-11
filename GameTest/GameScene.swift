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
    
    var foxTextures: [SKTexture] = []
    
    let playerCategory: UInt32 = 0x1 << 0
    let groundCategory: UInt32 = 0x1 << 1
    
    var lastXPixel = 0
    var gameRunning = true
    var canJump = false
    
    let IS_JUMP_CHUNK = 1

    override func didMove(to view: SKView) {
        
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
        
        physicsWorld.contactDelegate = self
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // controllo la collisione tra fox e terreno
        if (contact.bodyA.categoryBitMask == groundCategory) || (contact.bodyB.categoryBitMask == groundCategory ) {
            canJump = false
        }
       
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
                
        // controllo che la volpe possa saltare e con il tocco procedo a far effettuare il salto
        if !canJump {
            
            let jumpForce: CGFloat = 50.0
            
            playerFigure.physicsBody?.velocity = CGVector.zero
            
            // Adjust the dy value for a faster jump
            let jumpAction = SKAction.applyImpulse(CGVector(dx: 0, dy: jumpForce), duration: 0.5)
            playerFigure.run(jumpAction)
            player.startEndJump()
            canJump = true
            
            print("jump")
        }
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
                    endGame()
            
                }
    }
    func endGame() {
            gameRunning = false
        

            // messaggio di fine gioco
            let gameOverLabel = SKLabelNode(text: "Game Over")
            gameOverLabel.fontSize = 50
            gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
            gameOverLabel.zPosition = 2
            gameOverLabel.fontColor = .red
            
            background.position = CGPoint(x: size.width / 2, y: size.height / 2)
            cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
            addChild(gameOverLabel)
        }

    func generateRandomTerrain(isStartTerrain: Bool) {
        let terrainTypes = ["terrain1", "terrain2", "terrain3"]
        let terrainWidths = [48, 32, 32]
        
        
        if isStartTerrain {
            for _ in 0..<40{
                let randomTerrainIndex = Int(arc4random_uniform(UInt32(terrainTypes.count)))
                let randomWidth = terrainWidths[randomTerrainIndex]
                let randomType = terrainTypes[randomTerrainIndex]
                
                let terrain = SKSpriteNode(imageNamed: randomType)
                terrain.size = CGSize(width: randomWidth, height: 38)

                let randomX = lastXPixel + randomWidth / 2
                terrain.position = CGPoint(x: randomX, y: Int(-frame.size.height)/2 + 80)

                terrain.physicsBody = SKPhysicsBody(rectangleOf: terrain.size)
                terrain.physicsBody?.isDynamic = false
                terrain.physicsBody?.categoryBitMask = groundCategory
                terrain.physicsBody?.contactTestBitMask = playerCategory
                terrain.physicsBody?.restitution = 0 // No bouncing

                lastXPixel = randomX + randomWidth / 2

                terrain.zPosition = 1
                self.addChild(terrain)
            }
        }
        else
        {
            for _ in 0..<40{
                if(Int(arc4random_uniform(UInt32(10))) == IS_JUMP_CHUNK)
                {
                    let terrain = SKSpriteNode(imageNamed: "endt2")
                    terrain.position = CGPoint(x: lastXPixel + 32 / 2, y: Int(-frame.size.height)/2 + 80)
                    terrain.size = CGSize(width: 32, height: 38)
                    terrain.physicsBody = SKPhysicsBody(rectangleOf: terrain.size)
                    terrain.physicsBody?.isDynamic = false
                    terrain.physicsBody?.categoryBitMask = groundCategory
                    terrain.physicsBody?.contactTestBitMask = playerCategory
                    terrain.physicsBody?.restitution = 0 // No bouncing
                    lastXPixel = lastXPixel + 32 / 2
                    terrain.zPosition = 1
                    self.addChild(terrain)
                    
                    lastXPixel = lastXPixel + 150 + Int(arc4random_uniform(UInt32(2)))*50
                    
                    let terrain2 = SKSpriteNode(imageNamed: "endt1")
                    terrain2.position = CGPoint(x: lastXPixel + 32 / 2, y: Int(-frame.size.height)/2 + 80)
                    terrain2.size = CGSize(width: 32, height: 38)
                    terrain2.physicsBody = SKPhysicsBody(rectangleOf: terrain.size)
                    terrain2.physicsBody?.isDynamic = false
                    terrain2.physicsBody?.categoryBitMask = groundCategory
                    terrain2.physicsBody?.contactTestBitMask = playerCategory
                    terrain2.physicsBody?.restitution = 0 // No bouncing
                    terrain2.zPosition = 1
                    lastXPixel = lastXPixel + 32 / 2
                    self.addChild(terrain2)
                }
                else
                {
                    let randomTerrainIndex = Int(arc4random_uniform(UInt32(terrainTypes.count)))
                    let randomWidth = terrainWidths[randomTerrainIndex]
                    let randomType = terrainTypes[randomTerrainIndex]
                    
                    let terrain = SKSpriteNode(imageNamed: randomType)
                    terrain.size = CGSize(width: randomWidth, height: 38)

                    let randomX = lastXPixel + randomWidth / 2
                    terrain.position = CGPoint(x: randomX, y: Int(-frame.size.height)/2 + 80)

                    terrain.physicsBody = SKPhysicsBody(rectangleOf: terrain.size)
                    terrain.physicsBody?.isDynamic = false
                    terrain.physicsBody?.categoryBitMask = groundCategory
                    terrain.physicsBody?.contactTestBitMask = playerCategory
                    terrain.physicsBody?.restitution = 0 // No bouncing

                    lastXPixel = randomX + randomWidth / 2

                    terrain.zPosition = 1
                    self.addChild(terrain)
                }
            }
        }
    }
}
