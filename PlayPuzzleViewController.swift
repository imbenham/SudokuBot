//
//  PlayPuzzleViewController.swift
//  SudokuCheat
//
//  Created by Isaac Benham on 5/25/15.
//  Copyright (c) 2015 Isaac Benham. All rights reserved.
//

import Foundation
class PlayPuzzleViewController: SudokuController {

    var solution: [PuzzleCell]?
    var startingNils: [Tile] = []
    
   
    let clearButton: UIButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.orangeColor()
        
        self.view.addSubview(clearButton)
        
        clearButton.backgroundColor = UIColor.whiteColor()
        clearButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        clearButton.setTitle("Clear", forState: .Normal)
        clearButton.layer.cornerRadius = 5.0
        clearButton.addTarget(self, action: "clearAll", forControlEvents: .TouchUpInside)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        
        let clearWidth = NSLayoutConstraint(item: clearButton, attribute: .Width, relatedBy: .Equal, toItem: self.board, attribute: .Width, multiplier: 1/3, constant: 0)
        let clearHeight = NSLayoutConstraint(item: clearButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 40)
        let clearBottomPin = NSLayoutConstraint(item: clearButton, attribute: .Bottom, relatedBy: .Equal, toItem: self.bottomLayoutGuide, attribute: .Top, multiplier: 1, constant: -8)
        let clearCenterX = NSLayoutConstraint(item: clearButton, attribute: .CenterX, relatedBy: .Equal, toItem: self.board, attribute: .CenterX, multiplier: 1, constant: 0)
        
        let constraints = [clearWidth, clearHeight, clearBottomPin, clearCenterX]
        self.view.addConstraints(constraints)
        
    }

    
    override func boardReady() {
        /*
        if self.puzzle == nil {
            refreshPuzzle()
        }*/
    }
    
    override func puzzleReady() {
        
        let someCells:[PuzzleCell] = puzzle!.initialValues
        for pCell in someCells {
            let index = getTileIndexForRow(pCell.row, andColumn: pCell.column)
            
            let tile = board.tileAtIndex(index)
            tile.value = TileValue(rawValue: pCell.value)!
            tile.userInteractionEnabled = false
        }
        let startingNils = nilTiles()
        if startingNils.count != 0 {
            board.selectedTile = startingNils[0]
        }
        
        
        for tile in nilTiles() {
            tile.labelColor = UIColor.redColor()
        }
        
    }
    
    func clearAll() {

        for tile in startingNils {
            tile.value = TileValue.Nil
        }

    }
    
    override func valueSelected(value: Int) {
        super.valueSelected(value)
        if nilTiles().count == 0 {
            checkSolution()
        }
    }
    
    func checkSolution() {
      /*
        if solution == nil {
            solution = matrix.solutionForValidPuzzle(puzzle!.initialValues)!
        }

        for tile in solution! {
           let tIndex = getTileIndexForRow(tile.row, andColumn: tile.column)
            if board.tileAtIndex(tIndex).value.rawValue != tile.value {
                return
            }
        }
        puzzleSolved()
*/

    }
    
    override func viewDidAppear(animated: Bool) {
        if self.puzzle == nil {
            refreshPuzzle()
        }
    }
    
    func refreshPuzzle() {
        PuzzleStore.sharedInstance.getRandomPuzzleForController(self)
    }
    
    func puzzleSolved() {
        
        let alertController = UIAlertController(title: "Puzzle Solved", message: "Well done!", preferredStyle: .Alert)

        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (_) in
            self.navigationController!.popViewControllerAnimated(true)
        }
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true) {
    
        }
    }

}