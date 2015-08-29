//
//  PuzzleStore.swift
//  SudokuBot
//
//  Created by Isaac Benham on 8/29/15.
//  Copyright © 2015 Isaac Benham. All rights reserved.
//

import Foundation
class PuzzleStore: NSObject {
    static let sharedInstance = PuzzleStore()
    let matrix: Matrix = Matrix.sharedInstance
    var operationQueue = NSOperationQueue()
    
    var backupQueue: NSOperationQueue? {
        get {
            var opQueue: NSOperationQueue?
            dispatch_sync(concurrentBackupQueue) {
                opQueue = NSOperationQueue.currentQueue()
            }
            return opQueue
        }
    }
    
    var puzzReadyNotificationString: String?
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    
    var completionHandler: (Puzzle -> ())?
    
    
    func getPuzzleForController(controller: SudokuController, withCompletionHandler handler: (Puzzle ->())) {
     
            if let puzz = matrix.getCachedPuzzleOfDifficulty(controller.difficulty) {
                handler(puzz)
                
            } else {
                let defaults = NSUserDefaults.standardUserDefaults()
                let key = controller.difficulty.cacheString()
                if let dict = defaults.objectForKey(key), puzz = Puzzle.fromData((dict as! NSData)) {
                    handler(puzz)
                    defaults.removeObjectForKey(key)
                } else {
                    dispatch_async(GlobalMainQueue) {
                        UIView.animateWithDuration(0.25) {
                            controller.longFetchLabel.hidden = false
                            controller.longFetchLabel.frame = CGRectMake(0,0, controller.board.frame.width, controller.board.frame.height * 0.2)
                        }
                    }
                    
                    completionHandler = handler
                    puzzReadyNotificationString = controller.difficulty.notificationString()
                    notificationCenter.addObserver(self, selector: Selector("puzzleReady:"), name: puzzReadyNotificationString, object: matrix)
                    
                    let block: () ->() = {
                        self.matrix.generatePuzzleOfDifficulty(controller.difficulty, shouldCache:false)
                    }
                    
                    let operation = NSBlockOperation(block: block)
                    operation.qualityOfService = .UserInitiated
                    operation.queuePriority = .High
                    
                    operationQueue.addOperation(operation)
                    
                }
            }
        }

    func populatePuzzleCache(difficulty:PuzzleDifficulty) {
       
        let operation = NSBlockOperation(){
            self.matrix.generatePuzzleOfDifficulty(difficulty)
        }
        operation.qualityOfService = .Background
        operation.queuePriority = .Low

       
        if let lastOp = operationQueue.operations.last {
            operation.addDependency(lastOp)
        }
        
        notificationCenter.addObserver(self, selector: Selector("puzzleWasCached:"), name: cachedNotification, object: matrix)
        
        operationQueue.addOperation(operation)
        
    }
    
    func puzzleReady(notification: NSNotification) {
        notificationCenter.removeObserver(self, name: puzzReadyNotificationString, object: nil)
        let puzz:Puzzle = notification.userInfo!["puzzle"] as! Puzzle
        completionHandler?(puzz)
        completionHandler = nil
        puzzReadyNotificationString = nil
    }
    
    func puzzleWasCached(notification: NSNotification) {
        let caches = matrix.getEmptyCaches
        notificationCenter.removeObserver(self, name: cachedNotification, object: nil)
        if let next = caches.first {
            populatePuzzleCache(next)
        }
        
        
    }
    
    // unenroll from puzzReadyNotification
    
}