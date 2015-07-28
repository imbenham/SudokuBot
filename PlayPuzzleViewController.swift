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
    
   
    let clearButton: UIButton = UIButton(tag: 0)
    let hintButton: UIButton = UIButton(tag: 1)
    let optionsButton: UIButton = UIButton(tag: 2)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.orangeColor()

    }
    
    override func viewWillLayoutSubviews() {
        setUpButtons()
    }
    
    
    func setUpButtons() {
        let buttons = [clearButton, hintButton, optionsButton]
        
        for button in buttons {
            view.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            let tag = button.tag

            let pinAttribute: NSLayoutAttribute = tag == 0 ? .Leading : .Trailing
            
            let widthMultiplier: CGFloat = tag == 1 ? 1/9 : 1/4
            
            let bottomPinOffset: CGFloat = tag == 1 ? -40 : -8
            

            
            
            // lay out the buttons
            
            
            let width = NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: numPad, attribute: .Width, multiplier: widthMultiplier, constant: 0)
            let height = NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: numPad, attribute: .Height, multiplier: 1, constant: 0)
            let bottomPin = NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal, toItem: self.bottomLayoutGuide, attribute: .Top, multiplier: 1, constant: bottomPinOffset)
            let sidePin = NSLayoutConstraint(item: button, attribute: pinAttribute, relatedBy: .Equal, toItem: numPad, attribute: pinAttribute, multiplier: 1, constant: 0)
            
            let constraints = tag == 1 ? [width, height, bottomPin, NSLayoutConstraint(item: button, attribute: .CenterX, relatedBy: .Equal, toItem: numPad, attribute: .CenterX, multiplier: 1, constant: 0)] : [width, height, bottomPin, sidePin]
            self.view.addConstraints(constraints)
            
            // configure the buttons
            
            let buttonInfo = buttonInfoForTag(tag)
            let npHeight = self.numPadHeight
            
            let buttonRadius:CGFloat = tag == 1 ? npHeight/2 : 5.0
            
            button.backgroundColor = UIColor.whiteColor()
            button.setTitleColor(UIColor.blackColor(), forState: .Normal)
            button.setTitle(buttonInfo.title, forState: .Normal)
            button.layer.cornerRadius = buttonRadius
            button.layer.borderColor = UIColor.blackColor().CGColor
            button.layer.borderWidth = 2.0
            button.addTarget(self, action: Selector(buttonInfo.action), forControlEvents: .TouchUpInside)
            
            
        }

    }
    
    func buttonInfoForTag(tag: Int) -> (title: String, action: String) {
        switch tag {
        case 0:
            return ("Clear", "clearAll")
        case 1:
            return ("?", "showHint:")
        default:
            return ("Options", "showOptions:")
        }
    }
    
    
    override func puzzleReady() {
        let someCells:[PuzzleCell] = puzzle!.initialValues
        for pCell in someCells {
            let index = getTileIndexForRow(pCell.row, andColumn: pCell.column)
            
            let tile = board.tileAtIndex(index)
            tile.value = TileValue(rawValue: pCell.value)!
            tile.userInteractionEnabled = false
            tile.labelColor = UIColor.blackColor()
        }
        let startingNils = nilTiles
        if startingNils.count != 0 {
            board.selectedTile = startingNils[0]
        }
        
        
        for tile in nilTiles {
            tile.labelColor = UIColor.redColor()
            tile.userInteractionEnabled = true
        }
        
    }
    
    func clearSolution() {
        let nils = startingNils
        
        for tile in nils {
             tile.value = .Nil
        }
    }
    
    func clearAll() {
        
        let tiles = self.tiles
        for tile in tiles {
            tile.value = .Nil
        }

    }
    
    func showHint(sender: AnyObject) {
        print("Hint me!")
        
        // pull a value from the puzzle solution and animate it onto the board
        
        
    }
    
    func showOptions(sender: AnyObject) {
        print("Options!")
        
       
        let optionSheet = self.storyboard!.instantiateViewControllerWithIdentifier("options")
        navigationController!.showViewController(optionSheet, sender: sender)
    }
    
    override func valueSelected(value: Int) {
        super.valueSelected(value)
        if nilTiles.count == 0 {
            checkSolution()
        }
    }
    
    func checkSolution() {
        if solution == nil {
            solution = Matrix.sharedInstance.solutionForValidPuzzle(puzzle!.initialValues)!
        }
        

        for tile in solution! {
           let tIndex = getTileIndexForRow(tile.row, andColumn: tile.column)
            if board.tileAtIndex(tIndex).value.rawValue != tile.value {
                return
            }
        }
        puzzleSolved()

    }
    
    override func viewDidAppear(animated: Bool) {
        if self.puzzle == nil {
            fetchPuzzle()
        }
    }
    
    
    func puzzleSolved() {
        
        let alertController = UIAlertController(title: "Puzzle Solved", message: "Well done!", preferredStyle: .Alert)
        
        let newPuzz = UIAlertAction(title: "Play Again!", style: .Default) {(_) in
            self.clearAll()
            self.fetchPuzzle()
        }
        
        alertController.addAction(newPuzz)
        
        let current = Matrix.sharedInstance.getRawDifficultyForPuzzle(difficulty)
        let max = Matrix.sharedInstance.getRawDifficultyForPuzzle(.Insane)
        let newLevel = current + 10 > max ? PuzzleDifficulty.Insane : PuzzleDifficulty.Custom(current+10)
        
        if difficulty != .Insane {
            let harderPuzz = UIAlertAction(title: "Slightly tougher", style: .Default) { (_) in
                self.difficulty = newLevel
                self.clearAll()
                self.fetchPuzzle()
            }
            alertController.addAction(harderPuzz)
        }
        

        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (_) in
            self.navigationController!.popViewControllerAnimated(true)
        }
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true) {
    
        }
    }

}