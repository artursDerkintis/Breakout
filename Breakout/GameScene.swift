//
//  GameScene.swift
//  Breakout
//
//  Created by Arturs Derkintis on 8/20/15.
//  Copyright (c) 2015 Starfly. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var box : SKSpriteNode?
    var paddle : SKSpriteNode?
    var ball : SKSpriteNode?
    var canMove = false
    var bricks = [Brick]()
    var currentLevel : Level = Level.easy
    var lines : Int = 0
    override func didMoveToView(view: SKView) {
        print(frame)
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody?.linearDamping = 0.0
        self.physicsBody?.friction = 0.0
        physicsWorld.gravity = CGVector(dx: 0, dy: -0.1)
        physicsWorld.contactDelegate = self
        let sp = SKSpriteNode(imageNamed: "background")
        sp.size = frame.size
        sp.zPosition = Layer.Background
        sp.anchorPoint = CGPoint(x: 0, y: 0)
        sp.position = CGPoint(x: 0, y: 0)
        addChild(sp)
        addButtom()
        setUpBricks(Level.easy)
        addBall(CGPoint(x: CGRectGetMidX(frame), y: 70))
        addPaddle(CGPoint(x: CGRectGetMidX(frame), y: 30))
        radar()
    }
    
    func addBall(point : CGPoint){
        ball = SKSpriteNode(imageNamed: "ball")
        ball!.position = point
        ball!.size = CGSize(width: frame.width * 0.025, height: frame.width * 0.025)
        ball!.physicsBody = SKPhysicsBody(circleOfRadius: ball!.size.width * 0.5)
        ball!.physicsBody?.restitution = Bounciness.Ball
        ball!.physicsBody?.friction = 0.0
        ball?.physicsBody?.allowsRotation = false
        ball?.physicsBody?.linearDamping = 0.0
        ball!.physicsBody?.categoryBitMask = Category.Ball
        ball!.physicsBody?.contactTestBitMask = Category.Paddle | Category.Bottom | Category.Bricks
        ball!.zPosition = Layer.Ball
        ball!.name = Names.Ball
        let ballBevel = SKSpriteNode(imageNamed: "ball_bevel")
        ballBevel.zPosition = 10
        ballBevel.size = ball!.size
        ballBevel.position = CGPoint(x: 0, y: 0)
        ball!.addChild(ballBevel)
        addChild(ball!)
        ///For iPhone 6{
        ball?.physicsBody?.applyImpulse(CGVector(dx: 0.5, dy: -1))
        ///}
        ///For iPad {
        ///ball?.physicsBody?.applyImpulse(CGVector(dx: 4, dy: -7))
            ///}
    }
    func addPaddle(point : CGPoint){
        let texture = SKTexture(imageNamed: "table")
        paddle = SKSpriteNode(texture: texture)
        paddle?.size = CGSize(width: frame.width * 0.15, height: frame.width * 0.05)
        paddle?.position = point
        paddle?.name = Names.Paddle
        paddle?.zPosition = Layer.Paddle
        paddle?.physicsBody = SKPhysicsBody(texture: texture, size: paddle!.size)
        paddle?.physicsBody?.restitution = Bounciness.Paddle
        paddle?.physicsBody?.dynamic = false
        paddle?.physicsBody?.friction = 0.4
        paddle?.physicsBody?.categoryBitMask = Category.Paddle
        paddle?.physicsBody?.contactTestBitMask = Category.Ball
        paddle?.physicsBody?.affectedByGravity = false
        addChild(paddle!)
        
    }
    func setUpBricks(level : Level){
        currentLevel = level
        let rect = CGRect(x: frame.width * 0.1, y: frame.width * 0.1, width: frame.width * 0.8, height: frame.height * 0.4)
        
        let brickWidth = rect.width / CGFloat(level.rawValue)
        
        let brickHeight = brickWidth * 0.4
        let brickLinesCount = accurateRound(rect.height / brickHeight)
        lines = brickLinesCount
        addBox(CGPoint(x: frame.width * 0.1, y: frame.height * 0.5), size: CGSize(width: (brickWidth * CGFloat(level.rawValue)) - brickWidth, height: (CGFloat(brickLinesCount) * brickHeight) - brickHeight))
        let images = [UIImage(named: "brick_1"), UIImage(named: "brick_2"), UIImage(named: "brick_3"), UIImage(named: "brick_4"), UIImage(named: "brick_5"), UIImage(named: "brick_6")]
        
        for line in 1...brickLinesCount{
            for row in 0...level.rawValue{
                let index = randomInRange(0, upper: images.count - 1)
                let image = images[index]!
                addbrick(CGPoint(x: CGFloat(row) * (brickWidth + 1.0), y: CGFloat(line) * (brickHeight + 1.0)), size: CGSize(width: brickWidth, height: brickHeight), image: image, index : index)
            }
        }
        
    }
    func addbrick(position : CGPoint, size : CGSize, image : UIImage, index : Int){
        let sprite = Brick(texture: SKTexture(image: image))
        sprite.position = position
        sprite.size = size
        sprite.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: sprite.size.width - 3, height: sprite.size.height - 3), center: CGPoint(x: 0, y: 0))
        sprite.physicsBody?.affectedByGravity = false
        sprite.physicsBody?.restitution = Bounciness.Bricks
        sprite.name = Names.Brick
        sprite.tag = index
        sprite.physicsBody?.dynamic = false
        sprite.zPosition = Layer.Bricks
        bricks.append(sprite)
        box!.addChild(sprite)
    }
    func radar(){
        for brick in bricks{
            let left = scanMatchingBricks(Direction.left, brick: brick)
            let right = scanMatchingBricks(Direction.right, brick: brick)
            let up = scanMatchingBricks(Direction.up, brick: brick)
            let down = scanMatchingBricks(Direction.down, brick: brick)
            let matches = left + right + up + down
            brick.matchBricksNear = matches
            
            
                   }
    }
    func scanMatchingBricks(direction : Direction, brick : Brick) -> [Brick]{
        var bricksd = [Brick]()
        switch direction{
        case .left:
            let xOffset = brick.position.x
            let width = brick.size.width
           
            for i in 1...currentLevel.rawValue{
                let node = box?.nodeAtPoint(CGPoint(x: xOffset - (CGFloat(i) * width), y: brick.position.y)) as? Brick
                if let bric = node{
                    if bric.tag == brick.tag{
                        bricksd.append(bric)
                    }else{
                        break
                    }
                }else{
                    break
                }
                }
            break
        case .right:
            let xOffset = brick.position.x
            let width = brick.size.width
            
            for i in 1...currentLevel.rawValue{
                    let node = box?.nodeAtPoint(CGPoint(x: xOffset + (CGFloat(i) * width), y: brick.position.y)) as? Brick
                    if let bric = node{
                        if bric.tag == brick.tag{
                            bricksd.append(bric)
                        }else{
                            break
                        }
                    }else{
                        break
                }
            
            }
            
            break
        case .up:
            let yOffset = brick.position.y
            let height = brick.size.height
                for i in 1...lines{
                    let node = box?.nodeAtPoint(CGPoint(x: brick.position.x, y: yOffset + (CGFloat(i) * height))) as? Brick
                    if let bric = node{
                        if bric.tag == brick.tag{
                            bricksd.append(bric)
                        }else{
                            break
                        }
                    }else{
                        break
                    }
                }

            break
        case .down:
            let yOffset = brick.position.y
            let height = brick.size.height
                for i in 1...lines{
                    let node = box?.nodeAtPoint(CGPoint(x: brick.position.x, y: yOffset - (CGFloat(i) * height))) as? Brick
                    if let bric = node{
                        if bric.tag == brick.tag{
                            bricksd.append(bric)
                        }else{
                            break
                        }
                    }else{
                        break
                    }
            
            }
            break
        default:
            break
        }
       // print(bricksd)
        return bricksd
    }
    func addBox(pos : CGPoint, size : CGSize){
        box = SKSpriteNode()
        box?.anchorPoint = CGPoint(x: 0, y: 0)
        box?.position = pos
        box?.size = size
        addChild(box!)
    }


    func addButtom(){
        let bottom = SKSpriteNode(color: UIColor.blackColor(), size: CGSize(width: frame.width, height: 10))
        bottom.position = CGPoint(x: CGRectGetMidX(frame), y: 5)
        bottom.physicsBody = SKPhysicsBody(rectangleOfSize: bottom.size)
        bottom.physicsBody!.restitution = Bounciness.Borders
        bottom.name = Names.Bottom
        bottom.physicsBody?.dynamic = false
        addChild(bottom)
        
        
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            let nodes = nodesAtPoint(location)
            for node in nodes where node.name == Names.Paddle{
               canMove = true
            }
        }
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            if canMove{
                let action = SKAction.moveToX(location.x, duration: 0.01)
                paddle!.runAction(action)
               // print(paddle?.velocityX)
            }
            
        }
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        canMove = false
    }
    func didBeginContact(contact: SKPhysicsContact) {
        
        if (contact.bodyA.node?.name == Names.Ball && contact.bodyB.node?.name == Names.Bottom) || (contact.bodyA.node?.name == Names.Bottom && contact.bodyB.node?.name == Names.Ball){
            ball?.removeFromParent()
            addBall(CGPoint(x: paddle!.position.x, y: paddle!.position.y + 50))
        }
        
        var brick : SKPhysicsBody?
        if (contact.bodyA.node?.name == Names.Ball && contact.bodyB.node?.name == Names.Brick){
            brick = contact.bodyB
        }else if (contact.bodyA.node?.name == Names.Brick && contact.bodyB.node?.name == Names.Ball){
            brick = contact.bodyA
        }
        if let brickNode = brick{
            removeBricks(brickNode.node!)
        }
    }
    func removeBricks(brick : SKNode){
        let fade        = SKAction.fadeAlphaTo(0.8, duration: 0.1)
        let scaleUp     = SKAction.scaleTo(0.9, duration: 0.1)
        let scaleDown   = SKAction.group([SKAction.fadeAlphaTo(0.002, duration: 0.2)])
        let remove      = SKAction.removeFromParent()
        let actionGroup = SKAction.sequence([fade, scaleUp, scaleDown, remove])
        var bricksToRemove = [Brick]()
        
        let b1 = brick as! Brick
        bricksToRemove.append(b1)
        bricksToRemove += b1.matchBricksNear
        for subB in b1.matchBricksNear{
            bricksToRemove += subB.matchBricksNear
        }
        for brickToRemove in bricksToRemove{
            let particle = SKEmitterNode(fileNamed: "boom")
            particle?.position = CGPoint(x: 0, y: 0)
            brickToRemove.addChild(particle!)
            brickToRemove.runAction(actionGroup)
            
        }
        
    }
    
    
  
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}

class Brick : SKSpriteNode {
    var matchBricksNear = [Brick]()
    var tag : Int = 0
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
