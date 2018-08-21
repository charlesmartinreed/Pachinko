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
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //code
    }
}
