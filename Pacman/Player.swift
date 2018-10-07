//
//  Player.swift
//  Pacman
//
//  Created by Sapna Chandiramani on 12/02/17.
//  Copyright © 2017 Sapna Chandiramani. All rights reserved.
//

import Foundation
import SpriteKit

enum Direction {
    case top, bottom, left, right, none
}

enum DesiredDirection {
    case top, bottom, left, right, none
}

class Player: SKNode {
    
    var playerSprite: SKSpriteNode?
    var playerSpeed: Float = 5
    var currentDirection = Direction.right
    var desiredDirection = DesiredDirection.none
    
    var downBlocked: Bool = false
    var topBlocked: Bool = false
    var leftBlocked: Bool = false
    var rightBlocked: Bool = false
    
    var nodeTop: SKNode?
    var nodeBottom: SKNode?
    var nodeLeft: SKNode?
    var nodeRight: SKNode?
    var buffer: Int = 25
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init () {
        
        super.init()
        playerSprite = SKSpriteNode(imageNamed: "player")
        addChild(playerSprite!)
        
        let largerSize = CGSize(width: (playerSprite?.size.width)! * 1.2, height: (playerSprite?.size.height)! * 1.2)
        self.physicsBody = SKPhysicsBody(rectangleOf: largerSize)
        self.physicsBody?.friction = 0
        self.physicsBody?.isDynamic = true
        self.physicsBody?.restitution = 0
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = CollisionType.boundary.rawValue | CollisionType.coin.rawValue
        
        nodeTop = SKNode()
        addChild(nodeTop!)
        nodeTop!.position = CGPoint(x: 0, y: buffer)
        createTopSensorBody(whileTravellingTopOrBottom: false)
        
        nodeBottom = SKNode()
        addChild(nodeBottom!)
        nodeBottom!.position = CGPoint(x: 0, y: -buffer)
        createBottomSensorBody(whileTravellingTopOrBottom: false)
        
        nodeRight = SKNode()
        addChild(nodeRight!)
        nodeRight!.position = CGPoint(x: buffer, y: 0)
        createRightSensorPhysicsBody(whileTravellingLeftOrRight: true)
        
        nodeLeft = SKNode()
        addChild(nodeLeft!)
        nodeLeft!.position = CGPoint(x: -buffer, y: 0)
        createLeftSensorPhysicsBody(whileTravellingLeftOrRight: true)
    }
    
    func update() {
        switch currentDirection {
        case .right:
            self.position = CGPoint(x: self.position.x + CGFloat(playerSpeed), y: self.position.y)
            playerSprite!.zRotation = CGFloat(degreesToRadians(0))
        case .left:
            self.position = CGPoint(x: self.position.x - CGFloat(playerSpeed), y: self.position.y)
            playerSprite!.zRotation = CGFloat(degreesToRadians(180))
        case .top:
            self.position = CGPoint(x: self.position.x, y: self.position.y + CGFloat(playerSpeed))
            playerSprite!.zRotation = CGFloat(degreesToRadians(90))
        case .bottom:
            self.position = CGPoint(x: self.position.x, y: self.position.y - CGFloat(playerSpeed))
            playerSprite!.zRotation = CGFloat(degreesToRadians(-90))
        case .none:
            self.position = CGPoint(x: self.position.x, y: self.position.y)
        }
    }
    
    func degreesToRadians(_ degrees: Double) -> Double {
        return degrees / 180 * Double.pi
    }
    

    func moveTop() {
        if (topBlocked == true)
        {
            desiredDirection = DesiredDirection.top
        }
        else
        {
            currentDirection = .top
            desiredDirection = .none
            downBlocked = false
            
            self.physicsBody?.isDynamic = true
            
            createTopSensorBody(whileTravellingTopOrBottom : true)
            createBottomSensorBody(whileTravellingTopOrBottom: true)
            createLeftSensorPhysicsBody(whileTravellingLeftOrRight: false)
            createRightSensorPhysicsBody(whileTravellingLeftOrRight: false)
        }
    }
    
    func moveBottom() {
        if (downBlocked == true) {
            desiredDirection = DesiredDirection.bottom
        }
        else {
            currentDirection = .bottom
            desiredDirection = .none
            topBlocked = false
            
            self.physicsBody?.isDynamic = true
            
            createTopSensorBody(whileTravellingTopOrBottom: true)
            createBottomSensorBody(whileTravellingTopOrBottom: true)
            createLeftSensorPhysicsBody(whileTravellingLeftOrRight: false)
            createRightSensorPhysicsBody(whileTravellingLeftOrRight: false)
        }
    }
    
    func moveRight() {
        if (rightBlocked == true)
        {
            desiredDirection = DesiredDirection.right
        }
        else
        {
            currentDirection = .right
            desiredDirection = .none
            leftBlocked = false
            
            self.physicsBody?.isDynamic = true
            
            createTopSensorBody(whileTravellingTopOrBottom: false)
            createBottomSensorBody(whileTravellingTopOrBottom: false)
            createLeftSensorPhysicsBody(whileTravellingLeftOrRight: true)
            createRightSensorPhysicsBody(whileTravellingLeftOrRight: true)
        }
    }
    
    func moveLeft()
    {
        if (leftBlocked == true)
        {
            desiredDirection = DesiredDirection.left
        }
        else
        {
            currentDirection = .left
            desiredDirection = .none
            rightBlocked = false
            
            self.physicsBody?.isDynamic = true
            
            createTopSensorBody(whileTravellingTopOrBottom: false)
            createBottomSensorBody(whileTravellingTopOrBottom: false)
            createLeftSensorPhysicsBody(whileTravellingLeftOrRight: true)
            createRightSensorPhysicsBody(whileTravellingLeftOrRight: true)
        }
    }
    
    func createTopSensorBody(whileTravellingTopOrBottom: Bool) {
        var size: CGSize = CGSize.zero
        
        if (whileTravellingTopOrBottom == true) {
            size = CGSize(width: 32, height: 4)
        } else {
            size = CGSize(width: 32.4, height: 36)
        }
        
        nodeTop!.physicsBody = nil // get rid of any existing physics body
        let bodyUp: SKPhysicsBody = SKPhysicsBody(rectangleOf: size)
        nodeTop!.physicsBody = bodyUp
        nodeTop!.physicsBody?.categoryBitMask = CollisionType.topSensor.rawValue
        nodeTop!.physicsBody?.collisionBitMask = 0
        nodeTop!.physicsBody?.contactTestBitMask = CollisionType.boundary.rawValue
        nodeTop!.physicsBody?.pinned = true
        nodeTop!.physicsBody?.allowsRotation = false
    }
    
    func createBottomSensorBody(whileTravellingTopOrBottom: Bool) {
        var size: CGSize = CGSize.zero
        if (whileTravellingTopOrBottom == true) {
            size = CGSize(width: 20, height: 4)
        } else {
            size = CGSize(width: 20, height: 30)
        }

        nodeBottom?.physicsBody = nil
        let bodyDown: SKPhysicsBody = SKPhysicsBody(rectangleOf: size)
        nodeBottom!.physicsBody = bodyDown
        nodeBottom!.physicsBody?.categoryBitMask = CollisionType.bottomSensor.rawValue
        nodeBottom!.physicsBody?.collisionBitMask = 0
        nodeBottom!.physicsBody?.contactTestBitMask = CollisionType.boundary.rawValue
        nodeBottom!.physicsBody!.pinned = true
        nodeBottom!.physicsBody!.allowsRotation = false
    }
    
    func createLeftSensorPhysicsBody(whileTravellingLeftOrRight: Bool) {
        var size: CGSize = CGSize.zero
        if (whileTravellingLeftOrRight == true) {
            size = CGSize(width: 4, height: 32)
        } else {
            size = CGSize(width: 30, height: 20)
        }
        nodeLeft?.physicsBody = nil
        let bodyLeft: SKPhysicsBody = SKPhysicsBody(rectangleOf: size)
        nodeLeft!.physicsBody = bodyLeft
        nodeLeft!.physicsBody?.categoryBitMask = CollisionType.leftSensor.rawValue
        nodeLeft!.physicsBody?.collisionBitMask = 0
        nodeLeft!.physicsBody?.contactTestBitMask = CollisionType.boundary.rawValue
        nodeLeft!.physicsBody!.pinned = true
        nodeLeft!.physicsBody!.allowsRotation = false
    }
    
    func createRightSensorPhysicsBody(whileTravellingLeftOrRight: Bool) {
        var size: CGSize = CGSize.zero
        if (whileTravellingLeftOrRight == true) {
            size = CGSize(width: 4, height: 20)
        } else {
            size = CGSize(width: 30, height: 20)
        }
        
        nodeRight?.physicsBody = nil
        let bodyRight: SKPhysicsBody = SKPhysicsBody(rectangleOf: size)
        nodeRight!.physicsBody = bodyRight
        nodeRight!.physicsBody?.categoryBitMask = CollisionType.rightSensor.rawValue
        nodeRight!.physicsBody?.collisionBitMask = 0
        nodeRight!.physicsBody?.contactTestBitMask = CollisionType.boundary.rawValue
        nodeRight!.physicsBody!.pinned = true
        nodeRight!.physicsBody!.allowsRotation = false
    }
    
    func topContactStarted() {
        topBlocked = true
        if (currentDirection == Direction.top) {
            currentDirection = Direction.none
            self.physicsBody?.isDynamic = false
        }
    }
    
    func bottomContactStarted() {
        downBlocked = true
        if (currentDirection == Direction.bottom) {
            currentDirection = Direction.none
            self.physicsBody?.isDynamic = false
        }
    }
    
    func leftContactStarted() {
        leftBlocked = true
        if (currentDirection == Direction.left) {
            currentDirection = Direction.none
            self.physicsBody?.isDynamic = false
        }
    }
    
    func rightContactStarted() {
        rightBlocked = true
        if (currentDirection == Direction.right) {
            currentDirection = Direction.none
            self.physicsBody?.isDynamic = false
        }
    }
    
    func topContactEnd() {
        topBlocked = false
        if (desiredDirection == DesiredDirection.top) {
            moveTop()
            desiredDirection = DesiredDirection.none
        }
    }
    
    func bottomContactEnd() {
        downBlocked = false
        if (desiredDirection == DesiredDirection.bottom) {
            moveBottom()
            desiredDirection = DesiredDirection.none
        }
    }
    
    func leftContactEnd() {
        leftBlocked = false
        if (desiredDirection == DesiredDirection.left) {
            moveLeft()
            desiredDirection = DesiredDirection.none
        }
    }
    
    func rightContactEnd() {
        rightBlocked = false
        if (desiredDirection == DesiredDirection.right) {
            moveRight ()
            desiredDirection = DesiredDirection.none
        }
    }
}

