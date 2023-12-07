//
//  GameScene.swift
//  GameTest
//
//  Created by Luca Gargiulo on 04/12/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var prova : String = "prova"
    var background = SKSpriteNode(imageNamed: "sky")
    var playerFigure = SKSpriteNode(imageNamed: "fox1")
    var player = Player(x_position: 0, y_position: 0)
    var cameraNode = SKCameraNode()
    
    var foxTextures: [SKTexture] = []
    
    let playerCategory: UInt32 = 0x1 << 0
    let groundCategory: UInt32 = 0x1 << 1

    override func didMove(to view: SKView) {
        
        for i in 1...8 {
             let texture = SKTexture(imageNamed: "fox\(i)")
             foxTextures.append(texture)
         }
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.81)

        // Set up the camera
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

        generateRandomTerrain()
        
        self.addChild(background)
        self.addChild(playerFigure)
        
        physicsWorld.contactDelegate = self
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == groundCategory) || (contact.bodyB.categoryBitMask == groundCategory) {
            player.startEndJump()
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !player.isJumping() {
            // Adjust the dy value for a faster jump
            let jumpAction = SKAction.applyImpulse(CGVector(dx: 0, dy: 50), duration: 0.5)
            playerFigure.run(jumpAction)

            player.startEndJump()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
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

        // Move the fox continuously
        let moveAction = SKAction.moveBy(x: 1.0, y: 0, duration: 0)
        playerFigure.run(moveAction)

        // Update positions of background and camera
        background.position.x = playerFigure.position.x
        cameraNode.position.x = playerFigure.position.x
    }
    
    func generateRandomTerrain() {
        let terrainTypes = ["terrain1", "terrain2", "terrain3"]
        let terrainWidths = [48, 32, 32]
        var lastXPixel = Int(-frame.size.width)/2
        
        for _ in 0..<50{
            let randomTerrainIndex = Int(arc4random_uniform(UInt32(terrainTypes.count)))
            let randomWidth = terrainWidths[randomTerrainIndex]
            let randomType = terrainTypes[randomTerrainIndex]
            
            let terrain = SKSpriteNode(imageNamed: randomType)
            terrain.size = CGSize(width: randomWidth, height: 38)

            // Update randomX based on the accumulated width
            let randomX = lastXPixel + randomWidth / 2
            terrain.position = CGPoint(x: randomX, y: Int(-frame.size.height)/2 + 70)

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
