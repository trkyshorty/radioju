//
//  AppDelegate.swift
//  Radio (iOS)
//
//  Created by Türkay TANRIKULU on 15.03.2022.
//

import Foundation
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        application.beginReceivingRemoteControlEvents()
        return true
    }
}
