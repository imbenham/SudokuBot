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
        setUpButtons()
        

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "") // use this to tinker with settings??

    }
    
    
    func setUpButtons() {
        let buttons = [clearButton, hintButton, optionsButton]
        
        for button in buttons {
            view.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            let tag = button.tag
            //let leftNeighbor = tag == 2 ? buttons[1] : numPad
            let pinAttribute: NSLayoutAttribute = tag == 0 ? .Leading : .Trailing
            

            
            
            // lay out the buttons
            
            let width = NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: numPad, attribute: .Width, multiplier: 1/4, constant: 0)
            let height = NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: numPad, attribute: .Height, multiplier: 1, constant: 0)
            let bottomPin = NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal, toItem: self.bottomLayoutGuide, attribute: .Top, multiplier: 1, constant: -8)
            let sidePin = NSLayoutConstraint(item: button, attribute: pinAttribute, relatedBy: .Equal, toItem: numPad, attribute: pinAttribute, multiplier: 1, constant: 0)
            
            let constraints = tag == 1 ? [width, height, bottomPin, NSLayoutConstraint(item: button, attribute: .CenterX, relatedBy: .Equal, toItem: numPad, attribute: .CenterX, multiplier: 1, constant: 0)] : [width, height, bottomPin, sidePin]
            self.view.addConstraints(constraints)
            
            // configure the buttons
            
            let buttonInfo = buttonInfoForTag(tag)
            
            button.backgroundColor = UIColor.whiteColor()
            button.setTitleColor(UIColor.blackColor(), forState: .Normal)
            button.setTitle(buttonInfo.title, forState: .Normal)
            button.layer.cornerRadius = 5.0
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
            return ("Hint", "showHint:")
        default:
            return ("Options", "showOptions:")
        }
    }
    
    override func boardReady() {
        /*
        if self.puzzle == nil {
            refreshPuzzle()
        }*/
    }
    
    override func puzzleReady() {
        print("puzzleReady called")
        let someCells:[PuzzleCell] = puzzle!.initialValues
        for pCell in someCells {
            let index = getTileIndexForRow(pCell.row, andColumn: pCell.column)
            
            let tile = board.tileAtIndex(index)
            tile.value = TileValue(rawValue: pCell.value)!
            tile.userInteractionEnabled = false
            tile.labelColor = UIColor.blackColor()
        }
        let startingNils = nilTiles()
        if startingNils.count != 0 {
            board.selectedTile = startingNils[0]
        }
        
        
        for tile in nilTiles() {
            tile.labelColor = UIColor.redColor()
            tile.userInteractionEnabled = true
        }
        
    }
    
    func clearAll() {
        
        let tiles = self.tiles()
        for tile in tiles {
            tile.value = .Nil
        }

        fetchPuzzle()
       /* for tile in startingNils {
            tile.value = TileValue.Nil
        }*/

    }
    
    func showHint(sender: AnyObject) {
        print("Hint me!")
    }
    
    func showOptions(sender: AnyObject) {
        print("Options!")
        
       
        let optionSheet = self.storyboard!.instantiateViewControllerWithIdentifier("options")
        navigationController!.showViewController(optionSheet, sender: sender)
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
            fetchPuzzle()
        }
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