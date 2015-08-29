//
//  AppDelegate.swift
//  SudokuCheat
//
//  Created by Isaac Benham on 4/14/15.
//  Copyright (c) 2015 Isaac Benham. All rights reserved.
//

import UIKit
import iAd


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ADBannerViewDelegate {

    var window: UIWindow?
    let bannerView = ADBannerView(adType: .Banner)
  
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        window?.frame = UIScreen.mainScreen().bounds
        
        bannerView.delegate = self
        
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let number:Int = 0
        
        if defaults.objectForKey(symbolSetKey) == nil {
            defaults.setInteger(number, forKey: symbolSetKey)
        }
        if defaults.objectForKey(timedKey) == nil {
            defaults.setBool(false, forKey: timedKey)
        }
        
        if defaults.objectForKey(easyPuzzleKey) == nil {
            let easyData = NSKeyedArchiver.archivedDataWithRootObject(["givens":[349, 542, 218, 864, 638, 898, 696, 173, 295, 727, 992, 839, 875, 233, 358, 411, 256, 455, 682, 779, 615, 886, 136, 241, 946, 519, 363, 537, 585, 935, 487, 593, 397, 657, 753], "solution":[312, 574, 145, 162, 977, 325, 526, 852, 384, 478, 813, 928, 568, 224, 129, 272, 959, 765, 748, 422, 716, 671, 644, 794, 376, 961, 191, 732, 117, 669, 499, 289, 551, 983, 434, 821, 914, 188, 154, 623, 267, 781, 331, 466, 847, 443]])
            defaults.setObject(easyData, forKey: easyPuzzleKey)
        }
        
        if defaults.objectForKey(mediumPuzzleKey) == nil {
            let mediumData = NSKeyedArchiver.archivedDataWithRootObject(["givens":[522, 767, 595, 141, 127, 291, 413, 364, 958, 834, 269, 739, 335, 472, 846, 796, 448, 925, 454, 586, 678, 993, 652, 553, 631, 666, 168, 897, 971], "solution":[514, 426, 538, 788, 373, 218, 116, 683, 751, 179, 276, 232, 285, 224, 319, 257, 863, 917, 989, 745, 342, 859, 499, 962, 561, 629, 437, 875, 615, 133, 155, 549, 192, 944, 465, 712, 723, 811, 828, 577, 647, 774, 243, 398, 694, 184, 321, 882, 936, 356, 387, 481]])
            defaults.setObject(mediumData, forKey: mediumPuzzleKey)
        }
        
        if defaults.objectForKey(hardPuzzleKey) == nil {
            let hardData = NSKeyedArchiver.archivedDataWithRootObject(["givens":[493, 379, 876, 632, 962, 264, 481, 514, 827, 783, 521, 746, 578, 739, 894, 345, 251, 225, 248, 297, 585, 196, 754, 184, 429, 913, 163], "solution":[118, 949, 352, 998, 465, 442, 971, 543, 767, 391, 926, 812, 324, 686, 333, 569, 661, 623, 147, 556, 438, 388, 772, 592, 728, 236, 841, 644, 987, 131, 889, 934, 457, 317, 711, 853, 658, 416, 273, 366, 175, 868, 122, 699, 795, 677, 835, 615, 955, 537, 474, 219, 282, 159]])
            defaults.setObject(hardData, forKey: hardPuzzleKey)
        }
        
        if defaults.objectForKey(insanePuzzleKey) == nil {
        let insaneData = NSKeyedArchiver.archivedDataWithRootObject(["givens":[731, 848, 687, 463, 353, 517, 829, 267, 583, 397, 875, 479, 418, 172, 155, 552, 656, 432, 786, 549, 794, 221, 816, 928, 989], "solution":[319, 258, 743, 623, 371, 454, 426, 692, 914, 344, 765, 215, 935, 576, 141, 993, 951, 534, 284, 977, 495, 611, 481, 338, 882, 727, 113, 242, 891, 188, 447, 598, 385, 525, 196, 124, 962, 322, 857, 639, 645, 759, 137, 778, 833, 712, 273, 236, 668, 169, 561, 299, 366, 674, 946, 864]])
        defaults.setObject(insaneData, forKey: insanePuzzleKey)
        }
        
        defaults.synchronize()
        
        let operationQueue = PuzzleStore.sharedInstance.operationQueue
        let matrixInitialization = NSBlockOperation() {
            let matrix = Matrix.sharedInstance
            matrix.operationQueue = operationQueue
        }
        
        matrixInitialization.completionBlock = {
            PuzzleStore.sharedInstance.populatePuzzleCache(.Easy)
        }
        
        
        matrixInitialization.qualityOfService = .Utility
        matrixInitialization.queuePriority = .High
        
        
        operationQueue.addOperations([matrixInitialization], waitUntilFinished: false)
        
        
        let rootView = window?.rootViewController as? UINavigationController
        rootView?.topViewController
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        let rootView = window?.rootViewController as? UINavigationController
        
        if let puzzleController = rootView?.topViewController as? SudokuController {
            puzzleController.goToBackground()
        }
        
       dispatch_async(GlobalBackgroundQueue) {
    
            let matrix = Matrix.sharedInstance
            let diffs: [PuzzleDifficulty] = [.Easy, .Medium, .Hard, .Insane]
            let defaults = NSUserDefaults.standardUserDefaults()
            for diff in diffs {
                if defaults.objectForKey(diff.cacheString()) == nil {
                    if let cached = matrix.getCachedPuzzleOfDifficulty(diff) {
                        let someData = cached.asData()
                        defaults.setObject(someData, forKey: diff.cacheString())
                        defaults.synchronize()
                    } else {
                        matrix.fillCaches()
                    }

                }
            }
    
        }
        
        

        
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

       
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        let rootView = window?.rootViewController as? UINavigationController
        
        if let puzzleController = rootView?.topViewController as? SudokuController {
            puzzleController.wakeFromBackground()
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
    }
    
    // banner view delegate methods
    
    // banner view delegate
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        let rootView = window!.rootViewController as! UINavigationController
        if let puzzleController = rootView.topViewController as? SudokuController {
            puzzleController.bannerViewDidLoadAd(banner)
        }

    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        let rootView = window!.rootViewController as! UINavigationController
        if let puzzleController = rootView.topViewController as? SudokuController {
            puzzleController.bannerViewDidLoadAd(banner)
        }
    }
    
    
   func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        let rootView = window!.rootViewController as! UINavigationController
        if let puzzleController = rootView.topViewController as? PlayPuzzleViewController {
            return puzzleController.bannerViewActionShouldBegin(banner, willLeaveApplication: willLeave)
        } else {
            if let sudokuContrl = rootView.topViewController as? SudokuController {
                return sudokuContrl.bannerViewActionShouldBegin(banner, willLeaveApplication: willLeave)
            }
    }
        return false
    }
    
    
    
    func bannerViewActionDidFinish(banner: ADBannerView!) {
        let rootView = window!.rootViewController as! UINavigationController
        if let puzzleController = rootView.topViewController as? PlayPuzzleViewController {
            puzzleController.bannerViewActionDidFinish(banner)
        }
        
    }


}

