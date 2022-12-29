//
//  AppDelegate.swift
//  Radio (iOS)
//
//  Created by Türkay TANRIKULU on 15.03.2022.
//

import Foundation
import SwiftUI
import GoogleMobileAds

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        application.beginReceivingRemoteControlEvents()
        
        // Initialize Google Mobile Ads SDK.
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        return true
    }
}
