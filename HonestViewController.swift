//
//  HonestViewController.swift
//  SudokuCheat
//
//  Created by Isaac Benham on 5/25/15.
//  Copyright (c) 2015 Isaac Benham. All rights reserved.
//

import Foundation

class HonestViewController: UIViewController {
    @IBOutlet weak var playButton:UIButton!
    @IBOutlet weak var createButton:UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.orangeColor()
        playButton.layer.cornerRadius = playButton.frame.width/2
        createButton.layer.cornerRadius = createButton.frame.width/2
        playButton.layer.borderColor = UIColor.blackColor().CGColor
        createButton.layer.borderColor = UIColor.blackColor().CGColor
        playButton.layer.borderWidth = 3.0
        createButton.layer.borderWidth = 3.0
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
}