//
//  PuzzleStore.swift
//  SudokuCheat
//
//  Created by Isaac Benham on 5/25/15.
//  Copyright (c) 2015 Isaac Benham. All rights reserved.
//

import Foundation

class PuzzleStore {
    //let user = PFUser.currentUser()
    
    static let sharedInstance = PuzzleStore()
    
    func getPuzzleForController(controller: SudokuController) {
        let query = PFQuery(className: "Puzzle")
        query.includeKey("initialValues")
        query.findObjectsInBackgroundWithBlock{
            (objects: [AnyObject]?, error: NSError?) -> () in
            
            if let obs = objects  {
                let puzzles = obs as! [Puzzle]
                let random = Int(arc4random())
                let index = random % puzzles.count
                controller.puzzle = puzzles[index]
                controller.puzzleReady()
            }
        }
    }
}