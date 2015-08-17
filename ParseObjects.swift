//
//  ParseObjects.swift
//  SudokuCheat
//
//  Created by Isaac Benham on 5/26/15.
//  Copyright (c) 2015 Isaac Benham. All rights reserved.
//

import Foundation
struct PuzzleCell: Hashable {
    // PFSubclassing
   
    
    
    
    let row: Int
    let column: Int
    var value: Int
    //@NSManaged var puzzle: Puzzle
    
    init(row: Int, column:Int, value:Int = 0) {
        self.row = row
        self.column = column
        self.value = value
    }
    
    
    
    // hashable conformance
    
    var hashValue: Int {
        let rowString = String(row)
        let columnString = String(column)
        let valString = String(value)
        
        return Int(rowString+columnString+valString)!
    }
    
}

func == (lhs: PuzzleCell, rhs: PuzzleCell) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

class Puzzle {
    
    
    let initialValues: [PuzzleCell]
    var solution: [PuzzleCell]? 
    
    init(nonNilValues: [PuzzleCell]) {
        self.initialValues = nonNilValues
    }
    
    func asData() -> NSData {
        var givenList: [Int] = []
        for cell in initialValues {
            givenList.append(cell.hashValue)
        }
        var solutionList: [Int] = []
        for cell in initialValues {
            solutionList.append(cell.hashValue)
        }
        
        let dict = ["givens": givenList, "solution": solutionList]
        
        let data = NSKeyedArchiver.archivedDataWithRootObject(dict)
        
        return data
    }
    
    class func fromData(data:NSData) -> Puzzle? {
        if let dict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [String: [Int]], givens = dict["givens"], solution = dict["solution"] {
            var givenCells: [PuzzleCell] = []
            for cell in givens {
                if let rcv = decomposeInt(cell) {
                    givenCells.append(PuzzleCell(row: rcv.0, column: rcv.1, value: rcv.2))
                } else {
                    return nil
                }
            }
            var solutionCells: [PuzzleCell] = []
            for cell in solution {
                if let rcv = decomposeInt(cell) {
                    solutionCells.append(PuzzleCell(row: rcv.0, column: rcv.1, value: rcv.2))
                } else {
                    return nil
                }
            }
            let aPuzz = Puzzle(nonNilValues: givenCells)
            aPuzz.solution = solutionCells
        }
        return nil
    }
}

func decomposeInt(threeDigitInt:Int) -> (Int,Int,Int)? {
    let stringified = String(threeDigitInt) as NSString
    let string1 = stringified.substringWithRange(NSRange(location: 0, length: 1))
    let string2 = stringified.substringWithRange(NSRange(location: 1, length: 1))
    let string3 = stringified.substringWithRange(NSRange(location: 2, length: 1))
    
    if let row = Int(string1), column = Int(string2), value = Int(string3) {
        return (row, column, value)
    }
    
    return nil
}

/*
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
}*/
   