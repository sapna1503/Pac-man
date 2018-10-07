//
//  Coin.swift
//  Pacman
//
//  Created by Sapna Chandiramani on 12/02/17.
//  Copyright © 2017 Sapna Chandiramani. All rights reserved.
//

import Foundation
import SpriteKit

var coinSprite: SKSpriteNode?

class Coin: SKNode {
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init()
    {
        super.init()
        coinSprite = SKSpriteNode(imageNamed: "coin")
        addChild(coinSprite!)
        createPhysicsBody()
    }
    
    func createPhysicsBody()
    {
        self.physicsBody = SKPhysicsBody(circleOfRadius: coinSprite!.size.width / 2  )
        self.physicsBody?.categoryBitMask = CollisionType.coin.rawValue
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
        self.zPosition = 110
    }
}
