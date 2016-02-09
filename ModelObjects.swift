//
//  ParseObjects.swift
//  SudokuCheat
//
//  Created by Isaac Benham on 5/26/15.
//  Copyright (c) 2015 Isaac Benham. All rights reserved.
//

import Foundation


struct ColumnHeader {
    let row:Int
    let column:Int
    let value:Int
    let box:Int
    
    init(value:Int = 0, column:Int = 0, row:Int = 0, box:Int = 0) {
        self.value = value
        self.column = column
        self.box = box
        self.row = row
    }

}

func == (lhs: ColumnHeader, rhs: ColumnHeader) -> Bool {
    
    if (lhs.row == rhs.row) && (lhs.box == rhs.box) && (lhs.column == rhs.column) && (lhs.value == rhs.value) {
        return true
    }
    
    return false
}

extension ColumnHeader: Equatable{}

func == (lhs: ColumnHeader, var rhs: PuzzleCell) -> Bool {
    
    let nonboxConstraint = lhs.box == 0
    var lhsProps = nonboxConstraint ? [lhs.row, lhs.column, lhs.value] : [lhs.row, lhs.column, lhs.value, lhs.box]
    var rhsProps = nonboxConstraint ? [rhs.row, rhs.column, rhs.value] : [rhs.row, rhs.column, rhs.value, rhs.box]
    var count = 0
    
    while count < 2 && !((lhsProps.count + count) < 2)  {
        let cH = lhsProps.removeFirst()
        let pC = rhsProps.removeFirst()
        if cH == pC { count += 1}
    }
    
    return count == 2
}
func == (lhs: PuzzleCell, rhs: ColumnHeader) -> Bool {
    return rhs == lhs
}


struct PuzzleCell: Hashable {
 
    
    let row: Int
    let column: Int
    var value: Int
    lazy var box: Int = {
        switch self.column {
        case 1, 2, 3:
            switch self.row {
            case 1,2,3:
                return 1
            case 4,5,6:
                return 4
            default:
                return 7
            }
        case 4,5,6:
            switch self.row {
            case 1,2,3:
                return 2
            case 4,5,6:
                return 5
            default:
                return 8
            }
        default:
            switch self.row {
            case 1,2,3:
                return 3
            case 4,5,6:
                return 6
            default:
                return 9
            }
        }
    }()

  
    
    init(row: Int, column:Int, value:Int = 0) {
        self.row = row
        self.column = column
        self.value = value
    }
    

    init(cell:PuzzleCell) {
        self.row = cell.row
        self.column = cell.column
        self.value = cell.value
    }
    
    
    init?(dict: [String: Int]) {
        if let row = dict["row"], column = dict["column"], value = dict["value"] {
            self.init(row:row, column:column, value:value)
        } else {
            return nil
        }
    }
    
    // hashable conformance
    
    var hashValue: Int {
       
       return Int("\(row)\(column)\(value)")!
    
    }
    
    func asDict() -> NSDictionary {
        let dict = NSMutableDictionary()
        
        dict["row"] = row
        dict["column"] = column
        dict["value"] = value
        
        return dict
    }
    
}



func == (lhs: PuzzleCell, rhs: PuzzleCell) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

extension PuzzleCell: Equatable {}

class Puzzle: NSObject, NSCoding {
    
    
    var initialValues: [PuzzleCell]!
    var solution: [PuzzleCell]!
    
    init(nonNilValues: [PuzzleCell]) {
        self.initialValues = nonNilValues
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        
        var givens = [NSDictionary]()
        for cell in initialValues {
            givens.append(cell.asDict())
        }
        
        var sol = [NSDictionary]()
        for cell in solution {
            sol.append(cell.asDict())
        }
        
        aCoder.encodeObject(givens, forKey: "givens")
        
        aCoder.encodeObject(sol, forKey: "solution")
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        initialValues = []
        solution = []
        if let initials = aDecoder.decodeObjectForKey("givens") as? [[String: Int]], sol = aDecoder.decodeObjectForKey("solution") as? [[String: Int]] {
            for dict in initials {
                let cell = PuzzleCell(row: dict["row"]!, column: dict["column"]!, value: dict["value"]!)
                initialValues.append(cell)
            }
            
            for dict in sol {
                let cell = PuzzleCell(row: dict["row"]!, column: dict["column"]!, value: dict["value"]!)
                solution.append(cell)

            }
            
        } else {
            return nil
        }
      
    }
    
    /*func asData() -> NSData {
        var givenList: [Int] = []
        for cell in initialValues {
            givenList.append(cell.hashValue)
        }
        var solutionList: [Int] = []
        for cell in solution! {
            solutionList.append(cell.hashValue)
        }
        
        let dict = ["givens": givenList, "solution": solutionList]
        
        let data = NSKeyedArchiver.archivedDataWithRootObject(dict)
        
        return data
    }
    
    class func fromData(data:NSData) -> Puzzle? {
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
            let puzz = Puzzle(nonNilValues: givenCells)
            puzz.solution = solutionCells
            return puzz
        }
        return nil
    }*/
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
   