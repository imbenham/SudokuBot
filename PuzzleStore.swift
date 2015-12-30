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
  
    
    var operationQueue = NSOperationQueue()
    
    var puzzReadyNotificationString: String?
    
    var completionHandler: ((Puzzle, [String:Any]?) -> ())?
    
    
      // accessing the cached puzzles
    
    
    func getPuzzleForController(controller: SudokuController, withCompletionHandler handler: ((Puzzle, [String: Any]?) ->())) {
        
        
        if let saved = savedPuzzleForDifficulty(controller.difficulty) {
            handler(saved.0, saved.1)
            return
        } else {
                dispatch_async (concurrentPuzzleQueue) {
                    
                dispatch_async(GlobalMainQueue) {
                    UIView.animateWithDuration(0.25) {
                        controller.longFetchLabel.hidden = false
                        controller.longFetchLabel.frame = CGRectMake(0,0, controller.board.frame.width, controller.board.frame.height * 0.2)
                    }
                }
                    
                let matrix = Matrix.sharedInstance
                
                let notificationCenter = NSNotificationCenter.defaultCenter()
                    
                self.completionHandler = handler
                self.puzzReadyNotificationString = controller.difficulty.notificationString()
                notificationCenter.addObserver(self, selector: Selector("puzzleReady:"), name: self.puzzReadyNotificationString, object: matrix)
                
                let block: () ->() = {
                    matrix.generatePuzzleOfDifficulty(controller.difficulty)
                }
                
                let operation = NSBlockOperation(block: block)
                operation.qualityOfService = .UserInitiated
                operation.queuePriority = .High
                self.operationQueue.addOperation(operation)
                }
        }

    }
    
    func savedPuzzleForDifficulty(difficulty: PuzzleDifficulty) -> (Puzzle, [String:Any]?)? {
        let defaults = NSUserDefaults.standardUserDefaults()
        guard let key = difficulty.currentKey, let dict = defaults.objectForKey(key) as? [String: AnyObject], puzzData = dict["puzzle"] as? NSData, assigned = dict["progress"] as? [[String:Int]], let annotatedDict = dict["annotated"] as? [NSDictionary], let discovered = dict["discovered"] as? [[String: Int]], let time = dict["time"] as? Double  else {
            return nil
        }
        let currentPuzz = NSKeyedUnarchiver.unarchiveObjectWithData(puzzData) as! Puzzle
        let assignedCells = assigned.map{PuzzleCell(dict: $0)!}
        let discoveredCells = discovered.map{PuzzleCell(dict: $0)!}
        
        defaults.removeObjectForKey(key)
        
        let puzzInfo:[String:Any] = ["progress": assignedCells, "discovered":discoveredCells, "annotated":annotatedDict, "time":time]
        
        return (currentPuzz, puzzInfo)

    }
    
    
    func puzzleReady(notification: NSNotification) {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: puzzReadyNotificationString, object: nil)
        let puzz:Puzzle = notification.userInfo!["puzzle"] as! Puzzle
        completionHandler?(puzz, nil)
        completionHandler = nil
        puzzReadyNotificationString = nil
        
    }
    
}