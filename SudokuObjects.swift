//
//  SudokuObjects.swift
//  SudokuCheat
//
//  Created by Isaac Benham on 4/14/15.
//  Copyright (c) 2015 Isaac Benham. All rights reserved.
//

import UIKit

class SudokuItem: UIView {
    var parentSquare: Nester?
    var defaultIndex = 0
    
    init(index: Int) {
        super.init(frame: CGRectZero)
        self.defaultIndex = index
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
    var index: Int {
        get {
            return self.defaultIndex
        }
    }
}


class SudokuBoard: UIView, Nester {
    
    weak var controller: SudokuController?
    var boxes: [SudokuItem] = []
    var selectedTile: Tile? {
        willSet(newSelectedTile) {
            if let sel = selectedTile {
                sel.selected = false
                sel.refreshBackground()
            }
            if let nowSelected = newSelectedTile {
                nowSelected.selected = true
                nowSelected.refreshBackground()
            }
        }
        didSet {
            if let contrl = self.controller {
                contrl.boardSelectedTileChanged()
            }
        }
    }
    
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        for index in 0...8 {
            let aBox = Box(index: index, withParent: self)
            aBox.parentSquare = self
            boxes.append(aBox)
            self.addSubview(aBox)
        }
        self.prepareBoxes()
    }
    

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        for index in 0...8 {
            let aBox = Box(index: index)
            boxes.append(aBox)
            self.addSubview(aBox)
        }
        self.prepareBoxes()
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
    
    
    private func prepareBoxes() {
        for nested in boxes {
            let box = nested as SudokuItem
            box.parentSquare = self
            box.backgroundColor = UIColor.lightGrayColor()
            box.layer.borderColor = UIColor.blackColor().CGColor
            box.layer.borderWidth = 1.0
            box.userInteractionEnabled = true
            box.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let constraints = BoxSetter().configureConstraintsForParentSquare(self)
        self.addConstraints(constraints)
    }
    
    func tileTapped(sender: UIGestureRecognizer) {
        
        if let tapped = sender.view as? Tile {
            self.selectedTile = tapped
        }
    }
    
    func view() -> UIView {
        return self
    }
    
    func tilesReady() {
        if let cntrlr = self.controller {
            cntrlr.boardReady()
        }
    }
    
}


class Box: SudokuItem, Nester{
    
    var boxes: [SudokuItem] = []
    
    override init(index: Int) {
        super.init(index:index)
        if boxes.count == 0 {
            for ind in 0...8 {
                let aBox = Tile(index: ind, withParent: self)
                boxes.append(aBox)
                self.addSubview(aBox)
                aBox.userInteractionEnabled = true
            }
        }
    }
    
    convenience init (index withIndex: Int, withParent parent: SudokuBoard){
        self.init(index: withIndex)
        self.parentSquare = parent
        
        for aBox in self.boxes {
            let tapRecognizer = UITapGestureRecognizer(target: parent, action: "tileTapped:")
            aBox.addGestureRecognizer(tapRecognizer)
        }
        

    }

    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        for index in 0...8 {
            let aBox = Tile(index: index)
            boxes.append(aBox)
            self.addSubview(aBox)
        }
        self.prepareBoxes()
    }
    
    override func layoutSubviews() {
        self.prepareBoxes()
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
    
    private func prepareBoxes() {
        for nested in boxes {
            let box = nested as SudokuItem
            box.backgroundColor = UIColor.whiteColor()
            box.layer.borderColor = UIColor.lightGrayColor().CGColor
            box.layer.borderWidth = 1.0
            box.userInteractionEnabled = true
            box.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let constraints:[NSLayoutConstraint] = BoxSetter().configureConstraintsForParentSquare(self)
        self.addConstraints(constraints)
        
        
        if let parent = self.parentSquare as? SudokuBoard {
            parent.tilesReady()
        }


    }
    
    func view() -> UIView {
        return self
    }
    
}

func == (lhs:Tile, rhs:Tile) {
    
}

class Tile: SudokuItem {
    
    var value: TileValue = TileValue.Nil {
        didSet {
            refreshLabel()
        }
    }
    var valueLabel = UILabel()
    var labelColor = UIColor.blackColor()
    var selected = false
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
    
    let defaultBackgroundColor = UIColor.whiteColor()
    let assignedBackgroundColor = UIColor(red: 0.0, green: 1.0, blue: 0, alpha: 0.3)
    let wrongColor = UIColor(red: 1.0, green: 0.0, blue: 0, alpha: 0.3)
    let selectedColor = UIColor(red: 0.1, green: 0.1, blue: 0.9, alpha: 0.2)
    
    var solutionValue: Int?

    override init (index: Int) {
        super.init(index: index)
        
    }
    
    convenience init (index: Int, withParent parent: Nester) {
        self.init(index: index)
        self.parentSquare = parent
    }
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    override func layoutSubviews() {
        self.addSubview(valueLabel)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        let labelCenterX = NSLayoutConstraint(item: valueLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        let labelCenterY = NSLayoutConstraint(item: valueLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        self.addConstraints([labelCenterX, labelCenterY])
        refreshLabel()
    }
    
    func getValueText()->String {
        return self.value != .Nil ? symbolSet.getSymbolForTyleValue(value) : ""
    }
    
    func view() -> UIView {
        return self
    }
    
    func refreshLabel() {
        valueLabel.textColor = labelColor
        valueLabel.text = self.getValueText()
        refreshBackground()
    }
    
    func refreshBackground() {
        if value != .Nil && solutionValue != nil {
            backgroundColor = selected ? selectedColor : assignedBackgroundColor
        } else {
            backgroundColor = selected ? selectedColor : defaultBackgroundColor
        }

    }
}


    class BoxSetter {
    
    func configureConstraintsForParentSquare<U:UIView where U:Nester>(square: U) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        
        for box in square.makeRow(.One) {
            constraints.extend(self.makeLayoutConstraintsForBox(box, inBox: square, forAttributes: [.Top, .Height]))
        }
        
        for box in square.makeRow(.Three) {
            constraints.extend(self.makeLayoutConstraintsForBox(box, inBox: square, forAttributes: [.Bottom, .Height]))
        }
        
        for box in square.makeColumn(.One) {
            constraints.extend(self.makeLayoutConstraintsForBox(box, inBox: square, forAttributes: [.Leading, .Width]))
        }
        
        for box in square.makeColumn(.Three) {
            constraints.extend(self.makeLayoutConstraintsForBox(box, inBox: square, forAttributes: [.Trailing, .Width]))
        }
        
        for box in square.makeRow(.Two) {
            constraints.extend(self.makeLayoutConstraintsForBox(box, inBox: square, forAttributes: [.Top, .Bottom]))
        }
        
       for box in square.makeColumn(.Two) {
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
            return NSLayoutConstraint(item: box, attribute: anAttribute, relatedBy: NSLayoutRelation.Equal, toItem: parentBox, attribute: anAttribute, multiplier: 1/3, constant: 0)
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
            return (parent, .Top)
        default:
            return nil
        }
    }
    
    func getBottomNeighborForBoxIndex<U:UIView where U:Nester>(index: Int, inParent parent: U) -> ToItem {
        switch index {
        case 0...5:
            return (parent.boxes[index+3], .Top)
        case 5...8:
            return (parent, .Bottom)
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

enum TileValue:Int {
    case One = 1
    case Two = 2
    case Three = 3
    case Four = 4
    case Five = 5
    case Six = 6
    case Seven = 7
    case Eight = 8
    case Nine = 9
    case Nil = 0
    
    
    static func getFullSet()->Set<TileValue>{
        return [TileValue.One, TileValue.Two, TileValue.Three, TileValue.Four, TileValue.Five, TileValue.Six, TileValue.Seven, TileValue.Eight, TileValue.Nine]
        
    }
    
    func description() -> String {
        return "\(self.rawValue)"
    }
    
    
}

typealias TileIndex = (Box:Int, Tile:Int)

extension SudokuBoard {
    
    func getBoxAtIndex(index: Int) -> Box {
        let boxOfBoxes = self.boxes as! [Box]
        return boxOfBoxes[index-1]
    }
    
    func loadPuzzleWithIndexValues(valueList: [PuzzleCell]){
        if valueList.count != 81 {
            return
        }
        
        for cell in valueList {
            let index = getTileIndexForRow(cell.row, andColumn: cell.column)
            let value = TileValue(rawValue:cell.value)!
            
            self.tileAtIndex(index).value = value
        }
        
        
    }
    
    func loadPuzzleWithNonNilIndexValues(valueList: [PuzzleCell]) {
        if valueList.count > 81 {
            return
        }
    }
    
    func tileAtIndex(_index: TileIndex) -> Tile {
        return self.getBoxAtIndex(_index.0).getTileAtIndex(_index.1)
    }
    
    
    func getNilTiles() -> [Tile] {
        var nilTiles = [Tile]()
        for item in boxes {
            let box = item as! Box
            nilTiles += box.getNilTiles()
        }
        return nilTiles
    }
    
}

extension Box {
    // add game-logic related methods
    
    func getTileAtIndex(index: Int) -> Tile {
        return boxes[index] as! Tile
    }
    
    func getNilTiles() -> [Tile] {
        var nilTiles = [Tile]()
        for box in boxes {
            let tile = box as! Tile
            if tile.value == TileValue.Nil {
                nilTiles.append(tile)
            }
        }
        return nilTiles
    }
}

extension Tile {
    // add game-logic related methods
    
    func tileIndex() -> TileIndex {
        if let pSquare = parentSquare as? Box {
            return (pSquare.index, index)
        }
        return (0, index)
    }
    
    func indexString() -> String {
        let box = tileIndex().0
        let tile = tileIndex().1
        return "This tile's index is: \(box).\(tile) "
    }
    
    func getColumnIndex() -> Int {
        switch self.tileIndex().Box{
        case 0,3,6:
            switch self.tileIndex().Tile{
            case 0,3,6:
                return 1
            case 1,4,7:
                return 2
            default:
                return 3
            }
        case 1,4,7:
            switch self.tileIndex().Tile{
            case 0,3,6:
                return 4
            case 1,4,7:
                return 5
            default:
                return 6
            }
        default:
            switch self.tileIndex().Tile {
            case 0,3,6:
                return 7
            case 1,4,7:
                return 8
            default:
                return 9
            }
        }
    }
    
    
    func getRowIndex() -> Int {
        switch self.tileIndex().Box{
        case 0,1,2:
            switch self.tileIndex().Tile{
            case 0,1,2:
                return 1
            case 3,4,5:
                return 2
            default:
                return 3
            }
        case 3,4,5:
            switch self.tileIndex().Tile{
            case 0,1,2:
                return 4
            case 3,4,5:
                return 5
            default:
                return 6
            }
        default:
            switch self.tileIndex().Tile {
            case 0,1,2:
                return 7
            case 3,4,5:
                return 8
            default:
                return 9
            }
        }
    }
    
   
    
}
