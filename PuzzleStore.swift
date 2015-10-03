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
    
    var completionHandler: (Puzzle -> ())?
    
    
    private var puzzleCache: [PuzzleDifficulty: [Puzzle]] = [.Easy:[], .Medium:[], .Hard: [], .Insane: []]
    
    var cacheLimit = 2
    
    // accessing the cached puzzles
    
    var getEmptyCaches: Set<PuzzleDifficulty> {
        get {
            var toReturn:Set<PuzzleDifficulty> = [.Easy, .Medium, .Hard, .Insane]
            for key in toReturn {
                if !puzzleCache[key]!.isEmpty {
                    toReturn.remove(key)
                }
            }
            return toReturn
        }
    }
    
    var cachesToRefresh: Set<PuzzleDifficulty> = []
    
    func cachesWithLessThan(numItems: Int)->[PuzzleDifficulty] {
        let diffs: [PuzzleDifficulty] = [.Easy, .Medium, .Hard, .Insane]
        var lowDiffs: [PuzzleDifficulty] = []
        
        for diff in diffs {
            let cache = puzzleCache[diff]!
            if cache.count < numItems {
                lowDiffs.append(diff)
            }
        }
        return lowDiffs
    }
    
    func cachePuzzle(puzzle: Puzzle, ofDifficulty difficulty: PuzzleDifficulty) {
        puzzleCache[difficulty]!.append(puzzle)
        cachesToRefresh.insert(difficulty)
    }
    
    
    func cacheForDifficulty(difficulty: PuzzleDifficulty) -> [Puzzle] {
        return puzzleCache[difficulty]!
    }
    
    
    func clearCaches() {
        for diff in cachableDifficulties {
            puzzleCache[diff]! = []
        }
    }
    
    func getCachedPuzzleOfDifficulty(difficulty: PuzzleDifficulty) -> Puzzle? {
        
        if let puzzList = puzzleCache[difficulty] {
            if !puzzList.isEmpty {
                let puzz = puzzleCache[difficulty]!.removeLast()
                return puzz
            }
            return nil
        }
        return nil
    }
    
    func getPuzzleForController(controller: SudokuController, withCompletionHandler handler: (Puzzle ->())) {
     
            if let puzz = getCachedPuzzleOfDifficulty(controller.difficulty) {
                handler(puzz)
                dispatch_async(concurrentPuzzleQueue) {
                    self.restockCaches()
                }
                
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
                    matrix.generatePuzzleOfDifficulty(controller.difficulty, shouldCache:false)
                }
                
                let operation = NSBlockOperation(block: block)
                operation.qualityOfService = .UserInitiated
                operation.queuePriority = .High
                self.operationQueue.addOperation(operation)
                }
        }

    }
    
    func restockCaches() {
        dispatch_async(concurrentPuzzleQueue) {
            let lowCaches = self.cachesWithLessThan(self.cacheLimit)
            
            if let next = lowCaches.first {
                self.populatePuzzleCache(next)
            }
        }
        
    }

    func populatePuzzleCache(difficulty:PuzzleDifficulty) {

       let matrix = Matrix.sharedInstance
        let operation = NSBlockOperation(){
            matrix.generatePuzzleOfDifficulty(difficulty)
        }
        operation.qualityOfService = .Background
        operation.queuePriority = .Low
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.addObserver(self, selector: Selector("puzzleReadyToCache:"), name: cachedNotification, object: matrix)
        
        operationQueue.addOperation(operation)
        
    }
    
    func puzzleReady(notification: NSNotification) {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: puzzReadyNotificationString, object: nil)
        let puzz:Puzzle = notification.userInfo!["puzzle"] as! Puzzle
        completionHandler?(puzz)
        completionHandler = nil
        puzzReadyNotificationString = nil
        
        restockCaches()
    }
    
    func puzzleReadyToCache(notification: NSNotification) {
        
        let info = notification.userInfo!
        
        let puzz = info["puzzle"] as! Puzzle
        let difficulty = PuzzleDifficulty.fromCacheString((info["difficulty"] as! String))
        
        puzzleCache[difficulty]!.append(puzz)
        
        
        let emptyCaches = getEmptyCaches
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: cachedNotification, object: nil)
        if let next = emptyCaches.first {
            populatePuzzleCache(next)
            return
        }
    }
}