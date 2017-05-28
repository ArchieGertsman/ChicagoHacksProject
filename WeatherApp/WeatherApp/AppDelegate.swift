//
//  AppDelegate.swift
//  WeatherApp
//
//  Created by David Deborin on 5/27/17.
//  Copyright © 2017 Team Blue. All rights reserved.
//

import UIKit
import GooglePlaces
//import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //GMSServices.provideAPIKey("AIzaSyDYof-6Z_lcMAr2kCMoC9Rw8ZnlolL68Co")
        GMSPlacesClient.provideAPIKey("AIzaSyDYof-6Z_lcMAr2kCMoC9Rw8ZnlolL68Co")
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = UINavigationController(rootViewController: WeatherController())
        
        WeatherController.getTodaysMessage { (title, message) in
            guard let title = title else { return }
            guard let message = message else { return }
            
            WeatherController.setUpLocalNotification(hour: 1, minute: 4, title: title, message: message)
        }
        
        return true
    }


}

