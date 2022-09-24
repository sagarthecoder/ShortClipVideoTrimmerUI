//
//  AppDelegate.swift
//  ShortClipVideoTrimmerUI
//
//  Created by Sagar Chandra Das on 09/24/2022.
//  Copyright (c) 2022 Sagar Chandra Das. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let homeVC = HomePageViewController()
        let navController = UINavigationController(rootViewController: homeVC)
        navController.setNavigationBarHidden(true, animated: false)
        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()
        return true
    }
}

