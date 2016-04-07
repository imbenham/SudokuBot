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
    let boardIndex: Int
    
    init(value:Int = 0, column:Int = 0, row:Int = 0, box:Int = 0, boardIndex:Int = 0) {
        
        self.value = value
        self.column = column
        self.box = box
        self.row = row
        self.boardIndex = boardIndex
    }
    
    var companion: ColumnHeader? {
        switch boardIndex {
        case 0:
            if row < 4 && column < 4 {
                return ColumnHeader(value: value, column: column + 6, row: row + 6, boardIndex: 1)
            } else if row < 4 && column > 6 {
                return ColumnHeader(value: value, column: column - 6 , row: row + 6,  boardIndex: 2)
            } else if row > 6 && column > 6 {
                return ColumnHeader(value: value, column: column - 6, row: row - 6,  boardIndex: 3)
            } else if row > 6 && column < 4 {
                return ColumnHeader(value: value, column: column + 6, row: row - 6,  boardIndex: 4)
            }
            return nil
            
        case 1:
            if row > 6 && column > 6 {
                return ColumnHeader(value: value, column: column - 6, row: row - 6,  boardIndex: 0)
            }
            return nil
        case 2:
            if row > 6 && column < 4 {
                return ColumnHeader(value: value, column: column + 6, row: row - 6,  boardIndex: 0)
            }
            return nil
        case 3:
            if row < 4 && column < 4 {
                return ColumnHeader(value: value, column: column + 6 , row: row + 6, boardIndex: 0)
            }
            return nil
        case 4:
            if row < 4 && column > 6 {
                return ColumnHeader(value: value, column: column - 6, row: row + 6, boardIndex: 0)
            }
            return nil
        default:
            return nil
        }
    }
    
    var hash: String? {
        get {
            if let companion = companion {
                if companion.boardIndex == 0 {
                    return  String(value)+String(column)+String(row)+String(box)+String(boardIndex)
                }
                
                return String(companion.value)+String(companion.column)+String(companion.row)+String(companion.box)+String(companion.boardIndex)
            }
            return nil
        }
    }
    
}

func == (lhs: ColumnHeader, rhs: ColumnHeader) -> Bool {
    if lhs.boardIndex != rhs.boardIndex {
        return false
    }
    
    if lhs.row != rhs.row {
        return false
    }
    
    
    if lhs.column != rhs.column {
        return false
    }
    
    if  lhs.value != rhs.value {
        return false
    }
    
    if lhs.box != rhs.box {
        return false
    }
    
    return true
}

extension ColumnHeader: Equatable{}

func == (lhs: ColumnHeader, rhs: PuzzleCell) -> Bool {
    
    guard lhs.boardIndex == rhs.boardIndex else {
        return false
    }
    
    var rhs = rhs
    
    if lhs.row > 0 && lhs.row != rhs.row {
        return false
    }
    
    if lhs.column > 0 && lhs.column != rhs.column {
        return false
    }
    
    if lhs.value > 0 && lhs.value != rhs.value {
        return false
    }
    
    if lhs.box > 0 && lhs.box != rhs.box {
        return false
    }
    
    return true
    
}
func == (lhs: PuzzleCell, rhs: ColumnHeader) -> Bool {
    return rhs == lhs
}


struct PuzzleCell: Hashable {
    
    
    let row: Int
    let column: Int
    var value: Int
    let boardIndex: Int
    
    
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
    
    
    
    init(row: Int, column:Int, value:Int = 0, boardIndex:Int = 0) {
        
        self.row = row
        self.column = column
        self.value = value
        self.boardIndex = boardIndex
    }
    
    
    init(cell:PuzzleCell) {
        self.row = cell.row
        self.column = cell.column
        self.value = cell.value
        self.boardIndex = cell.boardIndex
    }
    
    
    // hashable conformance
    
    var hashValue: Int {
        
        return Int("\(boardIndex)\(row)\(column)\(value)")!
        
    }
    
    
    // conversion to managed backing cells
    
    func toBackingCell() -> BackingCell {
        
        return BackingCell(cell: self)
        
    }
    
       
}



func == (lhs: PuzzleCell, rhs: PuzzleCell) -> Bool {
    return lhs.hashValue == rhs.hashValue
}



extension PuzzleCell: Equatable {}