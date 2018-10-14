//
//  AppDelegate.swift
//  The 21st
//
//  Created by Travis RASE on 5/22/18.
//  Copyright © 2018 The 21st. All rights reserved.
//

import UIKit
import UserNotifications
import PushNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UIAlertViewDelegate {
    
    var window: UIWindow?
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    let pushNotifications = PushNotifications.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //set color of navigation bar
        UINavigationBar.appearance().isTranslucent = true
      
        //set color for line boxing in naviagtion bar
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
       
        //register for push notifications
        self.pushNotifications.start(instanceId: "e26036a3-7c7e-4de1-a782-a8aee792f3c4")
        self.pushNotifications.registerForRemoteNotifications()
        
        //pause on launch screen for 1 seconds
        sleep(1)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //pusher function
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.pushNotifications.registerDeviceToken(deviceToken) {
            try? self.pushNotifications.subscribe(interest: "hello")
        }
        
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
            //self.enableRemoteNotificationFeatures()
            //self.forwardTokenToServer(tokenn: deviceToken)
            
        }
        
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }
    //pusher function
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
        print("Remote notification support is unavailable due to error: \(error.localizedDescription)")
        //self.disableRemoteNotificationFeatures()
    }


}

