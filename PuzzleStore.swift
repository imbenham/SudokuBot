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
    
    
    func getPuzzleForController(controller: SudokuController, withCompletionHandler handler: (Puzzle -> ())) {
        
        // PLACEHOLDER-- HANDLE SAVED PUZZLE
        if false {
            return
        } else {
            
            controller.prepareForLongFetch()
            
            
            dispatch_async(Utils.ConcurrentPuzzleQueue) {
                self.completionHandler = handler
                self.difficulty = controller.difficulty
                Matrix.sharedInstance.generatePuzzle()
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
        
        dispatch_async(Utils.GlobalMainQueue) {
            self.completionHandler!(Puzzle.init(initialValues: initials, solution: solution))
            self.completionHandler = nil
        }
        
      
        
    }

    
    
}