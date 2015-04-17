//
//  ViewController.swift
//  SudokuCheat
//
//  Created by Isaac Benham on 4/14/15.
//  Copyright (c) 2015 Isaac Benham. All rights reserved.
//

import UIKit

import UIKit

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
    }
    
    
}

