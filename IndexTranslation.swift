//
//  IndexTranslation.swift
//  SudokuCheat
//
//  Created by Isaac Benham on 5/11/15.
//  Copyright (c) 2015 Isaac Benham. All rights reserved.
//

import Foundation


// row/column -> TileIndex ((Box: 0-8, Tile: 0-8))
func getBox(column: Int, row: Int) -> Int {
    switch column {
    case 1, 2, 3:
        switch row {
        case 1,2,3:
            return 1
        case 4,5,6:
            return 4
        default:
            return 7
        }
    case 4,5,6:
        switch row {
        case 1,2,3:
            return 2
        case 4,5,6:
            return 5
        default:
            return 8
        }
    default:
        switch row {
        case 1,2,3:
            return 3
        case 4,5,6:
            return 6
        default:
            return 9
        }
    }
}

func getTileIndexForRow(row: Int, andColumn column: Int) -> TileIndex {
    let box = getBox(column, row: row)
    switch row {
    case 1,4,7:
        switch column {
        case 1,4,7:
            return (box, 0)
        case 2,5,8:
            return (box, 1)
        default:
            return (box, 2)
        }
    case 2,5,8:
        switch column {
        case 1,4,7:
            return (box, 3)
        case 2,5,8:
            return (box, 4)
        default:
            return (box, 5)
        }
    default:
        switch column {
        case 1,4,7:
            return (box, 6)
        case 2,5,8:
            return (box, 7)
        default:
            return (box, 8)
        }
    }
}

// TileIndex -> row/column
func getColumnIndexFromTileIndex(tileIndex: TileIndex) -> Int {
    switch tileIndex.Box{
    case 1,4,7:
        switch tileIndex.Tile{
        case 1,4,7:
            return 1
        case 2,5,8:
            return 2
        default:
            return 3
        }
    case 2,5,8:
        switch tileIndex.Tile{
        case 1,4,7:
            return 4
        case 2,5,8:
            return 5
        default:
            return 6
        }
    default:
        switch tileIndex.Tile {
        case 1,4,7:
            return 7
        case 2,5,8:
            return 8
        default:
            return 9
        }
    }
}


func getRowIndexFromTileIndex(tileIndex: TileIndex) -> Int {
    switch tileIndex.Box{
    case 1,2,3:
        switch tileIndex.Tile{
        case 1,2,3:
            return 1
        case 4,5,6:
            return 2
        default:
            return 3
        }
    case 4,5,6:
        switch tileIndex.Tile{
        case 1,2,3:
            return 4
        case 4,5,6:
            return 5
        default:
            return 6
        }
    default:
        switch tileIndex.Tile {
        case 1,2,3:
            return 7
        case 4,5,6:
            return 8
        default:
            return 9
        }
    }
}

// constraints <-> tiles

func cellsFromConstraints(constraints: [LinkedNode<PuzzleNode>]) -> [PuzzleCell] {
    var puzzleNodes: [PuzzleNode] = []
    for node in constraints {
        if node.key != nil {
            puzzleNodes.append(node.key!)
        }
    }
    var cells: [PuzzleCell] = []
    for node in puzzleNodes {
        let cell = PuzzleCell(row: node.row!, column: node.column!, value: node.value!)
        cells.append(cell)
    }
    return cells
}

func tileForConstraint(node: PuzzleNode, tiles:[Tile]) -> Tile? {
    if let cRow = node.row {
        if let cCol = node.column {
            for t in tiles {
                if t.getColumnIndex() == cCol && t.getRowIndex() == cRow {
                    return t
                }
            }
        }
    }
    return nil
}


func translateCellsToConstraintList(cells:[PuzzleCell])->[PuzzleNode] {
    var matrixRowArray = [PuzzleNode]()
    for cell in cells {
        let cIndex = cell.column
        let rIndex = cell.row
        let mRow:PuzzleNode = PuzzleNode(value: cell.value, column: cIndex, row: rIndex, box: getBox(cIndex, row: rIndex))
        matrixRowArray.append(mRow)
    }
    return matrixRowArray
}

//tiles -> cells
func cellsFromTiles(tiles:[Tile]) -> [PuzzleCell] {
    var cells: [PuzzleCell] = []
    for tile in tiles {
        let val = tile.value.rawValue
        let row = tile.getRowIndex()
        let column = tile.getColumnIndex()
        let pCell = PuzzleCell(row: row, column: column, value: val)
        cells.append(pCell)
    }
    
    return cells
}

// other utils

var GlobalMainQueue: dispatch_queue_t {
    return dispatch_get_main_queue()
}

var GlobalUserInteractiveQueue: dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.rawValue), 0)
}

var GlobalUserInitiatedQueue: dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)
}

var GlobalUtilityQueue: dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.rawValue), 0)
}

var GlobalBackgroundQueue: dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)
}

