//
//  AppDelegate.swift
//  UpControl
//
//  Created by J.A. Korten on 14-06-18.
//  Copyright © 2018 JKSOFT Educational. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var poweredUpDelegate : PoweredUpDelegate!
    var appSettings = AppSettings()
    
    var bleTimer : Timer!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        poweredUpDelegate = PoweredUpDelegate()
        
        if let state = appSettings.stateFor(key: "autoConnect") {
            if state {
                poweredUpDelegate.initiateScanning()
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(peripheralGotDisconnected(notification:)), name: .peripheralDisconnected, object: nil)

        
        
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
        appSettings.saveContext()
    }
    
    @objc func peripheralGotDisconnected(notification: NSNotification) {
        // if reconnect in settings... then
        
        bleTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(tryToReconnectBLE), userInfo: nil, repeats: false) // for now don't repeat!
    }
    
    

    
    @objc func tryToReconnectBLE() {
        // try to reconnect
        if let state = appSettings.stateFor(key: "autoReconnect") {
            if state {
               poweredUpDelegate.initiateScanning()
            }
        }
    }

}

