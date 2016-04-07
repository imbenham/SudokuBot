//
//  SudokuBox.swift
//  SudokuBot
//
//  Created by Isaac Benham on 4/7/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import Foundation

class Box: SudokuItem, Nester{
    
    typealias T = Tile
    
    var boxes: [Tile] = []
    
    override init(index: Int) {
        super.init(index:index)
        if boxes.count == 0 {
            for ind in 0...8 {
                let aBox = Tile(index: ind, withParent: self)
                boxes.append(aBox)
            }
        }
    }
    
    convenience init (index withIndex: Int, withParent parent: SudokuBoard){
        self.init(index: withIndex)
        self.parentSquare = parent
        controller = parent.controller
    }
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        for index in 0...8 {
            let aBox = Tile(index: index)
            boxes.append(aBox)
        }
    }
    
    override func layoutSubviews() {
        
        self.prepareBoxes()
    }
    
    
    override func didSetController() {
        for box in boxes {
            box.controller = self.controller
            let tapRecognizer = UITapGestureRecognizer(target: controller, action: Selector("tileTapped:"))
            box.addGestureRecognizer(tapRecognizer)
            let longPressRecognizer = UILongPressGestureRecognizer(target: controller, action: "toggleNoteMode:")
            tapRecognizer.requireGestureRecognizerToFail(longPressRecognizer)
            box.addGestureRecognizer(longPressRecognizer)
        }
    }
    
    func makeRow(row: Int)-> [Tile] {
        switch row {
        case 1:
            return [boxes[0], boxes[1], boxes[2]]
        case 2:
            return [boxes[3], boxes[4], boxes[5]]
        default:
            return [boxes[6], boxes[7], boxes[8]]
        }
    }
    
    
    func makeColumn(column: Int) -> [Tile]{
        switch column {
        case 1:
            return [boxes[0], boxes[3], boxes[6]]
        case 2:
            return [boxes[1], boxes[4], boxes[7]]
        default:
            return [boxes[2], boxes[5], boxes[8]]
        }
    }
    
    func prepareBoxes() {
        
        for box in boxes {
            self.addSubview(box)
            box.userInteractionEnabled = true
            box.layer.borderColor = UIColor.lightGrayColor().CGColor
            box.layer.borderWidth = 1
            box.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let constraints:[NSLayoutConstraint] = BoxSetter().configureConstraintsForParentSquare(self)
        self.addConstraints(constraints)
        
        
        if let parent = self.parentSquare as? SudokuBoard {
            parent.tilesReady()
        }
        
        
    }
    
}

extension Box {
    // add game-logic related methods
    
    func getTileAtIndex(index: Int) -> Tile {
        return boxes[index]
    }
    
    
    func getNilTiles() -> [Tile] {
        var nilTiles = [Tile]()
        for box in boxes {
            let tile = box
            if tile.displayValue == TileValue.Nil {
                nilTiles.append(tile)
            }
        }
        return nilTiles
    }
}
