//
//  KeyboardViews.swift
//  SudokuCheat
//
//  Created by Isaac Benham on 5/25/15.
//  Copyright (c) 2015 Isaac Benham. All rights reserved.
//

import Foundation

class SudokuNumberPad: UIView {
    let one = UIButton()
    let two = UIButton()
    let three = UIButton()
    let four = UIButton()
    let five = UIButton()
    let six = UIButton()
    let seven = UIButton()
    let eight = UIButton()
    let nine = UIButton()
    let buttons: [UIButton]
    var current: UIButton? = nil {
        didSet {
            if let oldCurrent = oldValue {
                if oldCurrent == current {
                    return
                }
                oldCurrent.backgroundColor = defaultColor
                oldCurrent.setTitleColor(defaultTitleColor, forState: .Normal)
            }
            if let someVal = current {
                someVal.backgroundColor = currentColor
                someVal.setTitleColor(currentTitleColor, forState: .Normal)
            }
        }
    }
    var symbolSet: SymbolSet {
        get {
            let defaults = NSUserDefaults.standardUserDefaults()
            let symType = defaults.integerForKey("symbolSet")
            switch symType {
            case 0:
                return .Standard
            case 1:
                return .Critters
            default:
                return .Flags
            }
        }
    }
    var currentColor = UIColor.blackColor()
    var defaultColor = UIColor.whiteColor()
    var defaultTitleColor = UIColor.blackColor()
    var currentTitleColor = UIColor.whiteColor()
    var delegate: NumPadDelegate?
    var buttonHeight:CGFloat = 0.0
    
    override init(frame: CGRect) {
        buttons = [one, two, three, four, five, six, seven, eight, nine]
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        buttons = [one, two, three, four, five, six, seven, eight, nine]
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        self.userInteractionEnabled = true
        for index in 0...buttons.count-1 {
            setTextTitleForValue(index+1)
            let button = buttons[index]
            button.setTitleColor(defaultTitleColor, forState: .Normal)
            button.backgroundColor = defaultColor
            self.addSubview(button)
            constrainButton(button, atIndex: index)
            let radius = self.frame.height/2
            buttonHeight = radius
            button.layer.cornerRadius = radius
            button.layer.borderColor = UIColor.blackColor().CGColor
            button.layer.borderWidth = 2.0
            button.tag = index+1
           button.addTarget(self, action: "buttonTapped:", forControlEvents: .TouchUpInside)
        
        }
    }
    
    func refreshButtonText() {
        for val in 1...9 {
            setTextTitleForValue(val)
        }
    }
    
    private func setTextTitleForValue(value:Int) {
        let button = buttons[value-1]
        let title = symbolSet.getSymbolForValue(value)
        
        button.setTitle(title, forState: .Normal)
        button.setTitle(title, forState: .Selected)
    }
    
    func constrainButton(button: UIButton, atIndex index: Int) {
        button.translatesAutoresizingMaskIntoConstraints = false
        let buttonY = NSLayoutConstraint(item: button, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        let buttonHeight = NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant: 0)
        let buttonWidth = NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant: 0)
        
        var leftPin:NSLayoutConstraint
        
        let leftNeighbor = index == 0 ? self : buttons[index-1]
        if index == 0 {
            leftPin = NSLayoutConstraint(item: button, attribute: .Leading, relatedBy: .Equal, toItem: leftNeighbor, attribute: .Leading, multiplier: 1, constant: 0)
        } else {
            leftPin = NSLayoutConstraint(item: button, attribute: .Leading, relatedBy: .Equal, toItem: leftNeighbor, attribute: .Trailing, multiplier: 1, constant: 0)
        }
        
       
        let constraints = index == 8 ? [buttonY, buttonHeight, buttonWidth, leftPin, NSLayoutConstraint(item: button, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0)] : [buttonY, buttonHeight, buttonWidth, leftPin]
        
        self.addConstraints(constraints)
    }
    
    func buttonTapped(sender: UIButton) {
        let val = sender.tag
        if let del = self.delegate {
            del.valueSelected(val)
        }
    }
    
    func refresh() {
        if self.delegate == nil {
            return
        }
        if let existingValue = self.delegate!.currentValue() {
            if let nowCurrent = current {
                if nowCurrent == existingValue {
                    return
                }
            }
            current = buttons[existingValue-1]
        } else {
            if current != nil {
                current = nil
            }
        }
    }
}

protocol NumPadDelegate {
    func valueSelected(value: Int)
    func currentValue() -> Int? 
}