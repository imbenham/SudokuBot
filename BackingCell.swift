//
//  BackingCell.swift
//  SudokuBot
//
//  Created by Isaac Benham on 4/7/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import Foundation

// this will eventually be NSManagedObject subclass

class BackingCell {
    
    var row: Int
    var value: Int
    var board: Int
    var column: Int
    var revealed: Bool
    var assignedValue: Int?
    var notes: String?
    var puzzleSolution: Puzzle?
    var puzzleInitial: Puzzle?

    
    // Insert code here to add functionality to your managed object subclass
    
    
    var notesArray: [Int] {
        get {
            guard let notes = self.notes else {
                return []
            }
            
            let notesAsArray = Array(notes.characters)
            
            return notesAsArray.map({Int(String($0))!})
        }
        
        set {
            var newString = ""
            for num in newValue.sort({$0<$1}) {
                newString += "\(num)"
            }
            self.notes = newString
            // save puzzle
        }
    }
    
    init(cell: PuzzleCell) {
        /*
        
        let ctxt = CoreDataStack.sharedStack.managedObjectContext
        
        let entityDescriptor = NSEntityDescription.entityForName("BackingCell", inManagedObjectContext: ctxt)!
        
        super.init(entity: entityDescriptor, insertIntoManagedObjectContext: ctxt)
        */
        
        self.row = cell.row
        self.column = cell.column
        self.value = cell.value
        self.board = cell.boardIndex
        self.revealed = false
        
    }
    
    
    func setPuzzleInitalAndReturn(puzzle:Puzzle) -> BackingCell {
        self.puzzleInitial = puzzle
        return self
    }
    
    func setPuzzleSolutionAndReturn(puzzle:Puzzle) -> BackingCell {
        self.puzzleSolution = puzzle
        return self
    }
    
    
    func convertToTileIndex() -> TileIndex {
        let boardIndex = Int(self.board)
        let rowIndex = Int(self.row)
        let columnIndex = Int(self.column)
        
        return getTileIndex(boardIndex, row: rowIndex, column: columnIndex)
    }
    
    
}
