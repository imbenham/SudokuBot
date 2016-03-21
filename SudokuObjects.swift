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
    var parentSquare:UIView?
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
    typealias T: SudokuItem
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


class SudokuBoard: SudokuItem, Nester {
    
    typealias T = Box
    
    var boxes: [Box] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        for index in 0...8 {
            let aBox = Box(index: index, withParent: self)
            aBox.parentSquare = self
            boxes.append(aBox)
        }
    }
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        for index in 0...8 {
            let aBox = Box(index: index)
            boxes.append(aBox)
        }
    }
    
    override func layoutSubviews() {
        self.prepareBoxes()
    }
    
    override func didSetController() {
        for box in boxes {
            box.controller = self.controller
        }
    }
    
    func makeRow(row: Int)-> [Box] {
        switch row {
        case 1:
            return [boxes[0], boxes[1], boxes[2]]
        case 2:
            return [boxes[3], boxes[4], boxes[5]]
        default:
            return [boxes[6], boxes[7], boxes[8]]
        }
    }
    
    func makeColumn(column: Int) -> [Box]{
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
            box.parentSquare = self
            self.addSubview(box)
            
            
            box.userInteractionEnabled = true
            box.translatesAutoresizingMaskIntoConstraints = false
            
            box.layer.borderColor = UIColor.blackColor().CGColor
            box.layer.borderWidth = 1.0
            
            
        }
        
        
        let constraints = BoxSetter().configureConstraintsForParentSquare(self)
        self.addConstraints(constraints)
        
    }
    
    
    
    func tilesReady() {
        if let cntrlr = self.controller {
            cntrlr.boardReady()
        }
    }
    
}


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
            let tapRecognizer = UITapGestureRecognizer(target: controller, action: "tileTapped:")
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



class Tile: SudokuItem {
    
    var value: TileValue = TileValue.Nil {
        didSet {
        if value != .Nil {
            noteValues = []
        }
        backingCell.value = value.rawValue
        refreshLabel()
        }
    }
    var discovered = false {
        didSet {
        if discovered == true {
            solutionValue = nil
            userInteractionEnabled = false
        }
        refreshLabel()
        }
    }
    var valueLabel = UILabel()
    var labelColor = UIColor.blackColor()
    let defaultTextColor = UIColor.blackColor()
    let chosenTextColor = UIColor.redColor()
    var selected = false {
        didSet {
        if !selected {
            noteMode = false
        }
        refreshLabel()
        }
    }
    var symbolSet: SymbolSet {
        get {
            let defaults = NSUserDefaults.standardUserDefaults()
            let symType = defaults.integerForKey(symbolSetKey)
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
    
    let noteLabels: [TableCell]
    let noteModeColor = UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 0.3)
    var backingCell: PuzzleCell!
    let defaultBackgroundColor = UIColor.whiteColor()
    let assignedBackgroundColor = UIColor(red: 0.0, green: 1.0, blue: 0, alpha: 0.3)
    let wrongColor = UIColor(red: 1.0, green: 0.0, blue: 0, alpha: 0.3)
    var selectedColor = UIColor(red: 0.1, green: 0.1, blue: 0.9, alpha: 0.2)
    let noteBackground = UIView()
    var noteMode = false {
        didSet {
        if noteMode == true {
            if value != .Nil {
                noteValues.append(value)
            }
            self.selected = true
            
        } else {
            if noteValues.count > 0 {
                value = .Nil
            }
        }
        refreshBackground()
        controller?.refreshNoteButton()
        }
    }
    var noteValues: [TileValue] = []
    
    var solutionValue: Int?
    
    override init (index: Int) {
        var labels: [TableCell] = []
        while labels.count < 9 {
            let tc = TableCell()
            tc.label = UILabel()
            tc.label?.textAlignment = .Center
            labels.append(tc)
        }
        noteLabels = labels
        super.init(index: index)
        
    }
    
    convenience init (index: Int, withParent parent: UIView) {
        self.init(index: index)
        self.parentSquare = parent
        // let tileIndex: TileIndex = (parent.index, self.index)
        let cells = cellsFromTiles([self])
        self.backingCell = cells[0]
    }
    
    
    required init(coder aDecoder: NSCoder) {
        var labels: [TableCell] = []
        while labels.count < 9 {
            let tc = TableCell()
            tc.label = UILabel()
            tc.label?.textAlignment = .Center
            labels.append(tc)
        }
        noteLabels = labels
        super.init(coder: aDecoder)
    }
    
    
    
    override func layoutSubviews() {
        self.addSubview(valueLabel)
        valueLabel.frame = self.bounds
        valueLabel.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        valueLabel.textAlignment = .Center
        valueLabel.font = UIFont.boldSystemFontOfSize(UIFont.labelFontSize()+2)
        
        noteBackground.frame = self.bounds
        addSubview(noteBackground)
        noteBackground.backgroundColor = UIColor.clearColor()
        for label in noteLabels {
            label.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            label.backgroundColor = UIColor.clearColor()
            noteBackground.addSubview(label)
        }
        layoutNoteViews()
        
        refreshLabel()
    }
    
    
    func getValueText()->String {
        return self.value != .Nil ? symbolSet.getSymbolForTyleValue(value) : ""
    }
    
    
    func refreshLabel() {
        if discovered {
            valueLabel.textColor = chosenTextColor
        } else {
            valueLabel.textColor = labelColor
        }
        
        valueLabel.text = noteMode ? "" : self.getValueText()
        refreshBackground()
        configureNoteViews()
    }
    
    func refreshBackground() {
        if noteMode {
            if selected {
                self.backgroundColor = noteModeColor
                for lv in noteLabels {
                    lv.layer.borderWidth = 0.25
                }
                return
            }
        }
        
        if value != .Nil && solutionValue != nil {
            backgroundColor = selected ? selectedColor : assignedBackgroundColor
        } else if discovered {
            backgroundColor = defaultBackgroundColor
        } else {
            backgroundColor = selected ? selectedColor : defaultBackgroundColor
        }
        
        for lv in noteLabels {
            lv.layer.borderWidth = 0.0
        }
    }
    
    func removeNoteValue(value: TileValue) {
        let index = noteValues.indexOf(value)!
        noteValues.removeAtIndex(index)
        configureNoteViews()
    }
    
    func addNoteValue(value: TileValue) {
        noteValues.append(value)
        configureNoteViews()
    }
    
    func layoutNoteViews() {
        
        for index in 0...8 {
            let noteLabel = noteLabels[index]
            var rect = self.noteBackground.bounds
            rect.size.width *= 1/3
            rect.size.height *= 1/3
            
            if index > 2 {
                if index < 6 {
                    rect.origin.y = noteLabels[0].frame.size.height
                } else {
                    rect.origin.y = noteLabels[0].frame.size.height*2
                }
            }
            
            if index == 1 || index == 4 || index == 7 {
                rect.origin.x = noteLabels[0].frame.size.width
            } else if index == 2 || index == 5 || index == 8 {
                rect.origin.x = noteLabels[0].frame.size.width*2
            }
            
            noteLabel.frame = rect
            
            noteLabel.layer.borderColor = selectedColor.CGColor
            let fontHeight = noteLabel.frame.size.height * 9/10
            noteLabel.label?.font = UIFont(name: "futura", size: fontHeight)
            noteLabel.label?.textColor = UIColor.darkGrayColor()
            
        }
    }
    
    func configureNoteViews() {
        let numNotes = noteValues.count
        for index in 0...noteLabels.count-1 {
            let noteLabel = noteLabels[index]
            if symbolSet != .Standard {
                noteLabel.label?.text = ""
            } else {
                noteLabel.label?.text = index < numNotes ? symbolSet.getSymbolForTyleValue(noteValues[index]) : ""
            }
            
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
        let boxOfBoxes = self.boxes
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
            let box = item
            nilTiles += box.getNilTiles()
        }
        return nilTiles
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