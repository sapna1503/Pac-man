//
//  Boundary.swift
//  Pacman
//
//  Created by Sapna Chandiramani on 12/02/17.
//  Copyright © 2017 Sapna Chandiramani. All rights reserved.
//

import Foundation
import SpriteKit

class Boundary: SKNode {
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init (fromSKSWithRect rect:CGRect, isEdge:Bool) {
        super.init()
        let newLocation = CGPoint(x: -(rect.size.width/2)  , y: (-(rect.size.height / 2)) )
        let newRect:CGRect = CGRect (origin: newLocation, size: rect.size)
        createBoundary(newRect)
    }
    
    func createBoundary(_ rect:CGRect){
        let boundary = SKShapeNode(rect: rect, cornerRadius: 1)
        boundary.fillColor = SKColor.black
        boundary.strokeColor = SKColor.purple
        boundary.lineWidth = 5
        
        addChild(boundary)
        
        self.physicsBody = SKPhysicsBody(rectangleOf: rect.size)
        self.physicsBody!.isDynamic = false
        self.physicsBody!.categoryBitMask = CollisionType.boundary.rawValue
        self.physicsBody!.friction = 0
        self.physicsBody!.allowsRotation = false        
        self.zPosition = 100
    }
}
