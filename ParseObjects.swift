//
//  ParseObjects.swift
//  SudokuCheat
//
//  Created by Isaac Benham on 5/26/15.
//  Copyright (c) 2015 Isaac Benham. All rights reserved.
//

import Foundation

class PuzzleCell: PFObject, PFSubclassing {
    // PFSubclassing
    static func parseClassName() -> String {
        return "PuzzleCell"
    }
    
    
    
    @NSManaged var row: Int
    @NSManaged var column: Int
    @NSManaged var value: Int
    //@NSManaged var puzzle: Puzzle
    
    func setPCell(row: Int, column:Int, value:Int = 0) {
        self.row = row
        self.column = column
        self.value = value
    }
    
    // convenience initWithCell = getRowIndex, getColumnIndex, .rawValue from passed Cell
   
}

class Puzzle: PFObject, PFSubclassing {
    
    // PFSubclassing
    static func parseClassName() -> String {
        return "Puzzle"
    }
    

    @NSManaged var initialValues: [PuzzleCell] 
    //var tiles: [Tile] = []
    
    
    func setPuzzleWithInitialValues(nonNilValues: [PuzzleCell]) {
        for cell in nonNilValues {
            self.initialValues.append(cell)
        }
    }
}
   