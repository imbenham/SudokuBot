//
//  HonestViewController.swift
//  SudokuCheat
//
//  Created by Isaac Benham on 5/25/15.
//  Copyright (c) 2015 Isaac Benham. All rights reserved.
//

import Foundation

class HomeViewController: UIViewController {
    @IBOutlet weak var easyButton:UIButton!
    @IBOutlet weak var mediumButton:UIButton!
    @IBOutlet weak var hardButton:UIButton!
    @IBOutlet weak var insaneButton:UIButton!
    @IBOutlet weak var cheatButton:UIButton!
    
    @IBOutlet weak var middleButtonY: NSLayoutConstraint!
    
    override func viewDidLoad() {
        middleButtonY.constant = self.navigationController!.toolbar.frame.size.height-10
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.orangeColor()
         let buttons = [easyButton, mediumButton, hardButton, insaneButton, cheatButton]
        for button in buttons{
             button.layer.cornerRadius = button.frame.width/2
            button.layer.borderColor = UIColor.blackColor().CGColor
            button.layer.borderWidth = 3.0
        }
        
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let button = sender as? UIButton {
            let difficulty = button.tag
            let vc = segue.destinationViewController as! SudokuController
            
            switch difficulty{
            case 0:
                vc.difficulty = .Easy
            case 1:
                vc.difficulty = .Medium
            case 2:
                vc.difficulty = .Hard
            case 3:
                vc.difficulty = .Insane
            default:
                break
            }
            
        }
        
    }

}