//
//  GameScene.swift
//  Project11
//
//  Created by Charles Martin Reed on 8/21/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    override func didMove(to view: SKView) {
        //creating our background
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        //enclose the frame in a physics body boundary, so that when the edge of the frame is reached, the box stops and bounces semi-realistically.
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //just to test things out, let's place a box where we tap
        if let touch = touches.first {
            let location = touch.location(in: self)
            let box = SKSpriteNode(color: UIColor.red, size: CGSize(width: 64, height: 64))
            
            //give the box a physics body of the same size
            box.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 64))
            box.position = location
            addChild(box)
        }
    }
}
