//
//  CheatViewController.swift
//  SudokuCheat
//
//  Created by Isaac Benham on 5/25/15.
//  Copyright (c) 2015 Isaac Benham. All rights reserved.
//

import Foundation

class CheatViewController: SudokuController {
    
    let solveButton: UIButton = UIButton()
    let clearButton: UIButton = UIButton()
    var shown = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        originalContentView.backgroundColor = UIColor.orangeColor()
        
        originalContentView.addSubview(solveButton)
        solveButton.backgroundColor = UIColor.whiteColor()
        solveButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        solveButton.setTitle("Solve", forState: .Normal)
        solveButton.layer.cornerRadius = 5.0
        solveButton.addTarget(self, action: "solvePuzzle", forControlEvents: .TouchUpInside)
        originalContentView.addSubview(clearButton)
        clearButton.backgroundColor = UIColor.whiteColor()
        clearButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        clearButton.setTitle("Clear", forState: .Normal)
        clearButton.layer.cornerRadius = 5.0
        clearButton.addTarget(self, action: "clearAll", forControlEvents: .TouchUpInside)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(0, forKey: "symbolSet")
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        solveButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        
        let solveRightEdge = NSLayoutConstraint(item: solveButton, attribute: .Trailing, relatedBy: .Equal, toItem: self.board, attribute: .Trailing, multiplier: 1, constant: 0)
        let solveBottomPin = NSLayoutConstraint(item: solveButton, attribute: .Bottom, relatedBy: .Equal, toItem: self.bottomLayoutGuide, attribute: .Top, multiplier: 1, constant: -8)
        let buttonWidth = NSLayoutConstraint(item: solveButton, attribute: .Width, relatedBy: .Equal, toItem: self.board, attribute: .Width, multiplier: 1/3, constant: 0)
        let buttonHeight = NSLayoutConstraint(item: solveButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 40)
        
        let clearWidth = NSLayoutConstraint(item: clearButton, attribute: .Width, relatedBy: .Equal, toItem: self.board, attribute: .Width, multiplier: 1/3, constant: 0)
        let clearHeight = NSLayoutConstraint(item: clearButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 40)
        let clearBottomPin = NSLayoutConstraint(item: clearButton, attribute: .Bottom, relatedBy: .Equal, toItem: self.bottomLayoutGuide, attribute: .Top, multiplier: 1, constant: -8)
        let clearLeftEdge = NSLayoutConstraint(item: clearButton, attribute: .Leading, relatedBy: .Equal, toItem: self.board, attribute: .Leading, multiplier: 1, constant: 0)
        
        
        let constraints = [solveRightEdge, solveBottomPin, buttonWidth, buttonHeight, clearWidth, clearHeight, clearBottomPin, clearLeftEdge]
        view.addConstraints(constraints)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if !shown {
            let instructionAlert = UIAlertController(title: "Welcome to the dark side.", message: "Enter any valid puzzle and your phone will magically solve it for you. With magic.", preferredStyle: .Alert)
            let dismiss = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            instructionAlert.addAction(dismiss)
            self.presentViewController(instructionAlert, animated:true, completion: nil)
            
            shown = true
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func clearAll() {
        // alert view?
        let tiles = self.tiles
        for tile in tiles {
            tile.value = .Nil
            tile.refreshLabel()
        }
        board.selectedTile = nilTiles[0]
    }
    
    func solvePuzzle() {
        
        for tile in nilTiles {
            tile.labelColor = UIColor.redColor()
        }

        let valuatedTiles = nonNilTiles
        let cells: [PuzzleCell] = cellsFromTiles(valuatedTiles)
        if let solution = Matrix.sharedInstance.solutionForValidPuzzle(cells) {
            for cell in solution {
                let tIndex = getTileIndexForRow(cell.row, andColumn: cell.column)
                board.tileAtIndex(tIndex).value = TileValue(rawValue: cell.value)!
            }
            board.selectedTile = nil
        } else {
            let alertController = UIAlertController(title: "Invalid Puzzle", message: "Your phone can't help you because the puzzle you've tried to solve has more or less than one solution. It's not THAT magical.", preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (_) in
                self.dismissViewControllerAnimated(true) {
                    ()->() in
                }
            }
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true) {
                
            }
        }

    }
    

}
