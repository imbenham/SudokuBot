//
//  HonestViewController.swift
//  SudokuCheat
//
//  Created by Isaac Benham on 5/25/15.
//  Copyright (c) 2015 Isaac Benham. All rights reserved.
//

import Foundation

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    
   let tableView = UITableView(frame: CGRect.zeroRect, style: .Grouped)
    
    var tvHeight:CGFloat {
        get {
            return view.frame.size.height * 5/8
        }
    }
    
    var tvWidth:CGFloat {
        get {
            return view.frame.size.width * 7/8
        }
    }
    
    var rowHeight:CGFloat {
        get {
            let sections = self.numberOfSectionsInTableView(tableView)
            let totalHeight = tvHeight
            var totalRows = 0
            for section in 0...(sections-1) {
                totalRows += self.tableView.numberOfRowsInSection(section)
            }
            
            return totalHeight / (CGFloat(totalRows) * 1.5)
        }
    }
    
    var headerHeight:CGFloat {
        return 0.5 * rowHeight
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.orangeColor()
       
        view.addSubview(tableView)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let offset = navigationController != nil ? navigationController!.navigationBar.frame.size.height/2 : 0
        
        let tvCenterX = NSLayoutConstraint(item: tableView, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0)
        let tvCenterY = NSLayoutConstraint(item: tableView, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: offset)
        let width = NSLayoutConstraint(item: tableView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: tvWidth)
        let height = NSLayoutConstraint(item: tableView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 0)
        
        view.addConstraints([tvCenterX, tvCenterY, width, height])
        
    }
    
    override func viewDidLayoutSubviews() {
        tableView.layer.cornerRadius = 5.0
        tableView.layer.borderColor = UIColor.blackColor().CGColor
        tableView.layer.borderWidth = 3.0
        tableView.contentSize = tableView.bounds.size
        tableView.setContentOffset(CGPoint(x: 0, y: -20), animated: false)
        tableView.scrollEnabled = false
        
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "playSegue" {
            let difficulty = (sender as! UIView).tag
            let vc = segue.destinationViewController as! SudokuController
            
            switch difficulty{
            case 0:
                vc.difficulty = .Easy
            case 1:
                vc.difficulty = .Medium
            case 2:
                vc.difficulty = .Hard
            default:
                vc.difficulty = .Insane
            }
        }
        
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        default:
            return 1
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return rowHeight
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Play"
        case 1:
            return "Cheat"
        default:
            return "Options"
        }
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Easy puzzle"
                cell.tag = 0
            case 1:
                cell.textLabel?.text = "Medium puzzle"
                cell.tag = 1
            case 2:
                cell.textLabel?.text = "Hard puzzle"
                cell.tag = 2
            default:
                cell.textLabel?.text = "Insane puzzle"
                cell.tag = 3
            }
        case 1:
            cell.textLabel?.text = "Solve a valid puzzle"
        default:
            cell.textLabel?.text = "Change settings"
            
        }
        
        return cell

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.section {
        case 0:
            performSegueWithIdentifier("playSegue", sender: tableView.cellForRowAtIndexPath(indexPath))
        case 1:
            performSegueWithIdentifier("cheatSegue", sender: nil)
        default:
            showOptions(nil)
        }
        
        tableView.cellForRowAtIndexPath(indexPath)?.selected = false
        
    }
    
    func showOptions(sender: AnyObject?) {
        let defaults = NSUserDefaults.standardUserDefaults()
        let timed = defaults.boolForKey("timed")

        let optionSheet = self.storyboard!.instantiateViewControllerWithIdentifier("options") as! PuzzleOptionsViewController
        optionSheet.modalTransitionStyle = .FlipHorizontal
        optionSheet.timedStatus = timed
        self.presentViewController(optionSheet, animated: true, completion: nil)
    }
}