//
//  CreatePuzzleViewController.swift
//  SudokuCheat
//
//  Created by Isaac Benham on 5/27/15.
//  Copyright (c) 2015 Isaac Benham. All rights reserved.
//

import Foundation
class CreatePuzzleViewController:SudokuController {
    
    var createButton = UIButton()
    var clearButton = UIButton()
    //var solution: [PuzzleCell]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.orangeColor()
        
        self.view.addSubview(createButton)
        createButton.backgroundColor = UIColor.whiteColor()
        createButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        createButton.setTitle("Create", forState: .Normal)
        createButton.layer.cornerRadius = 5.0
        createButton.addTarget(self, action: "createPuzzle", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(clearButton)
        clearButton.backgroundColor = UIColor.whiteColor()
        clearButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        clearButton.setTitle("Clear", forState: .Normal)
        clearButton.layer.cornerRadius = 5.0
        clearButton.addTarget(self, action: "clearAll", forControlEvents: .TouchUpInside)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        clearButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let solveRightEdge = NSLayoutConstraint(item: createButton, attribute: .Trailing, relatedBy: .Equal, toItem: self.board, attribute: .Trailing, multiplier: 1, constant: 0)
        let solveBottomPin = NSLayoutConstraint(item: createButton, attribute: .Bottom, relatedBy: .Equal, toItem: self.bottomLayoutGuide, attribute: .Top, multiplier: 1, constant: -8)
        let buttonWidth = NSLayoutConstraint(item: createButton, attribute: .Width, relatedBy: .Equal, toItem: self.board, attribute: .Width, multiplier: 1/3, constant: 0)
        let buttonHeight = NSLayoutConstraint(item: createButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 40)
        
        let clearWidth = NSLayoutConstraint(item: clearButton, attribute: .Width, relatedBy: .Equal, toItem: self.board, attribute: .Width, multiplier: 1/3, constant: 0)
        let clearHeight = NSLayoutConstraint(item: clearButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 40)
        let clearBottomPin = NSLayoutConstraint(item: clearButton, attribute: .Bottom, relatedBy: .Equal, toItem: self.bottomLayoutGuide, attribute: .Top, multiplier: 1, constant: -8)
        let clearLeftEdge = NSLayoutConstraint(item: clearButton, attribute: .Leading, relatedBy: .Equal, toItem: self.board, attribute: .Leading, multiplier: 1, constant: 0)
        
        
        let constraints = [solveRightEdge, solveBottomPin, buttonWidth, buttonHeight, clearWidth, clearHeight, clearBottomPin, clearLeftEdge]
        self.view.addConstraints(constraints)
        
    }

    /*
    let easyPuzzle = Puzzle()
    easyPuzzle.initialValues = []
    
    
    let cellList = [(1,1,2), (1,2,3), (1,3,6), (1,5,8), (1,6,9), (1,7,7), (2,1,9), (2,6,6), (3,2,4), (3,4,2), (3,6,5), (3,8,6),  (4,3,8), (4,4,9), (4,6,3),  (4,8,5), (5,2,9), (5,4,1), (5,6,7), (5,8,4), (6,2,1), (6,4,5), (6,6,8), (6,7,6), (7,2,9), (7,4,8), (7,6,1), (7,8,7), (8,4,7), (8,9,9), (9,3,2), (9,4,3), (9,5,9), (9,7,1), (9,8,5), (9,9,6)]
    
    
    
    
    for item in cellList {
    let pCell = PuzzleCell()
    let row = getRowIndexFromTileIndex((item.0, item.1))
    let column = getColumnIndexFromTileIndex((item.0, item.1))
    pCell.setPCell(row, column: column, value: item.2)
    //pCell.saveInBackground()
    easyPuzzle.initialValues.append(pCell)
    }
    aPuzzle.saveInBackground()
    */
    
   
   
    
    
    func createPuzzle() {
        
        /*
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0), { ()->() in
            self.matrix.generatePuzzleWithCompletion({ puzz -> () in
                self.puzzle = puzz
                self.puzzleReady()
                })
            dispatch_async(dispatch_get_main_queue(), {
                self.puzzleReady()
            })
        })*/
        
        self.matrix.generatePuzzleWithCompletion({ puzz -> () in
            self.puzzle = puzz
            self.puzzleReady()
        })
        /*
    
        let vals = [(1,2,3), (1,8,1), (2,2,9), (2,3,4), (2,4,6), (2,7,2), (2,8,3), (3,1,8), (3,2,1), (3,4,9), (3,8,4), (4,4,4),  (4,5,9), (4,8,5), (5,4,1),  (5,5,6), (6,2,9), (6,5,8), (6,6,7), (7,2,6), (7,6,5), (7,8,2), (7,9,4), (8,2,4), (8,3,9), (8,6,6), (8,7,8), (8,8,1), (9,2,5), (9,8,3)]
        var initials:[PuzzleCell] = []
        
        for item in vals {
            let row = getRowIndexFromTileIndex((item.0, item.1))
            let column = getColumnIndexFromTileIndex((item.0, item.1))
            let pCell = PuzzleCell(row: row, column: column, value: item.2)
            initials.append(pCell)
        }
        
        let mediumPuzzle = Puzzle(nonNilValues: initials)
        
        let vals2 = [(1,2,2), (1,3,5), (1,7,9), (1,8,1), (2,2,3), (2,4,1), (2,6,8), (2,9,5), (3,3,4), (3,6,2), (3,8,3), (4,5,6),  (4,7,8), (4,9,1), (6,1,6),  (6,3,9), (6,5,1), (7,2,3), (7,6,2), (7,7,5), (8,1,4), (8,4,7), (8,6,3), (8,8,1), (9,2,9), (9,3,7), (9,7,2), (9,8,6)]
        var initials2:[PuzzleCell] = []
        
        for item in vals2 {
            let row = getRowIndexFromTileIndex((item.0, item.1))
            let column = getColumnIndexFromTileIndex((item.0, item.1))
            let pCell = PuzzleCell(row: row, column: column, value: item.2)
            initials2.append(pCell)
        }
        
        let hardPuzzle = Puzzle(nonNilValues: initials2)
        
        
        let cellList = [(1,1,2), (1,2,3), (1,3,6), (1,5,8), (1,6,9), (1,7,7), (2,1,9), (2,6,6), (3,2,4), (3,4,2), (3,6,5), (3,8,6),  (4,3,8), (4,4,9), (4,6,3),  (4,8,5), (5,2,9), (5,4,1), (5,6,7), (5,8,4), (6,2,1), (6,4,5), (6,6,8), (6,7,6), (7,2,9), (7,4,8), (7,6,1), (7,8,7), (8,4,7), (8,9,9), (9,3,2), (9,4,3), (9,5,9), (9,7,1), (9,8,5), (9,9,6)]
        
        var initials3: [PuzzleCell] = []
        
        for item in cellList {
            let row = getRowIndexFromTileIndex((item.0, item.1))
            let column = getColumnIndexFromTileIndex((item.0, item.1))
            let pCell = PuzzleCell(row:row, column: column, value: item.2)
            initials3.append(pCell)
        }
        
        let easyPuzzle = Puzzle(nonNilValues: initials3)
        
        let medCount = self.matrix.eliminatePuzzleGivens(initials)
        self.matrix.rebuild()
        let hardCount = self.matrix.eliminatePuzzleGivens(initials2)
        self.matrix.rebuild()
        let easyCount = self.matrix.eliminatePuzzleGivens(initials3)
        
        
        
        println("The easy puzzle has \(easyCount) rows left; the medium puzzle has \(medCount) rows left; the hard puzzle has \(hardCount) rows left")
        
        */
    
        
        /*
        println("createPuzzle tapped")
        let valuatedTiles = nonNilTiles()
        var cells: [PuzzleCell] = cellsFromTiles(valuatedTiles)
        solution = matrix.solutionForValidPuzzle(cells)
            if solution != nil {
            let puzz = Puzzle(className: "Puzzle")
            puzz.initialValues = []
            for cell in cells {
                puzz.initialValues.append(cell)
            }
            puzz.saveInBackgroundWithTarget(self, selector: "puzzleSavedSuccessfully")
        } else {
            let alertController = UIAlertController(title: "Invalid Puzzle", message: "SudokuCheat can't save this puzzle because it has more or less than one solution.  Try again!", preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (_) in
                self.dismissViewControllerAnimated(true) {
                    ()->() in
                }
            }
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true) {
                
            }

        }
*/
    }
    
    func clearAll() {
        // alert view?
        let tiles = self.tiles()
        for tile in tiles {
            tile.value = .Nil
            tile.refreshLabel()
        }
        self.puzzle!.solution = nil
        board.selectedTile = board.getNilTiles()[0]
    }
    
    func puzzleSavedSuccessfully() {
        
        let alertController = UIAlertController(title: "Valid Puzzle", message: "Way to go! You created a valid puzzle and it has been added to the SudokuCheat puzzle library.", preferredStyle: .Alert)
        
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (_) in
            self.clearAll()
        }
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true) {
            
        }

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

}