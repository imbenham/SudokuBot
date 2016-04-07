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
    
    var completionHandler: ((initials: [PuzzleCell], solution: [PuzzleCell]) -> ())?
    
    var difficulty: PuzzleDifficulty = .Medium
    private var rawDiffDict: [PuzzleDifficulty:Int] = [.Easy : 130, .Medium: 160, .Hard: 190, .Insane: 240]

    
    
    func setPuzzleDifficulty(pd:PuzzleDifficulty) {
        difficulty = pd
    }
    
    func getPuzzleDifficulty() -> Int {
        switch difficulty {
        case .Custom(let val):
            return val
        default:
            return rawDiffDict[difficulty]!
        }
    }
    
    
    func getPuzzleForController(controller: SudokuController, withCompletionHandler handler: ((initials: [PuzzleCell], solution: [PuzzleCell]) -> ())) {
        
        // PLACEHOLDER-- HANDLE SAVED PUZZLE
        if false {
            return
        } else {
                dispatch_async (concurrentPuzzleQueue) {
                    
                dispatch_async(GlobalMainQueue) {
                    UIView.animateWithDuration(0.25) {
                        controller.longFetchLabel.hidden = false
                        controller.longFetchLabel.frame = CGRectMake(0,0, controller.board.frame.width, controller.board.frame.height * 0.2)
                    }
                }
                    
                    self.completionHandler = handler
                    self.difficulty = controller.difficulty
                    let matrix = Matrix.sharedInstance
                    
                    
                    let block: () ->() = {
                        matrix.generatePuzzle()
                    }
                    
                    let operation = NSBlockOperation(block: block)
                    operation.qualityOfService = .UserInitiated
                    operation.queuePriority = .High
                    self.operationQueue.addOperation(operation)
            }
        }

    }
    
   /* func savedPuzzleForDifficulty(difficulty: PuzzleDifficulty) -> (Puzzle, [String:Any]?)? {
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

    }*/
    
    
    func puzzleReady(initials: [PuzzleCell], solution: [PuzzleCell]) {
        
        completionHandler?(initials: initials, solution: solution)
        completionHandler = nil
        
    }

    
    
}