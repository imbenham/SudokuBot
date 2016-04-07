//
//  PuzzleOptionsViewController.swift
//  SudokuBot
//
//  Created by Isaac Benham on 4/7/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import Foundation

class PuzzleOptionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let tableView = UITableView(frame: CGRectZero, style: .Grouped)
    let baseView = UIView(frame: CGRectZero)
    let saveButton = UIButton()
    var selectedIndex:NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)  {
        willSet {
            if selectedIndex != newValue {
                let cell = tableView.cellForRowAtIndexPath(selectedIndex)
                cell?.accessoryType = .None
            }
        }
        didSet {
            if selectedIndex != oldValue {
                let cell = tableView.cellForRowAtIndexPath(selectedIndex)
                cell?.accessoryType = .Checkmark
            }
        }
    }
    
    var timedStatus = true {
        didSet {
            let indexPath = NSIndexPath(forRow: 0, inSection: 1)
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.textLabel!.text = timedStatusString
        }
    }
    var timedStatusString: String {
        get {
            return timedStatus ? "On" : "Off"
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        view.addSubview(baseView)
        baseView.addSubview(saveButton)
        saveButton.addTarget(self, action: #selector(PuzzleOptionsViewController.saveAndDismiss), forControlEvents: .TouchUpInside)
        saveButton.setTitle("Save", forState: .Normal)
        saveButton.layer.borderColor = UIColor.darkGrayColor().CGColor
        saveButton.layer.borderWidth = 2.0
        saveButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        saveButton.layer.cornerRadius = 5.0
        saveButton.backgroundColor = UIColor.whiteColor()
        saveButton.showsTouchWhenHighlighted = true
        baseView.backgroundColor = UIColor.lightGrayColor()
        
        
        self.layoutTableView()
        tableView.delegate = self
        tableView.dataSource = self
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let selected = defaults.integerForKey(symbolSetKey)
        
        let index = NSIndexPath(forRow: selected, inSection: 0)
        selectedIndex = index
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func layoutTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        baseView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        let basePin = NSLayoutConstraint(item: baseView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0)
        let baseWidth = NSLayoutConstraint(item: baseView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0)
        let baseHeight = NSLayoutConstraint(item: baseView, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 1/12, constant: 0)
        
        let tvWidth = NSLayoutConstraint(item: tableView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0)
        let topPin = NSLayoutConstraint(item: tableView, attribute: .Top, relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0)
        let bottomPin = NSLayoutConstraint(item: tableView, attribute: .Bottom, relatedBy: .Equal, toItem: baseView, attribute: .Top, multiplier: 1, constant: 0)
        
        let buttonHeight = NSLayoutConstraint(item: saveButton, attribute: .Height, relatedBy: .Equal, toItem: baseView, attribute: .Height, multiplier: 4/5, constant: 0)
        let buttonWidth = NSLayoutConstraint(item: saveButton, attribute: .Width, relatedBy: .Equal, toItem: baseView, attribute: .Width, multiplier: 1/6, constant: 0)
        let buttonVertCenter = NSLayoutConstraint(item: saveButton, attribute: .CenterY, relatedBy: .Equal, toItem: baseView, attribute: .CenterY, multiplier: 1, constant: 0)
        let buttonPin = NSLayoutConstraint(item: saveButton, attribute: .Trailing, relatedBy: .Equal, toItem: baseView, attribute: .Trailing, multiplier: 1, constant: -8)
        
        let constraints = [basePin, baseWidth, baseHeight, tvWidth, topPin, bottomPin, buttonHeight, buttonWidth, buttonVertCenter, buttonPin]
        
        self.view.addConstraints(constraints)
        
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case 0:
            return "Change Symbol Set"
        default:
            return "Timer"
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 3
        default:
            return 1
            
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.font = UIFont(name: "futura", size: UIFont.labelFontSize())
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Standard: 1-9"
            case 1:
                cell.textLabel?.text = "Critters:🐥-🐌"
            default:
                cell.textLabel?.text = "Flags:🇨🇭-🇲🇽"
            }
        default:
            cell.textLabel?.text = timedStatusString
        }
        
        if indexPath == selectedIndex {
            cell.accessoryType = .Checkmark
        }
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            selectedIndex = indexPath
        } else {
            timedStatus = !timedStatus
        }
        
    }
    
    // saving changes
    
    func saveAndDismiss() {
        
        let selected = selectedIndex.row
        let defaults = NSUserDefaults.standardUserDefaults()
        
        defaults.setInteger(selected, forKey: "symbolSet")
        defaults.setBool(timedStatus, forKey: "timed")
        
        defaults.synchronize()
        
        presentingViewController!.dismissViewControllerAnimated(true) {
            
        }
        
    }
    
}
