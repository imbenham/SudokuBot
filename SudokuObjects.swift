//
//  SudokuObjects.swift
//  SudokuCheat
//
//  Created by Isaac Benham on 4/14/15.
//  Copyright (c) 2015 Isaac Benham. All rights reserved.
//

import UIKit

class SudokuItem: UIView {
    
    
    
    weak var controller: SudokuController? {
        didSet {
        didSetController()
        }
    }
    var parentSquare:SudokuItem?
    var defaultIndex = 0
    
    init(index: Int) {
        super.init(frame: CGRectZero)
        self.defaultIndex = index
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func didSetController() {
        
    }
}

protocol Nestable {
    var index:Int {get}
    
}



protocol Nester: class {
    associatedtype T: SudokuItem
    var boxes: [T] {get set}
    func makeRow(row: Int) -> [T]
    func makeColumn(column: Int) -> [T]
}

extension Nester where Self:UIView {
    
}

extension SudokuItem: Nestable {
    var index: Int {
        get {
            return self.defaultIndex
        }
    }
}



class BoxSetter {
    
    typealias T = SudokuItem
    
    func configureConstraintsForParentSquare<U:SudokuItem where U:Nester>(square: U) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        
        for box in square.makeRow(1) {
            constraints.appendContentsOf(self.makeLayoutConstraintsForBox(box, inBox: square, forAttributes: [.Top, .Height]))
        }
        
        for box in square.makeRow(3) {
            constraints.appendContentsOf(self.makeLayoutConstraintsForBox(box, inBox: square, forAttributes: [.Bottom, .Height]))
        }
        
        for box in square.makeColumn(1) {
            constraints.appendContentsOf(self.makeLayoutConstraintsForBox(box, inBox: square, forAttributes: [.Leading, .Width]))
        }
        
        for box in square.makeColumn(3) {
            constraints.appendContentsOf(self.makeLayoutConstraintsForBox(box, inBox: square, forAttributes: [.Trailing, .Width]))
        }
        
        for box in square.makeRow(2) {
            constraints.appendContentsOf(self.makeLayoutConstraintsForBox(box, inBox: square, forAttributes: [.Top, .Bottom]))
        }
        
        for box in square.makeColumn(2) {
            constraints.appendContentsOf(self.makeLayoutConstraintsForBox(box, inBox: square, forAttributes: [.Leading, .Trailing]))
            
        }
        
        return constraints
    }
    
    
    
    func makeLayoutConstraintsForBox<T:SudokuItem, U:SudokuItem where T: Nestable, U:Nester>(box: T, inBox parentBox: U, forAttributes attributes:[NSLayoutAttribute]) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        
        for attribute in attributes {
            constraints.append(self.makeLayoutConstraintForBox(box, inBox: parentBox, forAttribute: attribute))
        }
        
        return constraints
    }
    
    func makeLayoutConstraintForBox<T:SudokuItem, U:SudokuItem where T:Nestable, U:Nester>(box: T, inBox parentBox: U, forAttribute anAttribute: NSLayoutAttribute) -> NSLayoutConstraint {
        switch anAttribute{
        case .Width, .Height:
            return NSLayoutConstraint(item: box, attribute: anAttribute, relatedBy: NSLayoutRelation.Equal, toItem: parentBox, attribute: anAttribute, multiplier: 1/3, constant: 0)
        default:
            let neighborItem = self.getNeighborForBoxIndex(box.index, inParent: parentBox, forAttribute: anAttribute)!
            let neighborAttribute = neighborItem.attribute
            let neighborView = neighborItem.neighbor
            return NSLayoutConstraint(item: box, attribute: anAttribute, relatedBy: NSLayoutRelation.Equal, toItem: neighborView, attribute: neighborAttribute, multiplier: 1, constant: 0)
            
        }
        
    }
    
    // MARK: Constraint maker helpers
    typealias ToItem = (neighbor:SudokuItem, attribute:NSLayoutAttribute)?
    
    func getNeighborForBoxIndex<U: SudokuItem where U:Nester>(index: Int, inParent parent: U, forAttribute anAttribute:NSLayoutAttribute) -> ToItem {
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
    
    func getTopNeighborForBoxIndex<U: SudokuItem where U: Nester >(index: Int, inParent parent: U) -> ToItem {
        switch index {
        case 3...8:
            return (parent.boxes[index-3], .Bottom)
        case 0...2:
            return (parent, .Top)
        default:
            return nil
        }
    }
    
    func getBottomNeighborForBoxIndex<U: SudokuItem where U: Nester >(index: Int, inParent parent: U) -> ToItem {
        switch index {
        case 0...5:
            return (parent.boxes[index+3], .Top)
        case 5...8:
            return (parent, .Bottom)
        default:
            return nil
        }
    }
    
    func getLeftNeighborForBoxIndex<U:SudokuItem where U:Nester>(index: Int, inParent parent: U) -> ToItem {
        switch index {
        case 0,3,6:
            return (parent, .Leading)
        case 1,2,4,5,7,8:
            return (parent.boxes[index-1], .Trailing)
        default:
            return nil
        }
    }
    
    func getRightNeighborForBoxIndex<U:SudokuItem where U:Nester>(index: Int, inParent parent: U) -> ToItem {
        switch index {
        case 2,5,8:
            return (parent, .Trailing)
        case 0,1,3,4,6,7:
            return (parent.boxes[index+1], .Leading)
        default:
            return nil
        }
    }
}





