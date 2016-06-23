//
//  GameViewController.swift
//  TouchGame
//
//  Created by Adrian  Humphrey on 1/19/16.
//  Copyright (c) 2016 Adrian  Humphrey. All rights reserved.
//

import UIKit
import SpriteKit
import Social
import GameKit

//extending the uiview to take a screen shot
extension UIView{
    func takeSnapShot()-> UIImage{
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 1.0)
        drawViewHierarchyInRect(self.bounds, afterScreenUpdates: false)
        CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(),CGInterpolationQuality.Medium)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

class GameViewController: UIViewController {

    var userSettingsDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Initiate GameCenter
        authenticaLocalPlayer()
        
        if let scene = GameScene(fileNamed:"GameScene") {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = false
            skView.showsNodeCount = false
            skView.userInteractionEnabled = true
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            skView.presentScene(scene)
    
    }
    
}

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func authenticaLocalPlayer(){
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            
            if(viewController != nil){
                //If the user has not signed in, the display the Game Center ViewController
                self.presentViewController(viewController!, animated: true, completion: nil)

            }
            else{
                //Display Game Center Username in console
                print((GKLocalPlayer.localPlayer().authenticated))
                print("Local player alias \(localPlayer.alias)")
                
                //Prepare alias to be saved to userdefaults
                let alias = localPlayer.alias
                print("Game Center alias \(alias)")
                
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(alias, forKey: "Current Player")
            }
            }
    }
    
  
}
