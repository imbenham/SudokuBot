//
//  ViewController.swift
//  SudokuCheat
//
//  Created by Isaac Benham on 4/14/15.
//  Copyright (c) 2015 Isaac Benham. All rights reserved.
//

import UIKit
import iAd

extension UINavigationController {
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if let presented = self.topViewController {
            return presented.supportedInterfaceOrientations()
        } else {
            return .AllButUpsideDown
        }
    }
}


class SudokuController: UIViewController, NumPadDelegate {
    
    var startingNils: [Tile] = []
    var givens: [Tile] = []
    var board: SudokuBoard
    var numPad: SudokuNumberPad
    var storedTime: Double = 0
    
    
    var inactivateInterface: (()->())!
    var activateInterface: (()->())!

    var bannerView: ADBannerView {
        get {
            let delegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            if let bv = delegate.banner {
                return bv
            }
            
            delegate.banner = ADBannerView(adType: .Banner)
            delegate.banner?.delegate = delegate
            return delegate.banner!
        }
        
    }
    var bannerPin: NSLayoutConstraint?
    var bannerLayoutComplete = false
    var longFetchLabel = UILabel()
    let containerView = UIView(tag: 4)
    var selectedTile: Tile? {
        didSet {
            if let theTile = selectedTile {
                if !theTile.selected {
                    theTile.selected = true
                }
            }
            
            if let old = oldValue {
                if old != selectedTile {
                    if old.selected != false {
                        old.selected = false
                    }
                }
            }
            
            refreshNoteButton()
        }
    }
    
    
    var puzzle: Puzzle?
    
    var tiles: [Tile] {
        get {
            var mutableTiles = [Tile]()
            let boxList = self.board.boxes as! [Box]
            for box in boxList {
                let containedTiles = box.boxes as! [Tile]
                mutableTiles.appendContentsOf(containedTiles)
            }
            return mutableTiles
        }
    }
    
    var nilTiles: [Tile] {
        get {
            return tiles.filter({$0.value == .Nil})
        }
    }
    
    var nonNilTiles: [Tile] {
        get {
           
            return tiles.filter({$0.value != .Nil})
        }
    }
    
    var difficulty: PuzzleDifficulty = .Custom(150)
    
    var numPadHeight: CGFloat {
        get {
            return self.board.frame.size.width * 1/9
        }
    }
    
    var  wrongTiles: [Tile] {
        var wrong: [Tile] = []
        for tile in nonNilTiles {
            if let correct = tile.solutionValue {
                if correct != tile.value.rawValue {
                    wrong.append(tile)
                }
            }
        }
        return wrong
    }
    
    var annotatedTiles: [Tile] {
        return nilTiles.filter({$0.noteValues.count > 0})
    }
    
    var discoveredTiles: [Tile] {
        return nonNilTiles.filter({$0.discovered})
    }
    
    func tileWithBackingCell(cell: PuzzleCell) -> Tile {
        let row = cell.row
        let column = cell.column
        let tI = getTileIndexForRow(row, andColumn: column)
        return board.tileAtIndex(tI)
    }
    
    
    let spinner: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    
    required init?(coder aDecoder: NSCoder) {
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
        longFetchLabel.hidden = true
        longFetchLabel.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        board.addSubview(longFetchLabel)
        setUpBoard()
        setUpButtons()
        
        if self.canDisplayBannerAds  && !bannerLayoutComplete {
            view.addSubview(bannerView)
            
            bannerView.translatesAutoresizingMaskIntoConstraints = false
            
            originalContentView.removeConstraints()
            originalContentView.translatesAutoresizingMaskIntoConstraints = false
            
            
            bannerPin = NSLayoutConstraint(item: bannerView, attribute: .Top, relatedBy: .Equal, toItem: bottomLayoutGuide, attribute: .Top, multiplier: 1, constant: 0)
            bannerPin!.priority = 1000
            let bannerLeft = NSLayoutConstraint(item: bannerView, attribute: .Leading, relatedBy: .Equal, toItem:view, attribute: .Leading, multiplier: 1, constant: 0)
            let bannerRight = NSLayoutConstraint(item: bannerView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0)
            
            
            let contentBottom = NSLayoutConstraint(item: originalContentView, attribute: .Bottom, relatedBy: .Equal, toItem: bannerView, attribute: .Top, multiplier: 1, constant: 0)
            contentBottom.priority = 1000
            let contentLeft = NSLayoutConstraint(item: originalContentView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0)
            let contentRight = NSLayoutConstraint(item: originalContentView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0)
            let contentTop = NSLayoutConstraint(item: originalContentView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0)
            view.addConstraints([contentBottom, contentLeft, contentRight, contentTop, bannerPin!, bannerLeft, bannerRight])
            
            bannerLayoutComplete = true
            
            board.removeConstraints()
            setUpBoard()
            containerView.removeConstraints()
            setUpButtons()
            
        }
        
        longFetchLabel.layer.backgroundColor = UIColor.blackColor().CGColor
        longFetchLabel.textColor = UIColor.whiteColor()
        longFetchLabel.textAlignment = .Center
        longFetchLabel.numberOfLines = 2
        longFetchLabel.font = UIFont.systemFontOfSize(UIFont.labelFontSize())
        longFetchLabel.adjustsFontSizeToFitWidth = true
        
        longFetchLabel.text = "SudokuBot is cooking up a custom puzzle just for you!  It will be ready in a sec."
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.puzzle != nil && !canDisplayBannerAds {
            canDisplayBannerAds = true
            bannerView.userInteractionEnabled = true
        }

        activateInterface()
        
        // register to receive notifications when user defaults change
        NSUserDefaults.standardUserDefaults().addObserver(self, forKeyPath: symbolSetKey, options: .New, context: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let selected = selectedTile  {
            if selected.symbolSet != .Standard {
                selected.noteMode = false
            }
        }
       
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if canDisplayBannerAds {
            let delegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            delegate.banner = nil
            canDisplayBannerAds = false
            bannerLayoutComplete = false
            layoutAnimated(false)
        }
       
    }
    
   
    func wakeFromBackground() {
        
    }
    
    
    func goToBackground() {
        inactivateInterface()
        
        if canDisplayBannerAds {
            bannerView.removeFromSuperview()
            canDisplayBannerAds = false
            bannerLayoutComplete = false
            layoutAnimated(false)
        }
    }
    
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    
   override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let path = keyPath {
            if path == symbolSetKey {
                numPad.refreshButtonText()
                for tile in tiles {
                    tile.refreshLabel()
                }

            }
        }
    }
    
   deinit {

        NSUserDefaults.standardUserDefaults().removeObserver(self, forKeyPath: symbolSetKey)
    
    }
    
    func setUpBoard() {
        
        board.translatesAutoresizingMaskIntoConstraints = false
        numPad.translatesAutoresizingMaskIntoConstraints = false
        spinner.translatesAutoresizingMaskIntoConstraints = false
        longFetchLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let topPin = NSLayoutConstraint(item: board, attribute: .Top, relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 10)
        let centerPin = NSLayoutConstraint(item: board, attribute: .CenterX, relatedBy: .Equal, toItem: originalContentView, attribute: .CenterX, multiplier: 1, constant: 0)
        let boardWidth = NSLayoutConstraint(item: board, attribute: .Width, relatedBy: .Equal, toItem: originalContentView, attribute: .Width, multiplier: 0.95, constant: 0)
        let boardHeight = NSLayoutConstraint(item: board, attribute: .Height, relatedBy: .Equal, toItem: board, attribute: .Width, multiplier: 1, constant: 0)
        
        let constraints = [topPin, centerPin, boardWidth, boardHeight]
        originalContentView.addConstraints(constraints)
       
        
        let numPadWidth = NSLayoutConstraint(item: numPad, attribute: .Width, relatedBy: .Equal, toItem: board, attribute: .Width, multiplier: 1, constant: 0)
        let numPadHeight = NSLayoutConstraint(item: numPad, attribute: .Height, relatedBy: .Equal, toItem: board, attribute: .Width, multiplier: 1/9, constant: 0)
        let numPadCenterX = NSLayoutConstraint(item: numPad, attribute: .CenterX, relatedBy: .Equal, toItem: board, attribute: .CenterX, multiplier: 1, constant: 0)
        let numPadTopSpace = NSLayoutConstraint(item: numPad, attribute: .Top, relatedBy: .Equal, toItem: board, attribute: .Bottom, multiplier: 1, constant: 8)
        let spinnerHor = NSLayoutConstraint(item: spinner, attribute: .CenterX, relatedBy: .Equal, toItem: board, attribute: .CenterX, multiplier: 1, constant: 0)
        let spinnerVert = NSLayoutConstraint(item: spinner, attribute: .CenterY, relatedBy: .Equal, toItem: board, attribute: .CenterY, multiplier: 1, constant: 0)
        
        originalContentView.addConstraints([numPadWidth, numPadHeight, numPadCenterX, numPadTopSpace, spinnerHor, spinnerVert])


        
        board.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 1, alpha: 1)
        
        
    }
    
    func setUpButtons() {
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
        
    }
    
    
    func tileAtIndex(_index: TileIndex) -> Tile {
        return board.getBoxAtIndex(_index.0).getTileAtIndex(_index.1)
    }
    
    
    // puzzle fetching
    func fetchPuzzle() {
        
        bannerView.userInteractionEnabled = false
       
        UIView.animateWithDuration(0.25) {
            self.navigationController?.navigationBarHidden = true
            self.inactivateInterface()
        }
        
        board.userInteractionEnabled = false
        let firstTile = board.tileAtIndex((1,1))
        let placeHolderColor = firstTile.selectedColor
        let middleTile = board.tileAtIndex((5,4))
        if !spinner.isAnimating() {
            middleTile.selectedColor = UIColor.blackColor()
            selectedTile = middleTile
            spinner.startAnimating()
        }
        let handler: ((Puzzle,[String:Any]?) -> ()) = {
            puzz, dict -> () in
            dispatch_async(GlobalMainQueue){
                self.spinner.stopAnimating()
                middleTile.selectedColor = placeHolderColor
                self.puzzle = puzz
                self.startingNils = []
                self.givens = []
                for cell in puzz.solution {
                    let tIndex = getTileIndexForRow(cell.row, andColumn: cell.column)
                    let tile = self.board.tileAtIndex(tIndex)
                    tile.backingCell = cell
                    tile.solutionValue = cell.value
                    self.startingNils.append(tile)
                }
                for cell in puzz.initialValues {
                    let tIndex = getTileIndexForRow(cell.row, andColumn: cell.column)
                    let tile = self.board.tileAtIndex(tIndex)
                    tile.backingCell = cell
                    tile.value = TileValue(rawValue: cell.value)!
                    self.givens.append(tile)
                    
                }
                self.board.userInteractionEnabled = true
                UIView.animateWithDuration(0.25) {
                    self.navigationController?.navigationBarHidden = false
                    self.longFetchLabel.hidden = true
                }
                
                if let assignedCells = dict?["progress"] as? [PuzzleCell] {
                    for cell in assignedCells {
                        let tile = self.tileWithBackingCell(cell)
                        tile.backingCell = cell
                        tile.value = TileValue(rawValue: cell.value)!
                    }
                }
                
                if let annotatedDict = dict?["annotated"] as? [NSDictionary]  {
                    for dict in annotatedDict {
                        let cell = PuzzleCell(dict: (dict["cell"] as! [String: Int]))!
                        let notes:[TileValue] = (dict["notes"] as! [Int]).map({TileValue(rawValue: $0)!})
                        let tile = self.tileWithBackingCell(cell)
                        tile.noteValues = notes
                        tile.refreshLabel()
                    }
                }

                
                if let discoveredCells = dict?["discovered"] as? [PuzzleCell] {
                    for cell in discoveredCells {
                        let tile = self.tileWithBackingCell(cell)
                        tile.discovered = true
                    }
                }
                
                if let time = dict?["time"] as? Double {
                    self.storedTime = time
                }

                
                self.puzzleReady()
            }
        }
        
        PuzzleStore.sharedInstance.getPuzzleForController(self, withCompletionHandler: handler)
    }

    
    
    func replayCurrent() {
        if puzzle == nil {
            return
        }
        
        UIView.animateWithDuration(0.5) {
            for tile in self.startingNils {
                tile.value = TileValue.Nil
                if tile.solutionValue == nil {
                    tile.solutionValue = tile.backingCell.value
                    tile.userInteractionEnabled = true
                }
            }
        }
        
        for tile in self.givens {
            tile.userInteractionEnabled = false
        }
    }
    
    // Board tile selected handler
    func boardSelectedTileChanged() {
        numPad.refresh()
    }
    
    func boardReady() {
        
    }
    
    func puzzleReady() {
        activateInterface()
        if !canDisplayBannerAds {
            bannerView.userInteractionEnabled = true
            bannerLayoutComplete = false
            canDisplayBannerAds = true
        }

        if nilTiles.count > 0 {
            selectedTile = nilTiles[0]
        }
        
    }
    
    
    // NumPadDelegate methods
    func valueSelected(value: Int) {
        if let selected = selectedTile {
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
    
    func noteValueChanged(value: Int) {
        if let selected = selectedTile {
            let tv = TileValue(rawValue: value)!
            if selected.noteValues.contains(tv) {
                selected.removeNoteValue(tv)
            } else {
                selected.addNoteValue(tv)
            }
        }
    }
    
    func currentValue() -> Int? {
        if selectedTile?.noteMode == true {
            return nil
        }
        if let sel = selectedTile {
           let val = sel.value.rawValue
            if val == 0 {
                return nil
            }
            return val
        }
        return nil
    }
    
    func noteValues() -> [Int]? {
        let selected = selectedTile
        if selected == nil {
            return nil
        }
        if selected?.noteMode == false {
            return nil
        } else {
            var vals:[Int] = []
            for tv in selected!.noteValues {
                vals.append(tv.rawValue)
            }
            return vals
        }
    }
    
    func noteMode() -> Bool {
        if let selected = selectedTile {
            return selected.noteMode
        }
        
        return false
    }
    
    // banner view delegate
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {

        layoutAnimated(true)
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {

        layoutAnimated(true)
    }
    
    
    func layoutAnimated(animated: Bool) {
        
        if !canDisplayBannerAds {
            if bannerPin?.constant != 0 {
                view.layoutIfNeeded()
                UIView.animateWithDuration(0.25) {
                    self.bannerPin?.constant = 0
                    self.view.layoutIfNeeded()
                }
            }
            return
        }
        
        if bannerView.bannerLoaded  {
            if bannerPin?.constant == 0 {
                view.layoutIfNeeded()
                UIView.animateWithDuration(0.25) {
                    self.bannerPin?.constant = -self.bannerView.frame.size.height
                    self.view.layoutIfNeeded()
                }
            }
        } else {
            if bannerPin?.constant != 0 {
                view.layoutIfNeeded()
                UIView.animateWithDuration(0.25) {
                    self.bannerPin?.constant = 0
                    self.view.layoutIfNeeded()
                }

            }

        }
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        if banner.bannerLoaded {
            return true
        } else {
            activateInterface()
            layoutAnimated(true)
            return false
        }
    }
    
    // user input handlers 
    
    func tileTapped(sender: AnyObject) {
        if let tile = (sender as! UIGestureRecognizer).view as? Tile {
            if tile != selectedTile {
                selectedTile?.selected = false
                tile.selected = !tile.selected
                selectedTile = tile
            }
            numPad.refresh()
        }
    }
    
    func toggleNoteMode(sender: AnyObject) {
        
    }
    
    func refreshNoteButton() {
        
    }
    
}

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
        saveButton.addTarget(self, action: Selector("saveAndDismiss"), forControlEvents: .TouchUpInside)
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

