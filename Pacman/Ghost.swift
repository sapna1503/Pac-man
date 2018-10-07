//
//  Ghost.swift
//  Pacman
//
//  Created by Sapna Chandiramani on 12/02/17.
//  Copyright © 2017 Sapna Chandiramani. All rights reserved.
//

import Foundation
import SpriteKit

enum PlayerDirection {
    case southwest, southeast, northwest, northeast
}

enum GhostDirection {
    case top, bottom, left, right
}

class Ghost: SKNode {
    var playerLocation = PlayerDirection.southwest
    var currentDirection = GhostDirection.top
    var ghostSpeed: Float = 5
    var isStuck: Bool = false
    var previousLocation: CGPoint = CGPoint.zero
    var previousLocation2: CGPoint = CGPoint(x: 1, y: 1)


    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init (fromSKSFile image: String) {

        super.init()
        let ghostSprite = SKSpriteNode(imageNamed: image)
        addChild(ghostSprite)
        setPhysicsProperty(ghostSprite.size)

    }

    func setPhysicsProperty(_ size: CGSize) {
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = CollisionType.ghost.rawValue
        self.physicsBody?.collisionBitMask = CollisionType.boundary.rawValue | CollisionType.boundary2.rawValue | CollisionType.ghost.rawValue
        self.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.ghost.rawValue
        self.physicsBody?.allowsRotation = false
        self.zPosition = 90
    }

    func decideDirection() {
        let previousDirection = currentDirection
        switch (playerLocation) {
            case .southwest:
                if (previousDirection == .bottom)
                {
                    currentDirection = .left
                }
                else
                {
                    currentDirection = .bottom
                }
            case .southeast:
                if (previousDirection == .bottom)
                {
                    currentDirection = .right
                }
                else
                {
                    currentDirection = .bottom
                }

            case .northeast:
                if (previousDirection == .top)
                {
                    currentDirection = .right
                }
                else
                {
                    currentDirection = .top
                }
            case .northwest:
                if (previousDirection == .top)
                {
                    currentDirection = .left
                }
                else {
                    currentDirection = .top
                }
        }
    }



    func update() {
        if((Int(previousLocation2.y) == Int(previousLocation.y)) || (Int(previousLocation2.x) == Int(previousLocation.x)))
        {
            isStuck = true
            decideDirection()
        }

        let superDice = arc4random_uniform(2000)
        
        if (superDice == 0) {
            let diceRoll = arc4random_uniform(4)
            
            switch (diceRoll) {
            case 0:
                currentDirection = .left
            case 1:
                currentDirection = .bottom
            case 2:
                currentDirection = .right
            case 3:
                currentDirection = .top
            default:
                   update()
            }
        }
        previousLocation2 = previousLocation

        if (currentDirection == .top) {
            self.position = CGPoint(x: self.position.x, y: self.position.y + CGFloat(ghostSpeed))
            if(playerLocation == .northeast) {
                self.position = CGPoint(x: self.position.x + CGFloat(ghostSpeed), y: self.position.y)
            }
            else if(playerLocation == .northwest) {
                    self.position = CGPoint(x: self.position.x - CGFloat(ghostSpeed), y: self.position.y)
            }
        }
        else if (currentDirection == .bottom) {
                self.position = CGPoint(x: self.position.x, y: self.position.y - CGFloat(ghostSpeed))
                if(playerLocation == .southeast) {
                    self.position = CGPoint(x: self.position.x + CGFloat(ghostSpeed), y: self.position.y)
                }
                else if(playerLocation == .southwest) {
                        self.position = CGPoint(x: self.position.x - CGFloat(ghostSpeed), y: self.position.y)
                }
        }
        else if (currentDirection == .right) {
                self.position = CGPoint(x: self.position.x + CGFloat(ghostSpeed), y: self.position.y)
                if(playerLocation == .southeast) {
                    self.position = CGPoint(x: self.position.x, y: self.position.y - CGFloat(ghostSpeed))
                }
                    else if(playerLocation == .northeast) {
                        self.position = CGPoint(x: self.position.x, y: self.position.y + CGFloat(ghostSpeed))
                }
        }
        else if (currentDirection == .left) {
                self.position = CGPoint(x: self.position.x - CGFloat(ghostSpeed), y: self.position.y)
                if(playerLocation == .southwest) {
                    self.position = CGPoint(x: self.position.x, y: self.position.y - CGFloat(ghostSpeed))
                }
                    else if(playerLocation == .northwest) {
                        self.position = CGPoint(x: self.position.x, y: self.position.y + CGFloat(ghostSpeed))
                }
        }
        previousLocation = self.position
    }
    
    func collided() {
        switch(currentDirection)
        {
            case .top:
                currentDirection = .bottom
            case .bottom:
                currentDirection = .top
            case .left:
                currentDirection = .right
            case .right:
                currentDirection = .left
        }
    }
}
