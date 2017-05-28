//
//  AppDelegate.swift
//  WeatherApp
//
//  Created by David Deborin on 5/27/17.
//  Copyright © 2017 Team Blue. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = UINavigationController(rootViewController: WeatherController())
        
        WeatherController.getTodaysMessage { (title, message) in
            guard let title = title else { return }
            guard let message = message else { return }
            
            WeatherController.setUpLocalNotification(hour: 0, minute: 55, title: title, message: message)
        }
        
        return true
    }


}

