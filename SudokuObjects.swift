//
//  SudokuObjects.swift
//  SudokuCheat
//
//  Created by Isaac Benham on 4/14/15.
//  Copyright (c) 2015 Isaac Benham. All rights reserved.
//

import UIKit

class SudokuItem:UIView {
    var parentSquare: SudokuItem?
    var defaultIndex = 0
    
    required init(index: Int, withParent: SudokuItem?) {
        super.init(frame: CGRectZero)
        self.defaultIndex = index
        parentSquare = withParent
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

protocol Nestable {
    var index:Int {get}
    
}

enum Row: Int {
    case One = 1
    case Two = 2
    case Three = 3
}

enum Column: Int {
    case One = 1
    case Two = 2
    case Three = 3
}

protocol Nester {
    var boxes: [SudokuItem] {get set}
    func makeRow(row: Row) -> [SudokuItem]
    func makeColumn(column: Column) -> [SudokuItem]
    func view() -> UIView
}

extension SudokuItem: Nestable {
    // MARK: Nester confromance
    var index: Int {
        get {
            return self.defaultIndex
        }
    }
}

class SudokuBoard: SudokuItem, Nester {
   
    var boxes: [SudokuItem]


    required init(index: Int, withParent: SudokuItem?) {
        boxes = [Box]()
        super.init(index: index, withParent: withParent)
        
        for index in 0...8 {
            let aBox = Box(index: index, withParent:self)
            boxes.append(aBox)
            self.addSubview(aBox.view())
    
        }
        self.prepareBoxes()
    }
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeRow(row: Row)-> [SudokuItem] {
        switch row {
        case .One:
            return [boxes[0], boxes[1], boxes[2]]
        case .Two:
            return [boxes[3], boxes[4], boxes[5]]
        case .Three:
            return [boxes[6], boxes[7], boxes[8]]
        }
    }
    
    func makeColumn(column: Column) -> [SudokuItem]{
        switch column {
        case .One:
            return [boxes[0], boxes[3], boxes[6]]
        case .Two:
            return [boxes[1], boxes[4], boxes[7]]
        case .Three:
            return [boxes[2], boxes[5], boxes[8]]
        }
    }
    
    
    func prepareBoxes() {
        for nested in boxes {
            let box = nested as SudokuItem
            box.parentSquare = self
            box.backgroundColor = UIColor.lightGrayColor()
            box.layer.borderColor = UIColor.blackColor().CGColor
            box.layer.borderWidth = 1.0
            box.userInteractionEnabled = true
            box.setTranslatesAutoresizingMaskIntoConstraints(false)
        }
        
        let constraints = BoxSetter().configureConstraintsForParentSquare(self)
        self.addConstraints(constraints)
    }
    
    
    func view() -> UIView {
        return self
    }
    
}


class Box: SudokuItem, Nester{
    
    var boxes: [SudokuItem]
    
    required init (index withIndex: Int, withParent: SudokuItem?){
        boxes = [Tile]()
        super.init(index: withIndex, withParent: withParent)
        for index in 0...8 {
            let aBox = Tile(index: index, withParent: self)
            boxes.append(aBox)
            self.addSubview(aBox)
        }
        
        self.prepareBoxes()
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeRow(row: Row)-> [SudokuItem] {
        switch row {
        case .One:
            return [boxes[0], boxes[1], boxes[2]]
        case .Two:
            return [boxes[3], boxes[4], boxes[5]]
        case .Three:
            return [boxes[6], boxes[7], boxes[8]]
        }
    }
    

    func makeColumn(column: Column) -> [SudokuItem]{
        switch column {
        case .One:
            return [boxes[0], boxes[3], boxes[6]]
        case .Two:
            return [boxes[1], boxes[4], boxes[7]]
        case .Three:
            return [boxes[2], boxes[5], boxes[8]]
        }
    }

    
    func prepareBoxes() {
        for nested in boxes {
            let box = nested as SudokuItem
            box.backgroundColor = UIColor.whiteColor()
            box.layer.borderColor = UIColor.lightGrayColor().CGColor
            box.layer.borderWidth = 1.0
            box.userInteractionEnabled = true
            box.setTranslatesAutoresizingMaskIntoConstraints(false)
        }
        
        let constraints:[NSLayoutConstraint] = BoxSetter().configureConstraintsForParentSquare(self)
        self.addConstraints(constraints)
    }
    
    func view() -> UIView {
        return self
    }
}

class Tile: SudokuItem, Nestable {
    
    
    
    required init (index: Int, withParent: SudokuItem?) {
        super.init(index: index, withParent: withParent)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func view() -> UIView {
        return self
    }
}


    class BoxSetter {
    
    func configureConstraintsForParentSquare<U:UIView where U:Nester>(square: U) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        
        for box in square.makeRow(.One) {
            constraints.extend(self.makeLayoutConstraintsForBox(box, inBox: square, forAttributes: [NSLayoutAttribute.Top, .Width, .Height]))
        }
        
        for box in square.makeRow(.Three) {
            constraints.extend(self.makeLayoutConstraintsForBox(box, inBox: square, forAttributes: [.Bottom, .Width, .Height]))
        }
        
        for box in square.makeColumn(.One) {
            constraints.extend(self.makeLayoutConstraintsForBox(box, inBox: square, forAttributes: [.Leading, .Width, .Height]))
        }
        
        for box in square.makeColumn(.Three) {
            constraints.extend(self.makeLayoutConstraintsForBox(box, inBox: square, forAttributes: [.Trailing, .Width, .Height]))
        }
        
        for box in square.makeRow(.Two) {
            constraints.extend(self.makeLayoutConstraintsForBox(box, inBox: square, forAttributes: [.Top, .Bottom, .Width, .Height]))
        }
        
        for box in square.makeColumn(.One) {
            constraints.extend(self.makeLayoutConstraintsForBox(box, inBox: square, forAttributes: [.Leading, .Trailing]))
            
        }
        
        return constraints
    }

    
    
    func makeLayoutConstraintsForBox<T:UIView, U:UIView where T: Nestable, U:Nester>(box: T, inBox parentBox: U, forAttributes attributes:[NSLayoutAttribute]) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        
        for attribute in attributes {
            constraints.append(self.makeLayoutConstraintForBox(box, inBox: parentBox, forAttribute: attribute))
        }
        
        return constraints
    }
    
    func makeLayoutConstraintForBox<T:UIView, U:UIView where T:Nestable, U:Nester>(box: T, inBox parentBox: U, forAttribute anAttribute: NSLayoutAttribute) -> NSLayoutConstraint {
        switch anAttribute{
        case .Width, .Height:
            return NSLayoutConstraint(item: box, attribute: anAttribute, relatedBy: NSLayoutRelation.Equal, toItem: parentBox.view(), attribute: anAttribute, multiplier: 1/3, constant: 0)
        default:
            let neighborItem = self.getNeighborForBoxIndex(box.index, inParent: parentBox, forAttribute: anAttribute)!
            let neighborAttribute = neighborItem.attribute
            let neighborView = neighborItem.neighbor
            return NSLayoutConstraint(item: box, attribute: anAttribute, relatedBy: NSLayoutRelation.Equal, toItem: neighborView, attribute: neighborAttribute, multiplier: 1, constant: 0)
            
        }
        
    }
    
    // MARK: Constraint maker helpers
    typealias ToItem = (neighbor:UIView, attribute:NSLayoutAttribute)?
    
    func getNeighborForBoxIndex<U:UIView where U:Nester>(index: Int, inParent parent: U, forAttribute anAttribute:NSLayoutAttribute) -> ToItem {
        switch anAttribute {
        case .Bottom:
            return self.getBottomNeighborForBoxIndex(index, inParent: parent)
        case .Top:
            return self.getTopNeighborForBoxIndex(index, inParent: parent)
        case .Left,.Leading:
            return self.getLeftNeighborForBoxIndex(index, inParent: parent)
        case .Right,.Trailing:
            return self.getRightNeighborForBoxIndex(index, inParent: parent)
        default:
            return nil
        }
    }
    
    func getTopNeighborForBoxIndex<U:UIView where U:Nester>(index: Int, inParent parent: U) -> ToItem {
        switch index {
        case 3...8:
            return (parent.boxes[index-3], .Bottom)
        case 0...2:
            return (parent.view(), .Top)
        default:
            return nil
        }
    }
    
    func getBottomNeighborForBoxIndex<U:UIView where U:Nester>(index: Int, inParent parent: U) -> ToItem {
        switch index {
        case 0...5:
            return (parent.boxes[index+3], .Top)
        case 5...8:
            return (parent.view(), .Bottom)
        default:
            return nil
        }
    }
    
    func getLeftNeighborForBoxIndex<U:UIView where U:Nester>(index: Int, inParent parent: U) -> ToItem {
        switch index {
        case 0,3,6:
            return (parent.view(), .Leading)
        case 1,2,4,5,7,8:
            return (parent.boxes[index-1], .Trailing)
        default:
            return nil
        }
    }
    
    func getRightNeighborForBoxIndex<U:UIView where U:Nester>(index: Int, inParent parent: U) -> ToItem {
        switch index {
        case 2,5,8:
            return (parent.view(), .Trailing)
        case 0,1,3,4,6,7:
            return (parent.boxes[index+1], .Leading)
        default:
            return nil
        }
    }
}