//
//  Puzzle.swift
//  SudokuBot
//
//  Created by Isaac Benham on 4/7/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import Foundation


// this will eventually be an NSManagedObject subclass
class Puzzle {
    
    var solution: [BackingCell] = []
    var initialValues: [BackingCell] = []
    
    // Insert code here to add functionality to your managed object subclass
    
    init(initialValues: [PuzzleCell], solution:[PuzzleCell]) {
        
        
        /*let ctxt = CoreDataStack.sharedStack.managedObjectContext
        
        let entityDescriptor = NSEntityDescription.entityForName("Puzzle", inManagedObjectContext: ctxt)!
        
        super.init(entity: entityDescriptor, insertIntoManagedObjectContext: ctxt)*/
        
        //self.initialValues.setByAddingObjectsFromArray(initialValues.map({$0.toBackingCell().setPuzzleInitalAndReturn(self)}))
       // self.solution.setByAddingObjectsFromArray(solution.map({$0.toBackingCell().setPuzzleSolutionAndReturn(self)}))
        
        self.initialValues = (initialValues.map({$0.toBackingCell().setPuzzleInitalAndReturn(self)}))
        self.solution = (solution.map({$0.toBackingCell().setPuzzleSolutionAndReturn(self)}))
    }
    
    
}
