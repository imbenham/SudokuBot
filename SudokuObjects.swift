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
    var index = 0
}


class SudokuBoard: SudokuItem, SquareNester {
    typealias NestingSquare = Box
    
    var boxes: [SudokuItem]
    var delegate: SquareNesterDelegate?
    
    override init(frame: CGRect) {
        self.boxes = [Box]()
        super.init(frame: frame)
        
        for index in 0...8 {
            let aBox = Box(index: index)
            boxes.append(aBox)
            self.addSubview(aBox)
        }
        
        self.prepareBoxes()
    }
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareBoxes() {
        for box in boxes {
            box.parentSquare = self
            box.backgroundColor = UIColor.lightGrayColor()
            box.layer.borderColor = UIColor.blackColor().CGColor
            box.layer.borderWidth = 1.0
            box.userInteractionEnabled = true
            box.setTranslatesAutoresizingMaskIntoConstraints(false)
        }
        self.delegate = BoxSetter(squareNester: self)
        self.delegate = BoxSetter(squareNester: self)
        let constraints = self.delegate!.configureBoxConstraints()
        self.addConstraints(constraints)
    }
    
    
    func sudokuItem() -> SudokuItem {
        return self
    }
    
    func convertBoxesToContainBoxes() -> [Box] {
        var boxesToReturn = [Box]()
        for box in boxes {
            let boxAs = box as! Box
            boxesToReturn.append(boxAs)
        }
        return boxesToReturn
    }
    
    func getBoxAtIndex(index: Int) -> Box {
        return boxes[index] as! Box
    }
}


class Box: SudokuItem, SquareNester, Nestable {
    typealias NestingSquare = Tile
    var boxes = [SudokuItem]()
    var delegate: SquareNesterDelegate?
    
    init(index withIndex: Int){
        super.init(frame: CGRectZero)
        self.index = withIndex
        for index in 0...8 {
            let aBox = Tile(index: index, parent: self)
            boxes.append(aBox)
            self.addSubview(aBox)
        }
        
        self.prepareBoxes()
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func convertBoxesToContainTiles() -> [Tile] {
        var boxesToReturn = [Tile]()
        for box in boxes {
            let boxAs = box as! Tile
            boxesToReturn.append(boxAs)
        }
        
        return boxesToReturn
    }
    
    func sudokuItem() -> SudokuItem {
        return self
    }
    
    func prepareBoxes() {
        for box in boxes {
            box.backgroundColor = UIColor.whiteColor()
            box.layer.borderColor = UIColor.lightGrayColor().CGColor
            box.layer.borderWidth = 1.0
            box.userInteractionEnabled = true
            box.setTranslatesAutoresizingMaskIntoConstraints(false)
        }
        self.delegate = BoxSetter(squareNester: self)
        let constraints = self.delegate!.configureBoxConstraints()
        self.addConstraints(constraints)
    }
    
    func getTileAtIndex(index: Int) -> Tile {
        return boxes[index] as! Tile
    }
    
}

class Tile: SudokuItem, Nestable {
    
    typealias TileIndex = (Box:Int, Tile:Int)
    
    required init(index withIndex: Int, parent: SudokuItem) {
        super.init(frame: CGRectMake(0, 0, 0, 0))
        index = withIndex
        parentSquare = parent
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tileIndex() -> TileIndex {
        return (parentSquare!.index, index)
    }
    
    func indexString() -> String {
        let box = tileIndex().0
        let tile = tileIndex().1
        return "This tile's index is: \(box).\(tile) "
    }
    
}

protocol SquareNester  {
    var boxes: [SudokuItem] {get set}
    var delegate:SquareNesterDelegate? {get set}
    func sudokuItem() -> SudokuItem
    
}

protocol SquareNesterDelegate {
    
    var boxes: [SudokuItem] {get set}
    var row1: [SudokuItem] { get set}
    var row2: [SudokuItem] { get set}
    var row3: [SudokuItem] { get set}
    var column1: [SudokuItem] { get set}
    var column2: [SudokuItem] { get set}
    var column3: [SudokuItem] { get set}
    
    init (squareNester: SquareNester)
    
    func configureBoxConstraints() -> [NSLayoutConstraint]
}

protocol Nestable {
    // there might be a use for this down the road...
}


class BoxSetter: SquareNesterDelegate {
    
    var clientItem: SudokuItem
    var boxes:[SudokuItem]
    var row1: [SudokuItem]
    var row2: [SudokuItem]
    var row3: [SudokuItem]
    var column1: [SudokuItem]
    var column2: [SudokuItem]
    var column3: [SudokuItem]
    
    required init (squareNester: SquareNester) {
        boxes = squareNester.boxes
        row1 = [boxes[0], boxes[1], boxes[2]]
        row2 = [boxes[3], boxes[4], boxes[5]]
        row3 = [boxes[6], boxes[7], boxes[8]]
        column1 = [boxes[0], boxes[3], boxes[6]]
        column2 = [boxes[1], boxes[4], boxes[7]]
        column3 = [boxes[2], boxes[5], boxes[8]]
        
        clientItem = squareNester.sudokuItem()
    }
    
    func configureBoxConstraints() -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        
        for box in row1 {
            constraints.extend(self.makeLayoutConstraintsForBox(box, forAttributes: [.Top, .Width, .Height,]))
        }
        
        for box in row3 {
            constraints.extend(self.makeLayoutConstraintsForBox(box, forAttributes: [.Bottom, .Width, .Height]))
        }
        
        for box in column1 {
            constraints.extend(self.makeLayoutConstraintsForBox(box, forAttributes: [.Leading, .Width, .Height]))
        }
        
        for box in column3 {
            constraints.extend(self.makeLayoutConstraintsForBox(box, forAttributes: [.Trailing, .Width, .Height]))
        }
        
        for box in row2 {
            constraints.extend(self.makeLayoutConstraintsForBox(box, forAttributes: [.Top, .Bottom, .Width, .Height]))
        }
        
        for box in column2 {
            constraints.extend(self.makeLayoutConstraintsForBox(box, forAttributes: [.Leading, .Trailing]))
            
        }
        
        return constraints
    }
    
    
    func makeLayoutConstraintsForBox(aBox: SudokuItem, forAttributes attributes:[NSLayoutAttribute]) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        
        for attribute in attributes {
            constraints.append(self.makeLayoutConstraintForBox(aBox, forAttribute: attribute))
        }
        
        return constraints
    }
    
    private func makeLayoutConstraintForBox(aBox: SudokuItem, forAttribute anAttribute: NSLayoutAttribute) -> NSLayoutConstraint {
        switch anAttribute{
        case .Width, .Height:
            return NSLayoutConstraint(item: aBox, attribute: anAttribute, relatedBy: NSLayoutRelation.Equal, toItem: aBox.parentSquare, attribute: anAttribute, multiplier: 1/3, constant: 0)
        default:
            let neighborItem = self.getNeighborForBoxIndex(aBox.index, forAttribute: anAttribute)!
            let neighborAttribute = neighborItem.attribute
            let neighborView = neighborItem.neighbor
            return NSLayoutConstraint(item: aBox, attribute: anAttribute, relatedBy: NSLayoutRelation.Equal, toItem: neighborView, attribute: neighborAttribute, multiplier: 1, constant: 0)
            
        }
        
    }
    
    // MARK: Constraint maker helpers
    typealias ToItem = (neighbor:SudokuItem, attribute:NSLayoutAttribute)?
    
    func getNeighborForBoxIndex(index: Int, forAttribute anAttribute:NSLayoutAttribute) -> ToItem {
        switch anAttribute {
        case .Bottom:
            return self.getBottomNeighborForBoxIndex(index)
        case .Top:
            return self.getTopNeighborForBoxIndex(index)
        case .Left,.Leading:
            return self.getLeftNeighborForBoxIndex(index)
        case .Right,.Trailing:
            return self.getRightNeighborForBoxIndex(index)
        default:
            return nil
        }
    }
    
    func getTopNeighborForBoxIndex(index: Int) -> ToItem {
        switch index {
        case 3...8:
            return (boxes[index-3], .Bottom)
        case 0...2:
            return (clientItem, .Top)
        default:
            return nil
        }
    }
    
    func getBottomNeighborForBoxIndex(index: Int) -> ToItem {
        switch index {
        case 0...5:
            return (boxes[index+3], .Top)
        case 5...8:
            return (clientItem, .Bottom)
        default:
            return nil
        }
    }
    
    func getLeftNeighborForBoxIndex(index: Int) ->ToItem {
        switch index {
        case 0,3,6:
            return (clientItem, .Leading)
        case 1,2,4,5,7,8:
            return (boxes[index-1], .Trailing)
        default:
            return nil
        }
    }
    
    func getRightNeighborForBoxIndex(index: Int) -> ToItem {
        switch index {
        case 2,5,8:
            return (clientItem, .Trailing)
        case 0,1,3,4,6,7:
            return (boxes[index+1], .Leading)
        default:
            return nil
        }
    }
    
}