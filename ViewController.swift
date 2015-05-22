//
//  ViewController.swift
//  SudokuCheat
//
//  Created by Isaac Benham on 4/14/15.
//  Copyright (c) 2015 Isaac Benham. All rights reserved.
//

import UIKit
// look up voice-over



class ViewController: SudokuController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.addSubview(board)
        self.setUpBoard()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpBoard() {
        board.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let topPin = NSLayoutConstraint(item: board, attribute: .Top, relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 20)
        let centerPin = NSLayoutConstraint(item: board, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
        let boardWidth = NSLayoutConstraint(item: board, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 0.95, constant: 0)
        let boardHeight = NSLayoutConstraint(item: board, attribute: .Height, relatedBy: .Equal, toItem: board, attribute: .Width, multiplier: 1, constant: 0)
        
        let constraints = [topPin, centerPin, boardWidth, boardHeight]
        self.view.addConstraints(constraints)
        
        board.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 1, alpha: 1)
        board.prepareBoxes()
        let aPuzzle: [Cell] = [((1,1),TileValue.Two), ((1,2),TileValue.Three), ((1,3),TileValue.Six), ((1,5),TileValue.Eight), ((1,6),TileValue.Nine), ((1,7),TileValue.Seven), ((2,1),TileValue.Nine), ((2,6),TileValue.Six), ((3,2),TileValue.Four), ((3,4),TileValue.Two), ((3,6), TileValue.Five), ((3,8),TileValue.Six),  ((4,3),TileValue.Eight), ((4,4),TileValue.Nine), ((4,6),TileValue.Three),  ((4,8),TileValue.Five), ((5,2),TileValue.Nine),  ((5,4),TileValue.One), ((5,6), TileValue.Seven),  ((5,8),TileValue.Four),  ((6,2),TileValue.One), ((6,4),TileValue.Five), ((6,6),TileValue.Eight)]//, ((6,7),TileValue.Six)//, ((7,2),TileValue.Nine), ((7,4),TileValue.Eight), ((7,6),TileValue.One), ((7,8),TileValue.Seven), ((8,4),TileValue.Seven), ((8,9), TileValue.Nine), ((9,3),TileValue.Two)]//, ((9,4),TileValue.Three), ((9,5),TileValue.Nine), ((9,7),TileValue.One), ((9,8),TileValue.Five), ((9,9), TileValue.Six)]
        board.loadPuzzleWithNonNilIndexValues(aPuzzle)
        
        println("row choices: \(board.puzzle!.matrix.rowsAndColumns.verticalCount()), cell constraints: \(board.puzzle!.matrix.rowsAndColumns.lateralCount())")
        
        
        //let columnsList = board.puzzle!.tileColumns
       /* for band in columnsList {
            println(band.Tiles)
        }*/
    }
    
}

class SudokuController: UIViewController {
    // all the logic of the Sudoku game will be defined here, allowing the main view controller to focus on the task of handling user events
    
    let board = SudokuBoard(index: 0, withParent: nil)
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        
    }
    
    override func viewDidLayoutSubviews() {
        for tile in board.puzzle!.tiles {
            tile.label.text = tile.getValueText()
        }
    }
    
    func tileAtIndex(_index: TileIndex) -> Tile {
        return board.getBoxAtIndex(_index.0).getTileAtIndex(_index.1)
    }
    
    func didSetUpBoard() {
        let nilTiles = board.getNilTiles()
        for tile in nilTiles {
            tile.label.textColor = UIColor.redColor()
        }
    }
}

