//
//  AppDelegate.swift
//  SudokuCheat
//
//  Created by Isaac Benham on 4/14/15.
//  Copyright (c) 2015 Isaac Benham. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        window?.frame = UIScreen.mainScreen().bounds
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let number:Int = 0
        
        if defaults.objectForKey(Utils.Identifiers.symbolSetKey) == nil {
            defaults.setInteger(number, forKey: Utils.Identifiers.symbolSetKey)
        }
       
        
        // initialize the matrix so it's ready to crank out puzzles
        dispatch_async(Utils.ConcurrentPuzzleQueue) {
            Matrix.sharedInstance
        }

        return true
        
    }
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        let rootView = window?.rootViewController as? UINavigationController
        
        if let puzzleController = rootView?.topViewController as? PlayPuzzleViewController {
            saveCurrentPuzzleForController(puzzleController)
            puzzleController.goToBackground()
        } else if let puzzleController = rootView?.topViewController as? SudokuController {
            puzzleController.goToBackground()
        }
        
        
        PuzzleStore.sharedInstance.operationQueue.cancelAllOperations()
        
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

        let rootView = window?.rootViewController as? UINavigationController
        if let puzzleController = rootView?.topViewController as? PlayPuzzleViewController {
            saveCurrentPuzzleForController(puzzleController)
        }
        
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        let rootView = self.window?.rootViewController as? UINavigationController
        if let puzzleController = rootView?.topViewController as? SudokuController {
            puzzleController.wakeFromBackground()
        }

        
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        let rootView = self.window?.rootViewController as? UINavigationController
        if let puzzleController = rootView?.topViewController as? SudokuController {
            puzzleController.wakeFromBackground()
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
       
        
        let rootView = window?.rootViewController as? UINavigationController
        
        if let puzzleController = rootView?.topViewController as? PlayPuzzleViewController {
            saveCurrentPuzzleForController(puzzleController)
        }
        


    }
    
    func applicationDidReceiveMemoryWarning(application: UIApplication) {
        
        if UIApplication.sharedApplication().applicationState == UIApplicationState.Background {
            let rootView = window?.rootViewController as? UINavigationController
            
            if let puzzleController = rootView?.topViewController as? PlayPuzzleViewController {
                
                saveCurrentPuzzleForController(puzzleController)
                rootView?.popViewControllerAnimated(false)
            }

        }

    }
    
    func saveCurrentPuzzleForController(controller: PlayPuzzleViewController) {
        // TO-DO: PUZZLE SAVING
        
       /* let defaults = NSUserDefaults.standardUserDefaults()
        
        let dictionaryToSave = dictionaryToSaveForController(controller)
        
        defaults.setObject(dictionaryToSave, forKey: currentPuzzleKey)*/

    }

}

