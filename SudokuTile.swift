//
//  SudokuTile.swift
//  SudokuBot
//
//  Created by Isaac Benham on 4/7/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import Foundation


class Tile: SudokuItem {
    
    var defaultImage: UIImage!
    var valueGivenImage: UIImage!
    var selectedImage: UIImage!
    var noteModeImage: UIImage!
    var valueCorrectImage: UIImage!
    
    override weak var controller: SudokuController? {
        get {
            return parentSquare?.controller
        }
        set {
            parentSquare?.controller = newValue
        }
    }
    
    var displayValue: TileValue {
        get {
            guard let bc = backingCell else {
                return .Nil
            }
            
            if let solutionValue = solutionValue {
                if revealed {
                    return TileValue(rawValue: solutionValue)!
                } else  if let assignedVal = bc.assignedValue {
                    return TileValue(rawValue: Int(assignedVal))!
                }
                
                return .Nil
            } else {
                userInteractionEnabled = false
                return TileValue(rawValue:Int(bc.value))!
            }
            
        }
    }
    var revealed: Bool {
        
        get {
            guard let backingCell = backingCell else {
                return false
            }
            
            return backingCell.revealed.boolValue
        }
        
        set {
            guard backingCell != nil else{
                return
            }
            if newValue == true {
                backingCell?.revealed = true
                clearNoteValues()
                userInteractionEnabled = false
            } else {
                backingCell?.revealed = false
                userInteractionEnabled = true
            }
        }
    }
    var valueLabel = UILabel()
    var labelColor = UIColor.blackColor()
    let defaultTextColor = UIColor.blackColor()
    let chosenTextColor = UIColor.redColor()
    var selected:Bool  {
        get {
            if let controller = controller {
                return controller.selectedTile == self
            }
            
            return false
        }
    }
    var symbolSet: Utils.TextConfigs.SymbolSet {
        get {
            let defaults = NSUserDefaults.standardUserDefaults()
            let symType = defaults.integerForKey(Utils.Identifiers.symbolSetKey)
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
    var backgroundImageView = UIImageView()
    
    let noteLabels: [TableCell]
    var backingCell: BackingCell? {
        didSet {
            if let bc = backingCell {
                labelColor = UIColor.blackColor()
                if bc.puzzleSolution != nil {
                    userInteractionEnabled = true
                } else if bc.puzzleInitial != nil {
                    userInteractionEnabled = false
                }
            }
            refreshLabel()
        }
    }
    
    let wrongColor = UIColor(red: 1.0, green: 0.0, blue: 0, alpha: 0.3)
    
    let noteBackground = UIView()
    var noteMode:Bool {
        if let controller = controller as? PlayPuzzleViewController {
            return controller.noteMode
        }
        return false
    }
    var noteValues: [Int] {
        get {
            guard let backingCell = backingCell else {
                return []
            }
            return backingCell.notesArray.sort(<)
        }
    }
    
    var tvNoteValues: [TileValue] {
        get {
            return noteValues.map({TileValue(rawValue: $0)!})
        }
    }
    
    var solutionValue: Int? {
        get {
            if backingCell?.puzzleSolution != nil {
                return Int(backingCell!.value)
            }
            
            return nil
        }
    }
    
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
    
    convenience init (index: Int, withParent parent: SudokuItem) {
        self.init(index: index)
        self.parentSquare = parent
        // let tileIndex: TileIndex = (parent.index, self.index)
        let cells = cellsFromTiles([self])
        self.backingCell = BackingCell(cell:cells[0])
    }
    
    //tiles -> cells
    private func cellsFromTiles(tiles:[Tile]) -> [PuzzleCell] {
        var cells: [PuzzleCell] = []
        for tile in tiles {
            let val = tile.displayValue.rawValue
            let row = tile.getRowIndex()
            let column = tile.getColumnIndex()
            let pCell = PuzzleCell(row: row, column: column, value: val)
            cells.append(pCell)
        }
        
        return cells
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
        clipsToBounds = true
        addSubview(backgroundImageView)
        backgroundImageView.frame = bounds
        backgroundImageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        backgroundImageView.backgroundColor = UIColor.clearColor()
        
        let size = backgroundImageView.frame.size
        let configs = Utils.TileConfigs.self
        
        defaultImage = configs.backgroundImageForSize(size)
        valueGivenImage = configs.backgroundImageForSize(size, color: UIColor.darkGrayColor(), inverted: true)
        selectedImage = configs.backgroundImageForSize(size, color: UIColor(red: 0.1, green: 0.1, blue: 0.9, alpha: 1.0))
        noteModeImage = configs.backgroundImageForSize(size, color: UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0))
        valueCorrectImage = configs.backgroundImageForSize(size, color:UIColor(red: 0.0, green: 1.0, blue: 0, alpha: 1.0))
        
        
        self.layer.cornerRadius = 3.0
        
        backgroundImageView.addSubview(valueLabel)
        valueLabel.frame = self.bounds
        valueLabel.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        valueLabel.textAlignment = .Center
        valueLabel.font = UIFont.boldSystemFontOfSize(UIFont.labelFontSize()+2)
        
        noteBackground.frame = bounds
        backgroundImageView.addSubview(noteBackground)
        noteBackground.backgroundColor = UIColor.clearColor()
        for label in noteLabels {
            label.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            label.backgroundColor = UIColor.clearColor()
            noteBackground.addSubview(label)
        }
        layoutNoteViews()
        
        refreshLabel()
    }
    
    func addNote(note: Int) {
        self.backingCell?.notesArray.append(note)
    }
    
    func clearValue() {
        backingCell?.assignedValue = 0
    }
    
    func getValueText()->String {
        return self.displayValue != .Nil ? symbolSet.getSymbolForTileValue(displayValue) : ""
    }
    
    
    func refreshLabel() {
        
        guard let backingCell = backingCell else {
            valueLabel.text = ""
            refreshBackground()
            configureNoteViews()
            return
        }
        if backingCell.revealed.boolValue {
            valueLabel.textColor = chosenTextColor
            userInteractionEnabled = false
        } else if backingCell.puzzleSolution != nil{
            valueLabel.textColor = labelColor
            userInteractionEnabled = true
            
        } else {
            valueLabel.textColor = UIColor.whiteColor()
        }
        
        valueLabel.text = noteMode ? "" : self.getValueText()
        refreshBackground()
        configureNoteViews()
    }
    
    private func refreshBackground() {
        guard let backingCell = backingCell else {
            backgroundImageView.image = defaultImage
            return
        }
        
        if noteMode {
            if selected {
                backgroundImageView.image = noteModeImage
                for lv in noteLabels {
                    lv.layer.borderWidth = 1
                }
                return
            }
        }
        
        if backingCell.puzzleInitial != nil {
            backgroundImageView.image = valueGivenImage
        } else {
            backgroundImageView.image = selected ? selectedImage : defaultImage
        }
        
        
        for lv in noteLabels {
            lv.layer.borderWidth = 0.0
        }
    }
    
    func removeNoteValue(value: Int) {
        var newNotes = backingCell!.notesArray
        let index = newNotes.indexOf(value)!
        newNotes.removeAtIndex(index)
        backingCell!.notesArray = newNotes
        configureNoteViews()
    }
    
    func clearNoteValues() {
        backingCell?.notesArray = []
        //configureNoteViews()
    }
    
    func addNoteValue(value: Int) {
        var newNotes = backingCell!.notesArray
        newNotes.append(value)
        backingCell!.notesArray = newNotes
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
            
            noteLabel.layer.borderColor = UIColor(red: 0.1, green: 0.1, blue: 0.9, alpha: 0.3).CGColor
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
                noteLabel.label?.text = index < numNotes ? symbolSet.getSymbolForTileValue(tvNoteValues[index]) : ""
            }
            
        }
    }
    
    func prepareForPuzzleSolvedAnimation() {
        backgroundImageView.image = defaultImage
    }
    
    func finishPuzzleSolvedAnimation() {
        backgroundImageView.image = valueCorrectImage
    }
}

extension Tile {
    // add game-logic related methods
    
    var tileIndex: TileIndex {
        get {
            guard let pSquare = parentSquare as? Box else {
                return (0,index)
            }
            return (pSquare.index, index)
        }
        
    }
    
    
    
    func indexString() -> String {
        let box = tileIndex.Box
        let tile = tileIndex.Tile
        return "This tile's index is: \(box).\(tile) "
    }
    
    func getColumnIndex() -> Int {
        switch self.tileIndex.Box{
        case 0,3,6:
            switch self.tileIndex.Tile{
            case 0,3,6:
                return 1
            case 1,4,7:
                return 2
            default:
                return 3
            }
        case 1,4,7:
            switch self.tileIndex.Tile{
            case 0,3,6:
                return 4
            case 1,4,7:
                return 5
            default:
                return 6
            }
        default:
            switch self.tileIndex.Tile {
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
        switch self.tileIndex.Box{
        case 0,1,2:
            switch self.tileIndex.Tile{
            case 0,1,2:
                return 1
            case 3,4,5:
                return 2
            default:
                return 3
            }
        case 3,4,5:
            switch self.tileIndex.Tile{
            case 0,1,2:
                return 4
            case 3,4,5:
                return 5
            default:
                return 6
            }
        default:
            switch self.tileIndex.Tile {
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
