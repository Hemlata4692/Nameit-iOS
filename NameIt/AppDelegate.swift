//
//  AppDelegate.swift
//  NameIt
//
//  Created by Ranosys on 03/07/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import AssetsLibrary

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //Check database is exist or not
        DatabaseFile().checkDataBaseExistence()
        
        //Set navigation bar properties.
        navigationCustomization()
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

    func navigationCustomization() {
        
//        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.0/255.0 green:213.0/255.0 blue:195.0/255.0 alpha:1.0]];
//        [[UINavigationBar appearance] setTranslucent:NO];
//        [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont railwayRegularWithSize:18], NSFontAttributeName, nil]];
//        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 5.0/255.0, green: 144.0/255.0, blue: 201.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName : (UIFont.systemFont(ofSize: 18)), NSForegroundColorAttributeName: UIColor.white]
    }
}

