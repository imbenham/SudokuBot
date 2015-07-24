//
//  ViewController.swift
//  SudokuCheat
//
//  Created by Isaac Benham on 4/14/15.
//  Copyright (c) 2015 Isaac Benham. All rights reserved.
//

import UIKit
// look up voice-over


class SudokuController: UIViewController, NumPadDelegate {
    
    var board: SudokuBoard
    var numPad: SudokuNumberPad
    private var _puzzle: Puzzle?
    var puzzle: Puzzle? {
        var puzzCopy: Puzzle!
        dispatch_sync(concurrentPuzzleQueue){
            puzzCopy = self._puzzle
        }
        return puzzCopy
    }
    
    var difficulty: PuzzleDifficulty = .Easy
    
    private let concurrentPuzzleQueue = dispatch_queue_create(
    "com.isaacbenham.SudokuCheat.puzzleQueue", DISPATCH_QUEUE_CONCURRENT)
    
    private let spinner: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    
    required init(coder aDecoder: NSCoder) {
        numPad = SudokuNumberPad(frame: CGRectZero)
        board = SudokuBoard(frame: CGRectZero)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        board.controller = self
        numPad.delegate = self
        view.addSubview(board)
        view.addSubview(numPad)
        board.addSubview(spinner)
        self.setUpBoard()
    }
    
    
    func setUpBoard() {
        board.translatesAutoresizingMaskIntoConstraints = false
        
        let topPin = NSLayoutConstraint(item: board, attribute: .Top, relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 20)
        let centerPin = NSLayoutConstraint(item: board, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
        let boardWidth = NSLayoutConstraint(item: board, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 0.95, constant: 0)
        let boardHeight = NSLayoutConstraint(item: board, attribute: .Height, relatedBy: .Equal, toItem: board, attribute: .Width, multiplier: 1, constant: 0)
        
        let constraints = [topPin, centerPin, boardWidth, boardHeight]
        self.view.addConstraints(constraints)
        
        board.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 1, alpha: 1)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        numPad.translatesAutoresizingMaskIntoConstraints = false
        spinner.translatesAutoresizingMaskIntoConstraints = false
        let numPadWidth = NSLayoutConstraint(item: numPad, attribute: .Width, relatedBy: .Equal, toItem: board, attribute: .Width, multiplier: 1, constant: 0)
        let numPadHeight = NSLayoutConstraint(item: numPad, attribute: .Height, relatedBy: .Equal, toItem: board, attribute: .Width, multiplier: 1/9, constant: 0)
        let numPadCenterX = NSLayoutConstraint(item: numPad, attribute: .CenterX, relatedBy: .Equal, toItem: board, attribute: .CenterX, multiplier: 1, constant: 0)
        let numPadTopSpace = NSLayoutConstraint(item: numPad, attribute: .Top, relatedBy: .Equal, toItem: board, attribute: .Bottom, multiplier: 1, constant: 8)
        let spinnerHor = NSLayoutConstraint(item: spinner, attribute: .CenterX, relatedBy: .Equal, toItem: board, attribute: .CenterX, multiplier: 1, constant: 0)
        let spinnerVert = NSLayoutConstraint(item: spinner, attribute: .CenterY, relatedBy: .Equal, toItem: board, attribute: .CenterY, multiplier: 1, constant: 0)
        
        self.view.addConstraints([numPadWidth, numPadHeight, numPadCenterX, numPadTopSpace, spinnerHor, spinnerVert])
        
    }
    
    func tileAtIndex(_index: TileIndex) -> Tile {
        return board.getBoxAtIndex(_index.0).getTileAtIndex(_index.1)
    }
    
    func clearAllValues() {
        for tile in tiles() {
            tile.value = TileValue.Nil
        }
        board.selectedTile = nil
        numPad.refresh()
    }
    
    func tiles() -> [Tile] {
        var mutableTiles = [Tile]()
        let boxList = self.board.boxes as! [Box]
        for box in boxList {
            let containedTiles = box.boxes as! [Tile]
            mutableTiles.extend(containedTiles)
        }
        return mutableTiles
    }
    
    func nonNilTiles()->[Tile]{
        var nonNilTiles = [Tile]()
        for tile in tiles() {
            if tile.value != .Nil {
                nonNilTiles.append(tile)
            }
        }
        return nonNilTiles
    }
    
    func nilTiles()->[Tile]{
        var nilTiles = [Tile]()
        for tile in tiles() {
            if tile.value == .Nil {
                nilTiles.append(tile)
            }
        }
        return nilTiles
    }
    
    // puzzle fetching
    func fetchPuzzle() {
        board.selectedTile = board.tileAtIndex((5,4))
        spinner.startAnimating()
        dispatch_barrier_async(concurrentPuzzleQueue) {
            Matrix.sharedInstance.generatePuzzleOfDifficulty(self.difficulty) { puzz -> () in
                dispatch_async(GlobalMainQueue){
                    self.spinner.stopAnimating()
                    self._puzzle = puzz
                    self.puzzleReady()
                }
            }
        }
        
    }
    
    // Board tile selected handler
    func boardSelectedTileChanged() {
        numPad.refresh()
    }
    
    func boardReady() {
        let nils = nilTiles()
        if nils.count > 0 {
            board.selectedTile = nils[0]
        }
    }
    
    func puzzleReady() {
        
    }
    
    
    // NumPadDelegate methods
    func valueSelected(value: Int) {
        if let selected = board.selectedTile {
            if selected.value.rawValue == value {
                selected.value = TileValue(rawValue: 0)!
            } else {
                if let newTV = TileValue(rawValue: value) {
                    selected.value = newTV
                }
            }
        }
        numPad.refresh()
    }
    
    func currentValue() -> Int? {
        if let sel = self.board.selectedTile {
           let val = sel.value.rawValue
            if val == 0 {
                return nil
            }
            return val
        }
        return nil
    }
    
}

class PuzzleOptionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let tableView = UITableView(frame: CGRectZero, style: .Grouped)
    let baseView = UIView(frame: CGRectZero)
    var selectedSet = NSIndexPath(forRow: 0, inSection: 0) {
        willSet {
            if selectedSet != newValue {
                let cell = tableView.cellForRowAtIndexPath(selectedSet)
                cell?.accessoryType = .None
            }
        }
        didSet {
            if selectedSet != oldValue {
                let cell = tableView.cellForRowAtIndexPath(selectedSet)
                cell?.accessoryType = .Checkmark
            }
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        view.addSubview(baseView)
        self.layoutTableView()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func layoutTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        baseView.translatesAutoresizingMaskIntoConstraints = false
        
        let basePin = NSLayoutConstraint(item: baseView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0)
        let baseWidth = NSLayoutConstraint(item: baseView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0)
        let baseHeight = NSLayoutConstraint(item: baseView, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 1/12, constant: 0)
        
        let tvWidth = NSLayoutConstraint(item: tableView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0)
        let topPin = NSLayoutConstraint(item: tableView, attribute: .Top, relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0)
        let bottomPin = NSLayoutConstraint(item: tableView, attribute: .Bottom, relatedBy: .Equal, toItem: baseView, attribute: .Top, multiplier: 1, constant: 0)
        
        let constraints = [basePin, baseWidth, baseHeight, tvWidth, topPin, bottomPin]
        
        self.view.addConstraints(constraints)
        
    }

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Change Symbol Set"
        case 1:
            return "New Puzzle"
         default:
            return "Give Up"
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 3
        case 1:
            return 4
        default:
            return 1
            
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
       
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Standard: 1-9"
                cell.accessoryType = .Checkmark
            case 1:
                cell.textLabel?.text = "Critters:🐥-🐌"
            default:
                cell.textLabel?.text = "Flags:🇨🇭-🇲🇽"
            }
        default:
            break
        }
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            print("cell selected")
            selectedSet = indexPath
        }
        
    }
    
    
}

