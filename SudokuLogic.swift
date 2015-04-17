//
//  SudokuLogic.swift
//  SudokuCheat
//
//  Created by Isaac Benham on 4/17/15.
//  Copyright (c) 2015 Isaac Benham. All rights reserved.
//

import UIKit

class SudokuController: UIViewController {
    // all the logic of the Sudoku game will be defined here, allowing the main view controller to focus on the task of handling user events
    
    typealias TileIndex = (Box:Int, Tile:Int)
    let board:SudokuBoard = SudokuBoard(frame: CGRectZero)
    
    var boxes:[Box]
    var tiles: [Tile]
    
    required init(coder aDecoder: NSCoder) {
        let someBoxes = board.convertBoxesToContainBoxes()
        boxes = someBoxes
        tiles = {
            var mutableTiles = [Tile]()
            for box in someBoxes {
                mutableTiles.extend(box.convertBoxesToContainTiles())
            }
            return mutableTiles
            }()
        super.init(coder: aDecoder)
    }
    
    func tileAtIndex(_index: TileIndex) -> Tile {
        return board.getBoxAtIndex(_index.0).getTileAtIndex(_index.1)
    }
    
}