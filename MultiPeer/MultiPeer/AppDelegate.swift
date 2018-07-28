//
//  AppDelegate.swift
//  MultiPeer
//
//  Created by Maxime Moison on 7/25/18.
//  Copyright © 2018 Maxime Moison. All rights reserved.
//

import UIKit
import CoreData
import p2p_synclib


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var syncManager:PPSyncManger?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        CoreDataStack.addChangeListener(forListener: self) { (changes) in
            print("AppDelegate is listening")
        }
        
        
        CoreDataStack.clearStore()

        let values = [
            "blue": UIColor.blue,
            "red": UIColor.red,
            "green": UIColor.green,
            "orange": UIColor.orange,
            ]

        let context = CoreDataStack.newChildContext(withName: "app_delegate_initial")
        for (name, color) in values {
            let newItem = ColoredItem(context: context)
            newItem.name = name
            newItem.color = color
        }

        try? context.save()
        
        
        setupP2PSync()
        
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
        // Saves changes in the application's managed object context before the application terminates.
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    func setupP2PSync() {
        syncManager = PPSyncManger(handler: p2pSyncReceived, changedConnections: p2pConnectionsChanged)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidEnterBackground, object: nil, queue: nil) { _ in
            self.syncManager?.pause()
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidBecomeActive, object: nil, queue: nil) { _ in
            self.syncManager?.resume()
        }
    }
    
    func p2pSyncReceived(_ data: Data) {
        // received a change that needs to be applied to CoreData
        
    }
    
    func p2pConnectionsChanged(_ connections: Int) {
        // Number of connections changed
        
    }
}

