//
//  AdsUtility.swift
//  TouchGame
//
//  Created by Adrian  Humphrey on 1/26/16.
//  Copyright © 2016 Adrian  Humphrey. All rights reserved.
//

// Helper class to show iAd and Google AdMob interstitial ads. Default is the iAd.
// If a new iAD add is not available an Google AdMob ad will be shown

import Foundation
import UIKit
import iAd
import GoogleMobileAds


class AdsUtility: NSObject {
    
    class func chartboostInterstitial(){
        
        Chartboost.showInterstitial(CBLocationGameOver)
        
        Chartboost.cacheInterstitial(CBLocationGameOver)
        
    }
    
}