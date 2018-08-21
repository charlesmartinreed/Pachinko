//
//  GameScene.swift
//  Project11
//
//  Created by Charles Martin Reed on 8/21/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //creating a score for our game
    var scoreLabel: SKLabelNode!
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    //creating our level edit label and the editMode didSet
    var editLabel: SKLabelNode!
    
    //automatically change the label when the editLabel when the editingMode value changes
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    override func didMove(to view: SKView) {
        //physicsWorld is the physics sim associated with the scene
        physicsWorld.contactDelegate = self
        
    
        //creating our background
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        //placing our slots
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        //place the bouncer objects in the frame
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        
        //styling and placing our score label
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        //styling and placing our edit label
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
    }
    
    //creating the bouncers and placing them according to the passed param
    func makeBouncer(at position: CGPoint) {
        
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    //making our slots for the user to target; slots are either good (green) or bad (red).
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            
            //apple recommends using node names to organize and interact with them, rather than setting up variables that reference them
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        //we need rectangle physics for our slot; non-dynamic because it shouldn't move when a player ball hits it.
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        //MARK: - using SKActions to make our glow rotate
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //just to test things out, let's place a box where we tap
        if let touch = touches.first {
            let location = touch.location(in: self)
            //let locationX = location.x
            //let locationY = self.size.height
            
            //check whether or not the edit label was touched by checking the object nodes at the location we touch.
            let objects = nodes(at: location)
            
            if objects.contains(editLabel) {
                editingMode = !editingMode
            } else {
                if editingMode {
                    //create a box with a fixed height and random width, of a random color and a random zRotation. Place it where the user touches, when the editing mode is active.
                    let size = CGSize(width: GKRandomDistribution(lowestValue: 16, highestValue: 128).nextInt(), height: 16)
                    let box = SKSpriteNode(color: RandomColor(), size: size)
                    box.zRotation = RandomCGFloat(min: 0, max: 3)
                    box.position = location
                    
                    //set the physics of our obstacle box
                    box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                    box.physicsBody?.isDynamic = false
                    
                    addChild(box)
                    
            } else {
                //create a ball and give it physics
                let ball = SKSpriteNode(imageNamed: "ballRed")
                ball.name = "ball"
            
            //using circleOfRadius to give our ball circular physics
            ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
            
            //restitution = bounciness. Values range from 0-1.
            ball.physicsBody?.restitution = 0.4
            
            //contactBitMask = what a physics object can make contact with
            //collisionBitMask = what collisions we want to know about
            //setting the contactBitMask to the collisionBitMask means we want to be informed of all collisions
            ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
                    
            //y is set to the height of the GameScene so that the player can only set the X by touching.
            ball.position = CGPoint(x: location.x, y: self.size.height)
            //ball.position = CGPoint(x: locationX, y: locationY)
            addChild(ball)
                }
            }
        }
    }
    
    //check for collisions between the balls and other objects by looking at the node name and sending it to the collisionBetween func accordingly.
    //using guard statements to protect against the possibility that two collisions will be registered, ball into slot AND slot into ball.
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == "ball" {
            collisionBetween(ball: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collisionBetween(ball: nodeB, object: nodeA)
        }
    }
    
    //called when a ball collides with something else. If the object we get from the delegate method didBegin is named "good" or "bad", we handle the case accordingly.
    func collisionBetween(ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball: ball)
            score += 1
        } else if object.name == "bad" {
            destroy(ball: ball)
            score -= 1
        }
    }
    
    //removes the node from your node tree, AKA, your game
    func destroy(ball: SKNode) {
        ball.removeFromParent()
    }
}
