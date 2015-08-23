//
//  HonestViewController.swift
//  SudokuCheat
//
//  Created by Isaac Benham on 5/25/15.
//  Copyright (c) 2015 Isaac Benham. All rights reserved.
//

import Foundation

class HomeViewController: UIViewController {
   
    
    var justLaunched = true
    var table = UIView()
    let selectedColor = UIColor(red: 0.1, green: 0.1, blue: 0.9, alpha: 0.3).CGColor
    let defaultColor = UIColor.whiteColor().CGColor
    let tableBGColor = UIColor.blackColor().CGColor
    let mascotImage = UIImageView(image: (UIImage(named: "SudokuBot_RobotFace")))
    
    var selectedCell: TableCell? {
        willSet {
            var animationBloc: () -> ()
            if let new = newValue {
                animationBloc = {
                    self.table.layer.backgroundColor = UIColor.whiteColor().CGColor
                    self.selectedCell?.layer.backgroundColor = self.defaultColor
                    new.layer.backgroundColor = self.selectedColor
                }
            } else {
                animationBloc = {
                    self.selectedCell?.layer.backgroundColor = self.defaultColor
                    self.table.layer.backgroundColor = self.tableBGColor
                }
            }
                UIView.animateWithDuration(0.1, animations: animationBloc)
        }
    }
    
    var tableHeight: CGFloat = 0
    var tableWidth: CGFloat = 0
    var headerRatio: CGFloat = 1/2
    var rowHeight: CGFloat {
        get {
            let sects = sections()
            var totalRows = 0
            for section in 0...(sects-1) {
                let rows = rowsForSection(section)
                totalRows += rows
            }
            let numRows =  CGFloat(totalRows) + (headerRatio * CGFloat(sections()))
            return tableHeight/numRows

        }
    }
    
    var rowRatio: CGFloat {
        let sects = sections()
        var totalRows = 0
        for section in 0...(sects-1) {
            let rows = rowsForSection(section)
            totalRows += rows
        }
        let numRows =  CGFloat(totalRows) + (headerRatio * CGFloat(sections()))
        return 1/numRows
    }
    
    var allCells:[Int: [Int: TableCell]] = [:]
    var allHeaders: [Int: TableCell] = [:]
    
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.orangeColor()
        view.addSubview(table)
        view.addSubview(mascotImage)
        mascotImage.translatesAutoresizingMaskIntoConstraints = false
        table.userInteractionEnabled = true
        table.clipsToBounds = true
        table.layer.cornerRadius = 10.0
        table.layer.borderColor = UIColor.blackColor().CGColor
        table.layer.borderWidth = 5.0
        table.layer.backgroundColor = UIColor.blackColor().CGColor
        table.translatesAutoresizingMaskIntoConstraints = false
        for section in 0...sections()-1 {
            let header = headerForSection(section)
            table.addSubview(header)
            header.translatesAutoresizingMaskIntoConstraints = false
            for row in 0...rowsForSection(section)-1 {
                let cell = cellForRow(row, inSection: section)
                table.addSubview(cell)
                cell.translatesAutoresizingMaskIntoConstraints = false
            }
        }

        
        
        tableWidth = view.frame.size.width * (7/8)
        tableHeight = view.frame.size.height * (5/8)
        
        
        //let offset = navigationController != nil ? navigationController!.navigationBar.frame.size.height/2 : 0
        
        let tvCenterX = NSLayoutConstraint(item: table, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0)
        //let tvCenterY = NSLayoutConstraint(item: table, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: offset)
        let width = NSLayoutConstraint(item: table, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: tableWidth)
        let height = NSLayoutConstraint(item: table, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: tableHeight)
        height.priority = 999
        
        view.addConstraints([tvCenterX, width, height])
        
        let offset = navigationController != nil ? navigationController!.navigationBar.frame.size.height/4 : view.frame.size.height * 1/5
        
        let mascotCenterX = NSLayoutConstraint(item: mascotImage, attribute: .CenterX, relatedBy: .Equal, toItem: table, attribute: .CenterX, multiplier: 1, constant: 0)
        let mascotHeight = NSLayoutConstraint(item: mascotImage, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: offset*8)
        let mascotWidth = NSLayoutConstraint(item: mascotImage, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: offset*8)
        let mascotTop = NSLayoutConstraint(item: mascotImage, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom,
            multiplier: 1, constant: 10)
        let mascotBottom = NSLayoutConstraint(item: mascotImage, attribute: .Bottom, relatedBy: .Equal, toItem: table, attribute: .Top, multiplier: 1, constant: 0)
        
        view.addConstraints([mascotCenterX, mascotHeight, mascotWidth, mascotTop, mascotBottom])
        
        let sects = sections()
        
        for section in 0...(sects-1) {
            var constraints: [NSLayoutConstraint] = []
            let header = headerForSection(section)
            constraints.append(getBottomPinForHeaderInSection(section))
            constraints += getSidePinsForRowOrHeaderItem(header)
            
            if section == 0 {
                constraints.append(NSLayoutConstraint(item: header, attribute: .Top, relatedBy: .Equal, toItem: table, attribute: .Top, multiplier: 1, constant: 0))
            }
            
            constraints.append(NSLayoutConstraint(item: header, attribute: .Height, relatedBy: .Equal, toItem: cellForRow(0, inSection: 0), attribute: .Height, multiplier: headerRatio, constant: 0))
            
            let rows = rowsForSection(section)
            
            for row in 0...rows-1 {
                let cell = cellForRow(row, inSection: section)
                constraints += getSidePinsForRowOrHeaderItem(cell)
                constraints.append(getBottomPinForRow(row, inSection:section))
                let heightConstraint = NSLayoutConstraint(item: cell, attribute: .Height, relatedBy: .Equal, toItem: table, attribute: .Height, multiplier: rowRatio, constant: 0)
                constraints.append(heightConstraint)
            }
            view.addConstraints(constraints)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        selectedCell = nil
        if justLaunched {
            justLaunched = false
            
            navigationController?.navigationBarHidden = true
            
            let subBG = UIView(frame: view.bounds)
            subBG.backgroundColor = UIColor.blackColor()
            let grid = UIImageView(image: UIImage(named: "SudokuBot_Grid_VowelsOmitted"))
            view.addSubview(subBG)
            subBG.addSubview(grid)
            
            grid.translatesAutoresizingMaskIntoConstraints = false
            let gridX = NSLayoutConstraint(item: grid, attribute: .CenterX, relatedBy: .Equal, toItem: subBG, attribute: .CenterX, multiplier: 1, constant: 0)
            let gridY = NSLayoutConstraint(item: grid, attribute: .CenterY, relatedBy: .Equal, toItem: subBG, attribute: .CenterY, multiplier: 1, constant: 0)
            let height = NSLayoutConstraint(item: grid, attribute: .Height, relatedBy: .Equal, toItem: subBG, attribute: .Width, multiplier: 1, constant: 0)
            let width = NSLayoutConstraint(item: grid, attribute: .Width, relatedBy: .Equal, toItem: subBG, attribute: .Width, multiplier: 1, constant: 0)
            
            subBG.addConstraints([gridX, gridY, height, width])
            
            let fullGrid = UIImageView(image: UIImage(named: "SudokuBot_Grid_Letters"))
            fullGrid.alpha = 0.0
            fullGrid.translatesAutoresizingMaskIntoConstraints = false
            subBG.addSubview(fullGrid)
        
            let fullX = NSLayoutConstraint(item: fullGrid, attribute: .CenterX, relatedBy: .Equal, toItem: subBG, attribute: .CenterX, multiplier: 1, constant: 0)
            let fullY = NSLayoutConstraint(item: fullGrid, attribute: .CenterY, relatedBy: .Equal, toItem: subBG, attribute: .CenterY, multiplier: 1, constant: 0)
            let fullHeight = NSLayoutConstraint(item: fullGrid, attribute: .Height, relatedBy: .Equal, toItem: subBG, attribute: .Width, multiplier: 1, constant: 0)
            let fullWidth = NSLayoutConstraint(item: fullGrid, attribute: .Width, relatedBy: .Equal, toItem: subBG, attribute: .Width, multiplier: 1, constant: 0)
            subBG.addConstraints([fullX, fullY, fullHeight, fullWidth])
            view.layoutIfNeeded()
            
            UIView.animateWithDuration(1.0, animations: {
                fullGrid.alpha = 1.0}){ (finished) in
                    if finished {
                        UIView.transitionWithView(self.view, duration: 1.0, options: [UIViewAnimationOptions.TransitionCrossDissolve, UIViewAnimationOptions.CurveEaseIn], animations: {
                            grid.alpha = 0.0
                            fullGrid.alpha = 0.0
                            subBG.alpha = 0.0
                            subBG.removeFromSuperview()
                            }) {(_) in
                                UIView.animateWithDuration(0.25) {
                                    self.navigationController?.navigationBarHidden = false
                                    self.navigationItem.title = "SudokuBot bids you welcome!"
                                }
                        }
                    }
            }
        } else {
            UIView.animateWithDuration(0.25) {
                self.navigationItem.title = "Select a puzzle"
            }

        }
    }
    
    override func viewDidAppear(animated: Bool) {
        for section in 0...sections()-1 {
            let header = headerForSection(section)
            
            header.label?.textColor = UIColor.whiteColor()
            
            
            for row in 0...rowsForSection(section)-1 {
                let cell = cellForRow(row, inSection: section)
                print(cell.bounds.size.height)
            }
        }
    }
    
    func getSidePinsForRowOrHeaderItem(item: UIView) -> [NSLayoutConstraint] {
        let leftPin = NSLayoutConstraint(item: item, attribute: .Leading, relatedBy: .Equal, toItem: table, attribute: .Leading, multiplier: 1, constant: 0)
        let rightPin = NSLayoutConstraint(item: item, attribute: .Trailing, relatedBy: .Equal, toItem: table, attribute: .Trailing, multiplier: 1, constant: 0)
        
        return [leftPin, rightPin]
    }
    
    func getBottomPinForHeaderInSection(section: Int) -> NSLayoutConstraint {
        let header = headerForSection(section)
        
        let bottomNeighbor = cellForRow(0, inSection: section)
            
        return NSLayoutConstraint(item: header, attribute: .Bottom, relatedBy: .Equal, toItem: bottomNeighbor, attribute: .Top, multiplier: 1, constant: 0)

    }
    
    func getBottomPinForRow(row: Int, inSection section: Int) -> NSLayoutConstraint {
        let cell = cellForRow(row, inSection: section)
        let numRows = rowsForSection(section)
        if section == sections()-1 && row == numRows - 1 {
            return NSLayoutConstraint(item: cell, attribute: .Bottom, relatedBy: .Equal, toItem: table, attribute: .Bottom, multiplier: 1, constant: 0)
        }
        
        let bottomNeighbor = row == numRows - 1 ? headerForSection(section+1) : cellForRow(row+1, inSection: section)
        return NSLayoutConstraint(item: cell, attribute: .Bottom, relatedBy: .Equal, toItem: bottomNeighbor, attribute: .Top, multiplier: 1, constant: 0)
    }
   
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    override func sections() -> Int {
        return 3
    }
    
    override func rowsForSection(section: Int) -> Int {
        switch section {
        case 0:
            return 4
        default:
            return 1
        }

    }
    
    func headerForSection(section: Int) -> TableCell {
        if let headerView = allHeaders[section] {
            return headerView
        }
        
        let headerView = TableCell()
        headerView.layer.backgroundColor = UIColor.blackColor().CGColor
        headerView.label = UILabel()
        headerView.label?.text = titleForHeaderInSection(section)
        headerView.label?.textAlignment = .Center
        headerView.label?.textColor = UIColor.whiteColor()
        allHeaders[section] = headerView
        
        return headerView
    }
    
    func titleForHeaderInSection(section: Int) -> String {
        switch section {
        case 0:
            return "Play"
        case 1:
            return "Cheat"
        default:
            return "Options"
        }
    }

    func cellForRow(row: Int, inSection section: Int) -> TableCell {
        if let cell = allCells[section]?[row] {
            return cell
        }
        
        let cell = TableCell()
        cell.userInteractionEnabled = true
        cell.tag = row
        cell.section = section
        cell.backgroundColor = UIColor.whiteColor()
        cell.layer.borderColor = UIColor.blackColor().CGColor
        cell.layer.borderWidth = 1.0
        cell.layer.cornerRadius = 10.0
        cell.labelHorizontalInset = 10
        cell.labelVertInset = 2.5
        cell.label = UILabel()
        cell.label?.text = labelTextForRow(row, inSection: section)
        cell.label?.textColor = UIColor.blackColor()
        
        if allCells[section] != nil {
            allCells[section]![row] = cell
        } else {
            allCells[section] = [row:cell]
        }

        let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("rowTapped:"))
        cell.addGestureRecognizer(tapRecognizer)
        
        return cell
    }
    
    func labelTextForRow(row: Int, inSection section: Int) -> String {
        switch section {
        case 0:
            switch row {
            case 0:
                return "Easy puzzle"
            case 1:
                return "Medium puzzle"
            case 2:
                return "Hard puzzle"
                
            default:
                return "Insane puzzle"
            }
        case 1:
            return "Solve a valid puzzle"
        default:
            return "Change settings"
            
        }

    }
    
    func rowTapped(sender: AnyObject?) {
        let tapper = sender as! UITapGestureRecognizer
        let cell = tapper.view as! TableCell
        selectedCell = cell
        
        switch cell.section! {
        case 0:
            performSegueWithIdentifier("playSegue", sender: cell)
        case 1:
            performSegueWithIdentifier("cheatSegue", sender: nil)
        default:
            showOptions(nil)
        }
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

    
    func showOptions(sender: AnyObject?) {
        let defaults = NSUserDefaults.standardUserDefaults()
        let timed = defaults.boolForKey("timed")

        let optionSheet = self.storyboard!.instantiateViewControllerWithIdentifier("options") as! PuzzleOptionsViewController
        optionSheet.modalTransitionStyle = .FlipHorizontal
        optionSheet.timedStatus = timed
        self.presentViewController(optionSheet, animated: true, completion: nil)
    }
}