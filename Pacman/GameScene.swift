//
//  GameScene.swift
//  Pacman
//
//  Created by Sapna Chandiramani on 12/02/17.
//  Copyright © 2017 Sapna Chandiramani. All rights reserved.
//

import SpriteKit
import GameplayKit

enum CollisionType: UInt32 {

    case player = 1
    case boundary = 2
    case topSensor = 4
    case bottomSensor = 8
    case rightSensor = 16
    case leftSensor = 32
    case coin = 64
    case ghost = 128
    case boundary2 = 256
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var playerSpeed: CGFloat = 4
    var ghostSpeed: CGFloat = 1
    
    var player: Player?
    var playerLocation: CGPoint = CGPoint.zero
    var playerIsDead: Bool = false
    
    var mazeWorld: SKNode = SKNode()

    var ghostCount: Int = 0
    var ghostDictionary: [String: CGPoint] = [:]
    var ghostLogic: Double = 1
    
    var coinsAcquired: Int = 0
    var coinsTotal: Int = 0
    
    var scoreLabel: SKLabelNode?
    var livesLeftLabel: SKLabelNode?
    var showPhysics: Bool = false

    override func didMove(to view: SKView) {
        view.showsPhysics = showPhysics
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        mazeWorld = childNode(withName: "mazeWorld")!
        playerLocation = mazeWorld.childNode(withName: "StartingPoint")!.position
        player = Player()
        player?.position = playerLocation
        mazeWorld.addChild(player!)
        player?.speed = playerSpeed

        let delayAction: SKAction = SKAction.wait(forDuration: 0.5)
        self.run(delayAction, completion: {
            let swipeTop: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipedTop(_:)))
            swipeTop.direction = .up
            view.addGestureRecognizer(swipeTop)

            let swipeBottom: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipedBottom(_:)))
            swipeBottom.direction = .down
            view.addGestureRecognizer(swipeBottom)

            let swipeLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipedLeft(_:)))
            swipeLeft.direction = .left
            view.addGestureRecognizer(swipeLeft)

            let swipeRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipedRight(_:)))
            swipeRight.direction = .right
            view.addGestureRecognizer(swipeRight)
        })

        createBoundaryWall()
        createCoin()
        createGhosts()
        updatePlayerLocationToGhosts()
        createScoreLabel()
        createLivesLeftLabel()
    }

    func createScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel!.horizontalAlignmentMode = .left
        scoreLabel!.verticalAlignmentMode = .center
        scoreLabel!.fontColor = SKColor.yellow
        scoreLabel!.text = "Score: " + String(coinsAcquired)
        addChild(scoreLabel!)
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            scoreLabel!.position = CGPoint(x: -(self.size.width / 2.3), y: (self.size.height) / 2.25)
        }
    }


    func createBoundaryWall() {
        mazeWorld.enumerateChildNodes(withName: "boundary") {
            node, stop in
            if let boundary = node as? SKSpriteNode {
                let rect: CGRect = CGRect(origin: boundary.position, size: boundary.size)
                let newBoundary: Boundary = Boundary(fromSKSWithRect: rect, isEdge: false)
                self.mazeWorld.addChild(newBoundary)
                newBoundary.position = boundary.position
            }
        }
    }

    func createCoin() {
        mazeWorld.enumerateChildNodes(withName: "star") {
            node, stop in
            if let coin = node as? SKSpriteNode {
                let newCoin: Coin = Coin()
                self.mazeWorld.addChild(newCoin)
                newCoin.position = coin.position
                self.coinsTotal += 1
                coin.removeFromParent()
            }
        }
    }

    func createGhosts() {
        mazeWorld.enumerateChildNodes(withName: "ghost*") {
            node, stop in
            if let ghost = node as? SKSpriteNode {
                self.ghostCount += 1

                let newGhost: Ghost = Ghost(fromSKSFile: ghost.name!)
                self.mazeWorld.addChild(newGhost)
                newGhost.position = ghost.position
                newGhost.name = ghost.name!
                newGhost.ghostSpeed = Float(self.ghostSpeed)
                self.ghostDictionary.updateValue(newGhost.position, forKey: newGhost.name!)
                ghost.removeFromParent()

            }
        }
    }

    override func update(_ currentTime: TimeInterval) {
        if (playerIsDead == false)
            {
            player!.update()
            mazeWorld.enumerateChildNodes(withName: "ghost*") {
                node, stop in
                if let ghost = node as? Ghost
                    {
                    if (ghost.isStuck == true)
                        {
                        ghost.playerLocation = self.getPlayerLocation(ghost)
                        ghost.decideDirection()
                        ghost.isStuck = false
                    }
                    ghost.update()
                }
            }
        }
        else
        {
            resetGhost()
            player?.rightBlocked = false
            player!.position = playerLocation
            playerIsDead = false
            player?.currentDirection = .right
            player!.desiredDirection = .none
            player!.moveRight()
        }

    }

    @objc func swipedTop(_ sender: UISwipeGestureRecognizer) {
        player!.moveTop()
    }
    @objc func swipedBottom(_ sender: UISwipeGestureRecognizer) {
        player!.moveBottom()
    }
    @objc func swipedLeft(_ sender: UISwipeGestureRecognizer) {
        player!.moveLeft()
    }
    @objc func swipedRight(_ sender: UISwipeGestureRecognizer) {
        player!.moveRight()
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        switch(contactMask) {
            case CollisionType.ghost.rawValue | CollisionType.ghost.rawValue:
                if let ghost1 = contact.bodyA.node as? Ghost {
                    ghost1.collided()
                }
                    else if let ghost2 = contact.bodyB.node as? Ghost {
                        ghost2.collided()
                }
                    else if let ghost3 = contact.bodyB.node as? Ghost {
                        ghost3.collided()
                }
                    else if let ghost4 = contact.bodyB.node as? Ghost {
                        ghost4.collided()
                }

            case CollisionType.player.rawValue | CollisionType.ghost.rawValue:
                reloadLevel()

            case CollisionType.boundary.rawValue | CollisionType.topSensor.rawValue:
                player?.topContactStarted()

            case CollisionType.boundary.rawValue | CollisionType.bottomSensor.rawValue:
                player?.bottomContactStarted()

            case CollisionType.boundary.rawValue | CollisionType.leftSensor.rawValue:
                player?.leftContactStarted()

            case CollisionType.boundary.rawValue | CollisionType.rightSensor.rawValue:
                player?.rightContactStarted()

            case CollisionType.player.rawValue | CollisionType.coin.rawValue:
                if let coin = contact.bodyA.node as? Coin
                    {
                    coin.removeFromParent()
                    self.coinsAcquired += 1
                    scoreLabel!.text = "Score: " + String(coinsAcquired)
                }
                    else if let coin = contact.bodyB.node as? Coin
                            {
                        coin.removeFromParent()
                        self.coinsAcquired += 1
                        scoreLabel!.text = "Score: " + String(coinsAcquired)
                }
                if(coinsAcquired == coinsTotal)
                {
                    resetGhost()
                    player?.rightBlocked = false
                    player!.position = playerLocation
                    playerIsDead = false
                    player?.currentDirection = .right
                    player!.desiredDirection = .none
                    player!.moveRight()
                }
            default: return
        }

    }
    func didEnd(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        switch(contactMask) {
            case CollisionType.boundary.rawValue | CollisionType.topSensor.rawValue:
                player?.topContactEnd()

            case CollisionType.boundary.rawValue | CollisionType.bottomSensor.rawValue:
                player?.bottomContactEnd()

            case CollisionType.boundary.rawValue | CollisionType.leftSensor.rawValue:
                player?.leftContactEnd()

            case CollisionType.boundary.rawValue | CollisionType.rightSensor.rawValue:
                player?.rightContactEnd()

            default: return
        }
    }

    func updatePlayerLocationToGhosts () {
        let ghostAction: SKAction = SKAction.wait(forDuration: ghostLogic)
        self.run(ghostAction, completion:
            {
                self.updatePlayerLocationToGhosts()
        })

        mazeWorld.enumerateChildNodes(withName: "ghost*") {
            node, stop in
            if let ghost = node as? Ghost
            {
                ghost.playerLocation = self.getPlayerLocation(ghost)
            }
        }
    }


    func getPlayerLocation(_ ghost: Ghost) -> PlayerDirection {

        if (self.player!.position.x < ghost.position.x && self.player!.position.y < ghost.position.y) {
            return PlayerDirection.southwest
        }
        else if (self.player!.position.x > ghost.position.x && self.player!.position.y < ghost.position.y) {
            return PlayerDirection.southeast
        }
        else if (self.player!.position.x < ghost.position.x && self.player!.position.y > ghost.position.y) {
            return PlayerDirection.northwest

        }
        else if (self.player!.position.x > ghost.position.x && self.player!.position.y > ghost.position.y) {
            return PlayerDirection.northeast
        }
        else {
            return PlayerDirection.northeast
        }
    }

    func reloadLevel() {
        loseLife()
        playerIsDead = true
    }
    
    func resetGhost()
    {
        for (name, location) in ghostDictionary {
            mazeWorld.childNode(withName: name)?.position = location
        }
    }

    func loadNextLevel() {
        currentLevel += 1
        currentGameFile = gameFile
        let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene
        scene!.scaleMode = .aspectFill
        self.view?.presentScene(scene!, transition: SKTransition.fade(withDuration: 0))
    }

    func loseLife() {
        livesLeft = livesLeft - 1
        if (livesLeft == 0) {
            livesLeftLabel!.text = "Game Over"
            livesLeftLabel!.position = CGPoint.zero
            livesLeftLabel!.horizontalAlignmentMode = .center
            livesLeftLabel!.verticalAlignmentMode = .center

            let scaleAction: SKAction = SKAction.scale(to: 0.2, duration: 3)
            let fadeAction: SKAction = SKAction.fadeAlpha(to: 0, duration: 3)
            let group: SKAction = SKAction.group([scaleAction, fadeAction])

            mazeWorld.run(group, completion: {
                self.resetGame()
            })
            livesLeft = 0
        }
            else
        {
            livesLeftLabel!.text = "Lives Left: " + String(livesLeft)
        }
    }

    func resetGame() {
        livesLeft = 3
        coinsAcquired = 0
        currentLevel = 0
        currentGameFile = gameFile

        let scene = GameScene.unarchiveFromFile(currentGameFile) as? GameScene
        scene!.scaleMode = .aspectFill
        self.view?.presentScene(scene!, transition: SKTransition.fade(withDuration: 0))
    }

    func createLivesLeftLabel()
    {
        livesLeftLabel = SKLabelNode(fontNamed: "Chalkduster")
        livesLeftLabel!.horizontalAlignmentMode = .left
        livesLeftLabel!.verticalAlignmentMode = .center
        livesLeftLabel!.fontColor = SKColor.yellow
        livesLeftLabel!.text = "Lives Left: " + String(livesLeft)
        addChild(livesLeftLabel!)

        if (UIDevice.current.userInterfaceIdiom == .phone) {
            livesLeftLabel!.position = CGPoint(x: (self.size.width / 5.25), y: (self.size.height) / 2.25)
        }
    }



}
