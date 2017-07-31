//
//  AppDelegate.swift
//  NameIt
//
//  Created by Ranosys on 03/07/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import AssetsLibrary
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var spinnerView: MMMaterialDesignSpinner?
    var loaderView: UIView?
    var spinnerBackground: UIImageView?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        Fabric.with([Crashlytics.self])

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
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 5.0/255.0, green: 144.0/255.0, blue: 201.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName : (UIFont().montserratRegularWithSize(size: 18)), NSForegroundColorAttributeName: UIColor.white]
    }
    
    // MARK: - Show indicator
    func showIndicator(uiView: UIView) {
        
        spinnerBackground=UIImageView.init(frame: CGRect(x: 3.0, y: 3.0, width: 50.0, height: 50.0))
        spinnerBackground?.backgroundColor=UIColor.white
        spinnerBackground?.layer.cornerRadius=25.0
        spinnerBackground?.clipsToBounds=true
        spinnerBackground?.center=CGPoint(x: UIScreen.main.bounds.midX,y:UIScreen.main.bounds.midY)
        spinnerBackground?.tag=1000
        loaderView=UIView.init(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        loaderView?.tag=1001
        loaderView?.backgroundColor=UIColor.init(colorLiteralRed: (63.0/255.0), green: (63.0/255.0), blue: (63.0/255.0), alpha: 0.3)
        loaderView?.addSubview(spinnerBackground!)
        spinnerView=MMMaterialDesignSpinner.init(frame: CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0))
        spinnerView?.tag=1002
        spinnerView?.tintColor=UIColor(red: 5.0/255.0, green: 144.0/255.0, blue: 201.0/255.0, alpha: 1.0)
        spinnerView?.center=CGPoint(x: UIScreen.main.bounds.midX,y:UIScreen.main.bounds.midY)
        spinnerView?.lineWidth=3.0
        UIApplication.shared.keyWindow?.addSubview(loaderView!)
        UIApplication.shared.keyWindow?.addSubview(spinnerView!)
        spinnerView?.startAnimating()
    }
    
    // MARK: - Stop indicator
    func stopIndicator(uiView: UIView) {
        
        spinnerView?.stopAnimating()
        for container in (UIApplication.shared.keyWindow?.subviews)!{
            if container.tag == 1001 {
                
                for subContainer in container.subviews{
                    if subContainer.tag == 1000 {
                        
                        container.removeFromSuperview()
                    }
                }
                container.removeFromSuperview()
            }
            else if container.tag == 1002 {
                
                container.removeFromSuperview()
            }
        }
    }
    
    // MARK: - Database handling
    func insertUpdateRenamedText(imageName:String, rename renameText:String) {
        
        let check = DatabaseFile().isExistDataQuery(query: "SELECT * from PhotosData WHERE PhotoActualName = '\(imageName)';" as String as NSString)
        if check {
            DatabaseFile().update(updateStatementString: "UPDATE PhotosData SET PhotoRename = '\(renameText)' WHERE PhotoActualName = '\(imageName)';" as NSString)
        }
        else {
            let arr : NSMutableArray = [imageName,renameText]
            DatabaseFile().insertIntoDatabase(query: "insert into PhotosData values(?,?)", tempArray: arr)
        }
    }
    
    func fetchRenameEntries()->NSMutableDictionary {
        
         return DatabaseFile().selectQuery(query: "SELECT * from PhotosData;")
    }
    
    func deleteEntries(imageName:String) -> Bool {
        
        let check = DatabaseFile().delete(deleteStatementStirng: "DELETE FROM PhotosData WHERE PhotoActualName = '\(imageName)';" as NSString)
        if check {
            return true
        }
        else {
            
            return false
        }
    }
    // MARK: - end
}

