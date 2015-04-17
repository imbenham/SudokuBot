//
//  SudokuLogic.swift
//  SudokuCheat
//
//  Created by Isaac Benham on 4/17/15.
//  Copyright (c) 2015 Isaac Benham. All rights reserved.
//

import UIKit

extension SudokuBoard {
    // add game-logic related methods
    func getBoxAtIndex(index: Int) -> Box {
        let boxOfBoxes = self.boxes as! [Box]
        return boxOfBoxes[index]
    }
}

extension Box {
    // add game-logic related methods
    func getTileAtIndex(index: Int) -> Tile {
        return boxes[index] as! Tile
    }
}

extension Tile {
    // add game-logic related methods
    typealias TileIndex = (Box:Int, Tile:Int)
    
    func tileIndex() -> TileIndex {
        return (parentSquare!.index, index)
    }
    
    func indexString() -> String {
        let box = tileIndex().0
        let tile = tileIndex().1
        return "This tile's index is: \(box).\(tile) "
    }

}

class SudokuController: UIViewController {
    // all the logic of the Sudoku game will be defined here, allowing the main view controller to focus on the task of handling user events
    
    typealias TileIndex = (Box:Int, Tile:Int)
    let board = SudokuBoard(index: 0, withParent: nil)
    
    var boxes:[Box]
    var tiles: [Tile]
    var boxRows = [[Box]]()
    var boxColumns = [[Box]]()
    var tileRows = [Tile]()
    var tileColumns = [Tile]()
    

    required init(coder aDecoder: NSCoder) {
        let someBoxes = board.boxes as! [Box]
        boxes = someBoxes
        tiles = {
            var mutableTiles = [Tile]()
            for box in someBoxes {
                let containedTiles = box.boxes as! [Tile]
                mutableTiles.extend(containedTiles)
            }
            return mutableTiles
            }()
        super.init(coder: aDecoder)
    }
    
    func makeRowsAndColumns(){
        for rc in 1...3 {
            let aRow = board.makeRow(Row(rawValue: rc)!) as! [Box]
            boxRows.append(aRow)
            let aColumn = board.makeColumn(Column(rawValue: rc)!) as! [Box]
            boxColumns.append(aColumn)
        }
    }
    func tileAtIndex(_index: TileIndex) -> Tile {
        return board.getBoxAtIndex(_index.0).getTileAtIndex(_index.1)
    }
}