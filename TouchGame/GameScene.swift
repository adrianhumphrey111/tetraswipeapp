//
//  GameScene.swift
//  TouchGame
//
//  Created by Adrian  Humphrey on 1/19/16.
//  Copyright (c) 2016 Adrian  Humphrey. All rights reserved.
//

import SpriteKit
import UIKit
import Social
import AVFoundation


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //All the variables that control game play
    var swipeLeftCount = 0
    var swipeRightCount = 0
    var swipeUpCount = 0
    var swipeDownCount = 0
    var tapCount = 0
    var tripleTapCount = 0
    var score = 0
    var gameOver = Bool()
    var currentNumberOfShips = Int()
    var timeBetweenShips = Double()
    var moverSpeed = 4.0
    var gameStarted = Bool()
    var beginTap = SKLabelNode()
    
    var MaxMoverSpeed = 2.0
    var MaxTimeBetweenShips = 0.3
    
    let moveFactor = 1.05
    var now = NSDate()
    var nextTime = NSDate()
    var scoreLabel = SKLabelNode()
    
    let ShapeCategory : UInt32 = 0x1 << 0
    let BottomCategory : UInt32 = 0x1 << 1
    
    //All the arrays that keeps track of the nodes that come into the screen so that when an action is called to delete a node
    //it automatically deletes the first node that was put into the scene.
    var swipeRightArray = [SKSpriteNode]()
    var swipeLeftArray = [SKSpriteNode]()
    var swipeUpArray = [SKSpriteNode]()
    var swipeDownArray = [SKSpriteNode]()
    var tapArray = [SKSpriteNode]()
    
    //All of the nodes that will allow me to keep count of certain actions
    let swipeRightNode = SKNode()
    let swipeLeftNode = SKNode()
    let swipeUpNode = SKNode()
    let swipeDownNode = SKNode()
    let tapNode = SKNode()
    
    //Variable to keep track of ads have been bought, as well as the user's highscore to display and upload to leaderboard
    var userSettingsDefaults = NSUserDefaults.standardUserDefaults()
    
    //The two variables for the button that must be pressed to start the game
    var tapToBegin = UIButton()
    var tapToBeginImage = UIImage(named: "TapToBegin") as UIImage!
    let logo = SKSpriteNode(imageNamed: "StartScreenTetraSwipe")
    
    //Mute button
    var muteButton = UIButton()
    var muteButtonImgae = UIImage(named: 
    
    //Variable to play all of the sounds
    let screenChangeSoundAction = SKAction.playSoundFileNamed("HighScore.mp3", waitForCompletion: false)
    let gameOverSoundAction = SKAction.playSoundFileNamed("gameOver.mp3", waitForCompletion: false)
    let tapSoundAction = SKAction.playSoundFileNamed("TapSound.mp3", waitForCompletion: false)
    let swipeSoundAction = SKAction.playSoundFileNamed("Retrol.mp3", waitForCompletion: false)
    
    /*
    Entry point into our scene
    */
    override func didMoveToView(view: SKView) {
        self.size = view.bounds.size
        
        self.physicsWorld.contactDelegate = self
        //Turn off gravity, nodes are falling due to an SKAction
        self.physicsWorld.gravity = CGVectorMake(0.0, 0.0)
        
        backgroundColor = UIColor.whiteColor()
        initializeValues()
        gameStarted = false

        kscore = 0
        kMute = false
        //These are all of the possible gestures player can make
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        let swipeUp = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        let swipeDown = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "tap:")
        tapGesture.numberOfTapsRequired = 1
        
        swipeLeft.direction = .Left
        swipeRight.direction = .Right
        swipeUp.direction = .Up
        swipeDown.direction = .Down
        
        self.view!.addGestureRecognizer(swipeLeft)
        self.view!.addGestureRecognizer(swipeRight)
        self.view!.addGestureRecognizer(swipeUp)
        self.view!.addGestureRecognizer(swipeDown)
        self.view!.addGestureRecognizer(tapGesture)
        
        //Setting the bottom of the screen as somehting that the falling objects can collide with, Once they do didBeganContact is called
        let bottomRect = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 1)
        let bottom = SKNode()
        bottom.physicsBody = SKPhysicsBody(edgeLoopFromRect: bottomRect)
        addChild(bottom)
        
        self.tapToBegin = UIButton(type: UIButtonType.Custom)
        self.tapToBegin.setImage(tapToBeginImage, forState: .Normal)
        self.tapToBegin.frame = CGRectMake(self.frame.size.width/2, self.frame.height * 2 / 3 + 40, 250, 65)
        self.tapToBegin.layer.anchorPoint = CGPointMake(1.0, 1.0)
        self.tapToBegin.layer.zPosition = 0
        //Attach an action to the play again button
        self.tapToBegin.addTarget(self, action: "TapToBeginAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        view.addSubview(self.tapToBegin)
        
        self.logo.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2 + 85)
        self.logo.xScale = 0.35
        self.logo.yScale = 0.35
        self.addChild(logo)
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        //Takes a screen shot when the right before the game is over so if the player wants to share to Facebook of Twitter then, the photo will be saved
        gameOverScreenShot()
        
        //Removes all children in the GameScene to prevent memory leaks
        self.removeAllChildren()
        
        delay(0.5){
            self.gameOverScene()
        }
    }
    
    
    //Sets the initial values for our variables.
    
    func initializeValues(){
        self.removeAllChildren()
        
        self.addChild(swipeRightNode)
        self.addChild(swipeLeftNode)
        self.addChild(swipeUpNode)
        self.addChild(swipeDownNode)
        self.addChild(tapNode)
        
        
        score = 0
        currentNumberOfShips = 0
        timeBetweenShips = 1.0
        moverSpeed = 5.0
        nextTime = NSDate()
        now = NSDate()
        
        scoreLabel = SKLabelNode(fontNamed:"Avenir")
        scoreLabel.text = "\(score)"
        scoreLabel.fontColor = SKColor.grayColor()
        scoreLabel.fontSize = 40;
        scoreLabel.position = CGPoint(x:CGFloat(self.frame.origin.x + 35), y:CGFloat(20));
        self.addChild(scoreLabel)
        
    }
    
    //If the arrow is a swipe, when the person swipes a certain array, it removes the first arrow in the arrary of one type shape
    func handleSwipe(sender: UISwipeGestureRecognizer){
        if(gameStarted == false){
            
        }
        else{
            
            if(sender.direction == .Left){
                if(swipeLeftNode.children.count == 0){
                    self.gameOverScreenShot()
                    self.gameOverScene()
                }
                else{
                    self.runAction(swipeSoundAction)
                    swipeLeftArray[swipeLeftCount].removeFromParent()
                    swipeLeftCount++
                    score++
                    kscore = score
                }
            }
            if(sender.direction == .Right){
                if(swipeRightNode.children.count == 0){
                    self.gameOverScreenShot()
                    self.gameOverScene()
                }
                else{
                    self.runAction(swipeSoundAction)
                    swipeRightArray[swipeRightCount].removeFromParent()
                    swipeRightCount++
                    score++
                    kscore = score
                }
            }
            if(sender.direction == .Up){
                if(swipeUpNode.children.count == 0){
                    self.gameOverScreenShot()
                    self.gameOverScene()}
                else{
                    self.runAction(swipeSoundAction)
                    swipeUpArray[swipeUpCount].removeFromParent()
                    swipeUpCount++
                    score++
                    kscore = score
                }
            }
            if(sender.direction == .Down){
                if(swipeDownNode.children.count == 0){
                    self.gameOverScreenShot()
                    self.gameOverScene()
                }
                else{
                    self.runAction(swipeSoundAction)
                    swipeDownArray[swipeDownCount].removeFromParent()
                    swipeDownCount++
                    score++
                    kscore = score
                }
            }
        }
    }
    
    
    func tap(sender: UITapGestureRecognizer){
        
    
        if (gameStarted == false){
            
        }else{
            
            if(tapNode.children.count != 0){
                self.runAction(tapSoundAction)
                tapArray[tapCount].removeFromParent()
                tapCount++
                score++
                kscore = score
            }
            else{
                self.gameOverScreenShot()
                self.gameOverScene()
            }
        }
    
    }
    
    
    /*
    Called before each frame is rendered
    */
    override func update(currentTime: CFTimeInterval) {
        
        if (score == 50){
            backgroundColor = UIColor.blackColor()
            self.runAction(screenChangeSoundAction)
        }
        if (score == 100){
            backgroundColor = UIColor.grayColor()
            self.runAction(screenChangeSoundAction)
        }
        
        if (score == 150){
            backgroundColor = UIColor.purpleColor()
            self.runAction(screenChangeSoundAction)
        }
        if (score == 200){
            backgroundColor = UIColor.whiteColor()
            self.runAction(screenChangeSoundAction)
        }
        if (score == 300){
            backgroundColor = UIColor.blackColor()
            self.runAction(screenChangeSoundAction)
        }
        
        if (score == 400){
            backgroundColor = UIColor.blueColor()
            self.runAction(screenChangeSoundAction)
        }
        if (score == 500){
            backgroundColor = UIColor.redColor()
            self.runAction(screenChangeSoundAction)
        }
        if (score == 600){
            backgroundColor = UIColor.blackColor()
            self.runAction(screenChangeSoundAction)
        }
        
        if (score == 700){
            backgroundColor = UIColor.whiteColor()
            self.runAction(screenChangeSoundAction)
        }
        if (score == 800){
            backgroundColor = UIColor.blackColor()
            self.runAction(screenChangeSoundAction)
        }
        if (score == 900){
            backgroundColor = UIColor.grayColor()
            self.runAction(screenChangeSoundAction)
        }
        
        if(gameStarted == true){
            
            scoreLabel.text = "\(score)"
            now = NSDate()
            if (now.timeIntervalSince1970 > nextTime.timeIntervalSince1970){
                
                nextTime = now.dateByAddingTimeInterval(NSTimeInterval(timeBetweenShips))
                
                createRandomGesture()
                
                if( moverSpeed > MaxMoverSpeed){
                    moverSpeed = moverSpeed/moveFactor
                }
                if(timeBetweenShips > MaxTimeBetweenShips){
                    timeBetweenShips = timeBetweenShips/moveFactor}
            }
        }
        if(score == 999){
            delay(0.5){
                self.gameOverScene()
            }
        }
    }
    
    /*
    Creates a random gesture with 1 of the three
    different colors for each
    */
    func createRandomGesture() {
        
        //Creates the starting position of the node at the top of the screen at random x value
        //The random x coordinate is using the self.frame.width in order to conform to the width of the portrait of the iphone 4, 5, 6, 6 plus and all ipads
        
        let range = UInt32(self.frame.width - 75)
        let newX = Int(arc4random_uniform(range) + 40)
        let newY = Int(self.frame.height)
        
        let p = CGPoint(x: newX, y: newY)
        let destination = CGPoint(x: newX, y: 0)
        let randomShape = Int(arc4random_uniform(15))
        
        if(randomShape == 0){
            let SwipeLeft1 = SKSpriteNode(imageNamed:"SwipeLeft1")
            SwipeLeft1.position = p
            SwipeLeft1.zPosition = 0
            let duration = NSTimeInterval(moverSpeed)
            let action = SKAction.moveTo(destination, duration: duration)
            SwipeLeft1.runAction(SKAction.repeatActionForever(action))
            SwipeLeft1.physicsBody = SKPhysicsBody(rectangleOfSize: SwipeLeft1.size)
            SwipeLeft1.physicsBody?.dynamic = true
            SwipeLeft1.physicsBody?.categoryBitMask = ShapeCategory
            //Shape can only collide with the bottom of the screen
            SwipeLeft1.physicsBody?.collisionBitMask = BottomCategory
            //Notification whent when the shape collides with the bottom
            SwipeLeft1.physicsBody?.contactTestBitMask = BottomCategory
            
            swipeLeftArray.append(SwipeLeft1)
            swipeLeftNode.addChild(SwipeLeft1)
        }
        if (randomShape == 1){
            let SwipeLeft2 = SKSpriteNode(imageNamed:"SwipeLeft2")
            SwipeLeft2.position = p
            SwipeLeft2.zPosition = 0
            let duration = NSTimeInterval(moverSpeed)
            let action = SKAction.moveTo(destination, duration: duration)
            SwipeLeft2.runAction(SKAction.repeatActionForever(action))
            SwipeLeft2.physicsBody = SKPhysicsBody(rectangleOfSize: SwipeLeft2.size)
            SwipeLeft2.physicsBody?.dynamic = true
            SwipeLeft2.physicsBody?.categoryBitMask = ShapeCategory
            SwipeLeft2.physicsBody?.collisionBitMask = BottomCategory
            SwipeLeft2.physicsBody?.contactTestBitMask = BottomCategory
            swipeLeftArray.append(SwipeLeft2)
            swipeLeftNode.addChild(SwipeLeft2)
        }
        else if (randomShape == 2){
            let SwipeLeft3 = SKSpriteNode(imageNamed:"SwipeLeft3")
            
            SwipeLeft3.position = p
            SwipeLeft3.zPosition = 0
            let duration = NSTimeInterval(moverSpeed)
            let action = SKAction.moveTo(destination, duration: duration)
            SwipeLeft3.runAction(SKAction.repeatActionForever(action))
            SwipeLeft3.physicsBody = SKPhysicsBody(rectangleOfSize: SwipeLeft3.size)
            SwipeLeft3.physicsBody?.dynamic = true
            SwipeLeft3.physicsBody?.categoryBitMask = ShapeCategory
            SwipeLeft3.physicsBody?.collisionBitMask = BottomCategory
            SwipeLeft3.physicsBody?.contactTestBitMask = BottomCategory
            swipeLeftArray.append(SwipeLeft3)
            swipeLeftNode.addChild(SwipeLeft3)
        }
        else if (randomShape == 3){
            let SwipeRight1 = SKSpriteNode(imageNamed:"SwipeRight1")
            
            SwipeRight1.position = p
            SwipeRight1.zPosition = 0
            let duration = NSTimeInterval(moverSpeed)
            let action = SKAction.moveTo(destination, duration: duration)
            SwipeRight1.runAction(SKAction.repeatActionForever(action))
            SwipeRight1.physicsBody = SKPhysicsBody(rectangleOfSize: SwipeRight1.size)
            SwipeRight1.physicsBody?.dynamic = true
            SwipeRight1.physicsBody?.categoryBitMask = ShapeCategory
            SwipeRight1.physicsBody?.collisionBitMask = BottomCategory
            SwipeRight1.physicsBody?.contactTestBitMask = BottomCategory
            swipeRightArray.append(SwipeRight1)
            swipeRightNode.addChild(SwipeRight1)
        }
        else if (randomShape == 4){
            let SwipeRight2 = SKSpriteNode(imageNamed:"SwipeRight2")
            
            SwipeRight2.position = p
            SwipeRight2.zPosition = 0
            let duration = NSTimeInterval(moverSpeed)
            let action = SKAction.moveTo(destination, duration: duration)
            SwipeRight2.runAction(SKAction.repeatActionForever(action))
            SwipeRight2.physicsBody = SKPhysicsBody(rectangleOfSize: SwipeRight2.size)
            SwipeRight2.physicsBody?.dynamic = true
            SwipeRight2.physicsBody?.categoryBitMask = ShapeCategory
            SwipeRight2.physicsBody?.collisionBitMask = BottomCategory
            SwipeRight2.physicsBody?.contactTestBitMask = BottomCategory
            swipeRightArray.append(SwipeRight2)
            swipeRightNode.addChild(SwipeRight2)
        }
        else if (randomShape == 5){
            let SwipeRight3 = SKSpriteNode(imageNamed:"SwipeRight3")
            
            SwipeRight3.position = p
            SwipeRight3.zPosition = 0
            let duration = NSTimeInterval(moverSpeed)
            let action = SKAction.moveTo(destination, duration: duration)
            SwipeRight3.runAction(SKAction.repeatActionForever(action))
            SwipeRight3.physicsBody = SKPhysicsBody(rectangleOfSize: SwipeRight3.size)
            SwipeRight3.physicsBody?.dynamic = true
            SwipeRight3.physicsBody?.categoryBitMask = ShapeCategory
            SwipeRight3.physicsBody?.collisionBitMask = BottomCategory
            SwipeRight3.physicsBody?.contactTestBitMask = BottomCategory
            swipeRightArray.append(SwipeRight3)
            swipeRightNode.addChild(SwipeRight3)
        }
        else if (randomShape == 6){
            let SwipeUp1 = SKSpriteNode(imageNamed:"SwipeUp1")
            
            SwipeUp1.position = p
            SwipeUp1.zPosition = 0
            let duration = NSTimeInterval(moverSpeed)
            let action = SKAction.moveTo(destination, duration: duration)
            SwipeUp1.runAction(SKAction.repeatActionForever(action))
            SwipeUp1.physicsBody = SKPhysicsBody(rectangleOfSize: SwipeUp1.size)
            SwipeUp1.physicsBody?.dynamic = true
            SwipeUp1.physicsBody?.categoryBitMask = ShapeCategory
            SwipeUp1.physicsBody?.collisionBitMask = BottomCategory
            SwipeUp1.physicsBody?.contactTestBitMask = BottomCategory
            swipeUpArray.append(SwipeUp1)
            swipeUpNode.addChild(SwipeUp1)
        }
        else if (randomShape == 7){
            let SwipeUp2 = SKSpriteNode(imageNamed:"SwipeUp2")
            
            SwipeUp2.position = p
            SwipeUp2.zPosition = 0
            let duration = NSTimeInterval(moverSpeed)
            let action = SKAction.moveTo(destination, duration: duration)
            SwipeUp2.runAction(SKAction.repeatActionForever(action))
            SwipeUp2.physicsBody = SKPhysicsBody(rectangleOfSize: SwipeUp2.size)
            SwipeUp2.physicsBody?.dynamic = true
            SwipeUp2.physicsBody?.categoryBitMask = ShapeCategory
            SwipeUp2.physicsBody?.collisionBitMask = BottomCategory
            SwipeUp2.physicsBody?.contactTestBitMask = BottomCategory
            swipeUpArray.append(SwipeUp2)
            swipeUpNode.addChild(SwipeUp2)
        }
        else if (randomShape == 8){
            let SwipeUp3 = SKSpriteNode(imageNamed:"SwipeUp3")
            
            SwipeUp3.position = p
            SwipeUp3.zPosition = 0
            let duration = NSTimeInterval(moverSpeed)
            let action = SKAction.moveTo(destination, duration: duration)
            SwipeUp3.runAction(SKAction.repeatActionForever(action))
            SwipeUp3.physicsBody = SKPhysicsBody(rectangleOfSize: SwipeUp3.size)
            SwipeUp3.physicsBody?.dynamic = true
            SwipeUp3.physicsBody?.categoryBitMask = ShapeCategory
            SwipeUp3.physicsBody?.collisionBitMask = BottomCategory
            SwipeUp3.physicsBody?.contactTestBitMask = BottomCategory
            swipeUpArray.append(SwipeUp3)
            swipeUpNode.addChild(SwipeUp3)
        }
        else if (randomShape == 9){
            let SwipeDown1 = SKSpriteNode(imageNamed:"SwipeDown1")
            
            SwipeDown1.position = p
            SwipeDown1.zPosition = 0
            let duration = NSTimeInterval(moverSpeed)
            let action = SKAction.moveTo(destination, duration: duration)
            SwipeDown1.runAction(SKAction.repeatActionForever(action))
            SwipeDown1.physicsBody = SKPhysicsBody(rectangleOfSize: SwipeDown1.size)
            SwipeDown1.physicsBody?.dynamic = true
            SwipeDown1.physicsBody?.categoryBitMask = ShapeCategory
            SwipeDown1.physicsBody?.collisionBitMask = BottomCategory
            SwipeDown1.physicsBody?.contactTestBitMask = BottomCategory
            swipeDownArray.append(SwipeDown1)
            swipeDownNode.addChild(SwipeDown1)
        }
        else if (randomShape == 10){
            let SwipeDown2 = SKSpriteNode(imageNamed:"SwipeDown2")
            
            SwipeDown2.position = p
            SwipeDown2.zPosition = 0
            let duration = NSTimeInterval(moverSpeed)
            let action = SKAction.moveTo(destination, duration: duration)
            SwipeDown2.runAction(SKAction.repeatActionForever(action))
            SwipeDown2.physicsBody = SKPhysicsBody(rectangleOfSize: SwipeDown2.size)
            SwipeDown2.physicsBody?.dynamic = true
            SwipeDown2.physicsBody?.categoryBitMask = ShapeCategory
            SwipeDown2.physicsBody?.collisionBitMask = BottomCategory
            SwipeDown2.physicsBody?.contactTestBitMask = BottomCategory
            swipeDownArray.append(SwipeDown2)
            swipeDownNode.addChild(SwipeDown2)
        }
        else if (randomShape == 11){
            let SwipeDown3 = SKSpriteNode(imageNamed:"SwipeDown3")
            
            SwipeDown3.position = p
            SwipeDown3.zPosition = 0
            let duration = NSTimeInterval(moverSpeed)
            let action = SKAction.moveTo(destination, duration: duration)
            SwipeDown3.runAction(SKAction.repeatActionForever(action))
            SwipeDown3.physicsBody = SKPhysicsBody(rectangleOfSize: SwipeDown3.size)
            SwipeDown3.physicsBody?.dynamic = true
            SwipeDown3.physicsBody?.categoryBitMask = ShapeCategory
            SwipeDown3.physicsBody?.collisionBitMask = BottomCategory
            SwipeDown3.physicsBody?.contactTestBitMask = BottomCategory
            swipeDownArray.append(SwipeDown3)
            swipeDownNode.addChild(SwipeDown3)
        }
        else if (randomShape == 12){
            let DoubleTap1 = SKSpriteNode(imageNamed: "Tap1")
            
            DoubleTap1.position = p
            DoubleTap1.zPosition = 0
            let duration = NSTimeInterval(moverSpeed)
            let action = SKAction.moveTo(destination, duration: duration)
            DoubleTap1.runAction(SKAction.repeatActionForever(action))
            DoubleTap1.physicsBody = SKPhysicsBody(rectangleOfSize: DoubleTap1.size)
            DoubleTap1.physicsBody?.dynamic = true
            DoubleTap1.physicsBody?.categoryBitMask = ShapeCategory
            DoubleTap1.physicsBody?.collisionBitMask = BottomCategory
            DoubleTap1.physicsBody?.contactTestBitMask = BottomCategory
            tapArray.append(DoubleTap1)
            tapNode.addChild(DoubleTap1)
        }
        else if (randomShape == 13){
            let DoubleTap2 = SKSpriteNode(imageNamed: "Tap2")
            
            DoubleTap2.position = p
            DoubleTap2.zPosition = 0
            let duration = NSTimeInterval(moverSpeed)
            let action = SKAction.moveTo(destination, duration: duration)
            DoubleTap2.runAction(SKAction.repeatActionForever(action))
            DoubleTap2.physicsBody = SKPhysicsBody(rectangleOfSize: DoubleTap2.size)
            DoubleTap2.physicsBody?.dynamic = true
            DoubleTap2.physicsBody?.categoryBitMask = ShapeCategory
            DoubleTap2.physicsBody?.collisionBitMask = BottomCategory
            DoubleTap2.physicsBody?.contactTestBitMask = BottomCategory
            tapArray.append(DoubleTap2)
            tapNode.addChild(DoubleTap2)
        }
        else if (randomShape == 14){
            let DoubleTap3 = SKSpriteNode(imageNamed: "Tap3")
            
            DoubleTap3.position = p
            DoubleTap3.zPosition = 0
            let duration = NSTimeInterval(moverSpeed)
            let action = SKAction.moveTo(destination, duration: duration)
            DoubleTap3.runAction(SKAction.repeatActionForever(action))
            DoubleTap3.physicsBody = SKPhysicsBody(rectangleOfSize: DoubleTap3.size)
            DoubleTap3.physicsBody?.dynamic = true
            DoubleTap3.physicsBody?.categoryBitMask = ShapeCategory
            DoubleTap3.physicsBody?.collisionBitMask = BottomCategory
            DoubleTap3.physicsBody?.contactTestBitMask = BottomCategory
            tapArray.append(DoubleTap3)
            tapNode.addChild(DoubleTap3)
        }
            
        else{
            //Do nothing
        }
    }
    
    /*
    Displays the actual game over screen
    */
    func gameOverScene(){
        //Keeps track of how many times a person has played the gaem in one sitting to place advertisments accordingly
        
        self.runAction(gameOverSoundAction)
        SaveScore()
        
        //Creates a new scene which is the gameOver scene
        let skView = self.view! as SKView
        skView.ignoresSiblingOrder = true
        //remove scene before transition
        self.scene?.removeFromParent()
        let transition = SKTransition.fadeWithColor(UIColor.grayColor(), duration: 1.0)
        transition.pausesOutgoingScene = false
        //A variable to hold the new scene
        var scene: GameOver!
        scene = GameOver(size: skView.bounds.size)
        
        //setting the new scene aspect to fill
        scene.scaleMode = .AspectFill
        skView.presentScene(scene, transition: transition)
    }
    
    //This is a delay function that makes the game play more smooth
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time( DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
    }
    
    func SaveScore(){
        
        if(score > kGameSceneHighScore){
            kGameSceneHighScore = score
            
            //save the highscore to the NSUserDefaults
            userSettingsDefaults.setInteger(kGameSceneHighScore, forKey: "highscore")
            userSettingsDefaults.synchronize()
        }
    }
    
    func TapToBeginAction(sender: UIControlEvents){
        logo.removeFromParent()
        tapToBegin.removeFromSuperview()
        gameStarted = true
    }
    
    func gameOverScreenShot(){
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
            
            let takeScreenShot = self.view!.takeSnapShot()
            kScreenShot = takeScreenShot
        }
    }
}