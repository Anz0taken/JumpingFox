//
//  GameOverScene.swift
//  GameTest
//
//  Created by Domenico Mennillo on 12/12/23.
//
import SpriteKit


class GameOverScene: SKScene {

    override func didMove(to view: SKView) {
        // Questo metodo viene chiamato quando la scena è stata presentata

        // Aggiungi il background
        let background = SKSpriteNode(imageNamed: "sky") // Sostituisci "backgroundImage" con il nome effettivo dell'immagine
     
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = self.size
        background.zPosition = -1
        addChild(background)

       
//        aggiungiPunteggio(scores)
//
       
        
       
            let gameOverLabel = SKSpriteNode(imageNamed: "Game Over Fatt")
            gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 50)
        
        let mioScore = UserDefaults.standard.integer(forKey: "Score")
        let scoreLabel = SKLabelNode(text: "Score : \(mioScore) ")
            scoreLabel.fontName = "Aclonica"
            scoreLabel.fontSize = 50
            scoreLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 160)
            scoreLabel.zPosition = 2
            scoreLabel.fontColor = .red
          
        
            addChild(gameOverLabel)
            addChild(scoreLabel)
        // Aggiungi un pulsante per ricominciare il gioco
        let restartButton = SKSpriteNode(imageNamed: "Start") // Sostituisci "restartButtonImage" con il nome effettivo dell'immagine del pulsante
        restartButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 100)
        restartButton.name = "restartButton"
        addChild(restartButton)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Gestisci i tocchi sulla scena
        for touch in touches {
            let location = touch.location(in: self)

            // Controlla se il tocco è avvenuto sul pulsante di ricomincia
            if let node = atPoint(location) as? SKSpriteNode, node.name == "restartButton" {
                // Avvia il tuo metodo per ricominciare il gioco, ad esempio:
                restartGame()
            }
        }
    }

    // Aggiungi qui la logica per ricominciare il gioco
    func restartGame() {
        // Implementa la logica per reinizializzare il gioco
        // Ad esempio, puoi transizionare verso la tua scena di gioco principale
        if let gameScene = GameScene(fileNamed: "GameScene") {
            gameScene.scaleMode = .aspectFill
            view?.presentScene(gameScene)
        }
    }
}
