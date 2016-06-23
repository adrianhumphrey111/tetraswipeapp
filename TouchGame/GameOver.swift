//
//  GameOver.swift
//  TouchGame
//
//  Created by Adrian  Humphrey on 1/24/16.
//  Copyright © 2016 Adrian  Humphrey. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import GameKit
import StoreKit
import Social


class GameOver: SKScene , GKGameCenterControllerDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver{
    //Variables used for in-App-purshases of the no ads
    var productID: NSString?;
    let RemoveAds = SKProduct()
    
    let scoreLabel = SKLabelNode(fontNamed: "Avenir")
    var highScoreLabel = SKLabelNode(fontNamed: "Avenir")
    
    var userSettingsDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    var noAdsButton = SKSpriteNode()
    var playAgainButton = SKSpriteNode()
    var shareButton = SKSpriteNode()
    var leaderboardsButton = SKSpriteNode()
    var rateButton = SKSpriteNode()
    
    let scoreMessage = "Score"
    let highscoreMessage = "High Score"
    
    let scoreMessageLabel = SKLabelNode(fontNamed: "Avenir")
    let highscoreMessageLabel = SKLabelNode(fontNamed: "Avenir")
    
    var ads: AdsUtility!

   
    //variable is made so that when the user makes the purchase to remove the ads, it calls the iAd banner in the GameViewController to be hidden

    
    
    override func didMoveToView(view: SKView){
        productID = "com.HumpTrump.TetraSwipe11.RemoveAds2";
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        
        ktimesPlayed++
        
        
        //Check if product is Purchased
        if(userSettingsDefaults.boolForKey("purchased")){
            //If the user has successfully purchased the noAds, the "purchased" will be true and no ads will be played
        }
        else{
            if(ktimesPlayed%3 == 0){
                AdsUtility.chartboostInterstitial()
            }
        }


        
        self.backgroundColor = SKColor.whiteColor()
        let highScore = userSettingsDefaults.integerForKey("highscore") as NSInteger!
        
        self.scoreMessageLabel.text = scoreMessage
        self.scoreMessageLabel.fontSize = 30
        self.scoreMessageLabel.fontColor = SKColor.grayColor()
        self.scoreMessageLabel.position = CGPointMake(self.frame.width/4, self.frame.size.height - 50 - 55)
        self.addChild(scoreMessageLabel)
        
        self.highscoreMessageLabel.text = highscoreMessage
        self.highscoreMessageLabel.fontSize = 30
        self.highscoreMessageLabel.fontColor = SKColor.grayColor()
        self.highscoreMessageLabel.position = CGPointMake(self.frame.width/4*3, self.frame.size.height - 50 - 55)
        self.addChild(highscoreMessageLabel)
        
        self.scoreLabel.text = "\(kscore)"
        self.scoreLabel.fontSize = 40
        self.scoreLabel.fontColor = SKColor.grayColor()
        self.scoreLabel.position = CGPointMake(self.frame.width/4, self.frame.size.height - 50 - 35 - 35 - 20)
        
        self.addChild(scoreLabel)
        
        self.highScoreLabel.text = "\(highScore)"
        self.highScoreLabel.fontSize = 40
        self.highScoreLabel.fontColor = SKColor.grayColor()
        self.highScoreLabel.position = CGPointMake(self.size.width/4*3, self.frame.size.height - 50 - 35 - 35 - 20)
        self.addChild(highScoreLabel)
        
        
        self.leaderboardsButton = SKSpriteNode(imageNamed: "LeaderboardButton")
        self.leaderboardsButton.position = CGPointMake(self.frame.size.width/2, self.frame.size.height - 120 - 35 - 65 - 65 - 20)
        self.leaderboardsButton.name = "LeaderboardButton"
        self.leaderboardsButton.xScale = 0.25
        self.leaderboardsButton.yScale = 0.25
        delay(0.5){
            self.addChild(self.leaderboardsButton)
        }
        
        
        self.noAdsButton = SKSpriteNode(imageNamed: "NoAdsButton")
        self.noAdsButton.position = CGPointMake(self.frame.size.width/2 - 80 , self.frame.size.height - 120 - 35 - 20)
        self.noAdsButton.name = "NoAdsButton"
        self.noAdsButton.xScale = 0.2
        self.noAdsButton.yScale = 0.25
        delay(0.5){
            self.addChild(self.noAdsButton)
        }
        
        self.rateButton = SKSpriteNode(imageNamed: "RateButton")
        self.rateButton.position = CGPointMake(self.frame.size.width/2 + 80 , self.frame.size.height - 120 - 35 - 20)
        self.rateButton.name = "RateButton"
        self.rateButton.xScale = 0.2
        self.rateButton.yScale = 0.25
        delay(0.5){
            self.addChild(self.rateButton)
        }
        
        self.shareButton = SKSpriteNode(imageNamed: "ShareButton")
        self.shareButton.position = CGPointMake(self.frame.size.width/2, self.frame.size.height - 120 - 35 - 65 - 20)
        self.shareButton.name = "ShareButton"
        self.shareButton.xScale = 0.25
        self.shareButton.yScale = 0.25
        delay(0.5){
            self.addChild(self.shareButton)
        }
        
        self.playAgainButton = SKSpriteNode(imageNamed: "PlayAgainButton")
        self.playAgainButton.position = CGPointMake(self.frame.size.width/2, self.frame.size.height - 120 - 35 - 65 - 65 - 65 - 20 )
        self.playAgainButton.name = "PlayAgainButton"
        self.playAgainButton.xScale = 0.25
        self.playAgainButton.yScale = 0.25
        delay(0.5){
            self.addChild(self.playAgainButton)
        }
        
        reportLeaderboardIdentifier("TetraSwipeLeaderboard", score: kGameSceneHighScore)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches{
            let location = touch.locationInNode(self)
            if(self.nodeAtPoint(location) == playAgainButton){
                playAgainAction()
            }
            if(self.nodeAtPoint(location) == leaderboardsButton){
                leaderboardAction()
            }
            
            if(self.nodeAtPoint(location) == noAdsButton){
                removeAdsAction()
            }
            if(self.nodeAtPoint(location) == shareButton){
                shareAction()
            }
            if(self.nodeAtPoint(location) == rateButton){
                rateAction()
            }
            
            
        }
        
    }
    
    func requestProductInfo(){
        
        //Check to see if We can make purchases
        if(SKPaymentQueue.canMakePayments()){
            let product_ID:NSSet = NSSet(object: self.productID!)
            let productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: product_ID as! Set<String>)
            productsRequest.delegate = self
            productsRequest.start()
        }
        else{
            
            let alert = UIAlertController(title: "Payment Can Not Be Made", message: "Sorry, there are restrictions to purchase.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            let vc = self.view?.window?.rootViewController
            vc?.presentViewController(alert, animated: true, completion: nil)
        }
    
    }
    
    deinit {
        SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
    }
    
    func buyProduct(product: SKProduct){
        let payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    
    func productsRequest (request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        
        let count : Int = response.products.count
        print(response.products.count)
        if (count>0) {
            let validProduct: SKProduct = response.products[0] as SKProduct
            if (validProduct.productIdentifier == self.productID) {
                print(validProduct.localizedTitle)
                print(validProduct.localizedDescription)
                print(validProduct.price)
                buyProduct(validProduct);
            } else {
                print(validProduct.productIdentifier)
            }
        }
        
        else {
            print("nothing")
        }
    }
    
    
    func request(request: SKRequest, didFailWithError error: NSError) {
        print("Error Fetching product information");
    }
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])    {
        print("Received Payment Transaction Response from Apple");
        
        for transaction:AnyObject in transactions {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction{
                switch trans.transactionState {
                    
                case .Purchased:
                    print("Product Purchased");
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction as! SKPaymentTransaction)
                    userSettingsDefaults.setBool(true , forKey: "purchased")
                    break;
                    
                case .Failed:
                    print("Purchased Failed");
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction as! SKPaymentTransaction)
                    break;
                    
                case .Restored:
                    print("Already Purchased");
                    SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
                    
                    
                default:
                    break;
                }
            }
        }
        
    }
    
    
    func delay(delay:Double, closure:()->()) {
        
        dispatch_after(
            dispatch_time( DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
        
        
    }
    
    //If the play again function is called then the shapes should start falling automatically so it declares  gamestarted to true
    func playAgainAction(){
        
        let reveal : SKTransition = SKTransition.crossFadeWithDuration(0.5)
        let scene = GameScene(size: self.view!.bounds.size)
        scene.scaleMode = .AspectFill
        
        removeGameOverButtons()
        self.view?.presentScene(scene, transition: reveal)
        scene.tapToBegin.removeFromSuperview()
        scene.gameStarted = true
        scene.logo.removeFromParent()
        
        
        
    }
    
    
    //When the play again function is called, it calls this method to remove everything from the gameOverScene before is goes back in order to prevent memory leaking
    func removeGameOverButtons(){
        self.playAgainButton.removeFromParent()
        self.noAdsButton.removeFromParent()
        self.rateButton.removeFromParent()
        self.shareButton.removeFromParent()
        self.leaderboardsButton.removeFromParent()

    }
    
    
    func reportLeaderboardIdentifier(identifier: String, score: Int){
        //Check if the user has signed into game center
        if GKLocalPlayer.localPlayer().authenticated{
            let scoreObject = GKScore(leaderboardIdentifier: identifier)
            scoreObject.value = Int64(score) //value is a gkscore that is holding our value
            GKScore.reportScores([scoreObject]) {(error) -> Void in
                if error != nil{
                    print("Error in reportingLeaderboard score: \(score)")
                }
            }
        }
        
    }
    
    
    func leaderboardAction(){
        //Call the game center leaderboard to view score
        showLeader()
    }
    
    func showLeader(){
        //Shows leaderbaord viewController
        let vc = self.view?.window?.rootViewController
        let gc = GKGameCenterViewController()
        gc.gameCenterDelegate = self
        vc?.presentViewController(gc, animated: true, completion: nil)
        
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController){
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //This method is called when the user pressed the rate me button and takes the to the app store, the page of TetraSwipe
    func rateAction(){
        UIApplication.sharedApplication().openURL(NSURL(string: "https://itunes.apple.com/us/app/tetraswipe/id1079828509?ls=1&mt=8")!)
    }
    
    //This method is called when the user presses the share button, then proceeds to ask them where they would like to share to Facebook of Twitter
    func shareAction() {
        let alert = UIAlertController(title: "Share", message: "Where do you want to share?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Facebook", style: .Default, handler: {(alert: UIAlertAction!) in self.showFacebook()}))
        alert.addAction(UIAlertAction(title: "Twitter", style: .Default, handler: {(alert: UIAlertAction!) in self.showTwitter()}))
        let vc = self.view?.window?.rootViewController
        vc?.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    private func showFacebook() {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
            let mySLComposerSheet = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            mySLComposerSheet.setInitialText("My Highscore was \(kscore)! Downloand and see if you can beat it! This game is fun, simple, and addicting! TETRASWIPE! Download From AppStore!")
            mySLComposerSheet.addImage(kScreenShot)
            mySLComposerSheet.addURL(NSURL(string: "https://itunes.apple.com/us/app/tetraswipe/id1079828509?ls=1&mt=8")!)
            let vc = self.view?.window?.rootViewController
            vc?.presentViewController(mySLComposerSheet, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "You are not signed into Facebook", message: "Please go to settings and sign into Facebook in order to share!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            let vc = self.view?.window?.rootViewController
            vc?.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    private func showTwitter() {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            let mySLComposerSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            mySLComposerSheet.setInitialText("My Highscore was \(kscore)! Download and see if you can beat it! Fun, simple, and addicting!")
            mySLComposerSheet.addImage(kScreenShot)
            mySLComposerSheet.addURL(NSURL(string: "https://itunes.apple.com/us/app/tetraswipe/id1079828509?ls=1&mt=8")!)
            let vc = self.view?.window?.rootViewController
            vc?.presentViewController(mySLComposerSheet, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "You are not signed into Twitter", message: "Please go to settings and sign into Twitter in oreer to share!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            let vc = self.view?.window?.rootViewController
            vc?.presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    
    //This funtion is called when user presses the no ads buttons, ask if the would like to buy no ads, or to restore a purchase that the already made.
    func removeAdsAction(){
        
        let alert = UIAlertController(title: "Remove Ads", message: "Would You like to buy No Ads, or restore a purchase?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Buy No Ads", style: .Default, handler: {(alert: UIAlertAction!) in self.buyNoAds()}))
        alert.addAction(UIAlertAction(title: "Restore Payment", style: .Default, handler: {(alert: UIAlertAction!) in self.restorePayment()}))
        let vc = self.view?.window?.rootViewController
        vc?.presentViewController(alert, animated: true, completion: nil)
        
    }
    //This is called when the buyNoAds button is pressed
    func buyNoAds(){
        requestProductInfo()
        
    }
    //This is called whe the restore button is pressed
    func restorePayment(){
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    
    
}
