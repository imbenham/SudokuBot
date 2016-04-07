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
            
            for box in self.board.boxes {
                let containedTiles = box.boxes
                mutableTiles.appendContentsOf(containedTiles)
            }
            return mutableTiles
        }
    }
    
    var nilTiles: [Tile] {
        get {
            return tiles.filter({$0.displayValue == .Nil})
        }
    }
    
    var nonNilTiles: [Tile] {
        get {
           
            return tiles.filter({$0.displayValue != .Nil})
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
                if correct != tile.displayValue.rawValue {
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
        return nonNilTiles.filter({$0.revealed})
    }
    
    func tileWithBackingCell(cell: BackingCell) -> Tile {
        let row = cell.row
        let column = cell.column
        let tI = getTileIndex(0, row: row, column: column)
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
        longFetchLabel.layer.zPosition = 1
        spinner.layer.zPosition = 1
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
        activateInterface()
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
    
    func prepareForLongFetch() {
        
        
        UIView.animateWithDuration(0.35) {
            self.navigationController?.navigationBarHidden = true
            self.inactivateInterface()
            self.longFetchLabel.hidden = false
            self.longFetchLabel.frame = CGRectMake(0, 0, self.board.frame.width, self.board.frame.height * 0.25)
        }
        
        
      
        
        let middleTile = board.tileAtIndex((0,5,4))
        if !spinner.isAnimating() {
            middleTile.selectedColor = UIColor.blackColor()
            selectedTile = middleTile
            spinner.startAnimating()
        }


    }
    
    // puzzle fetching
    func fetchPuzzle() {
     
       
        bannerView.userInteractionEnabled = false
        board.userInteractionEnabled = false
        
        let placeHolderColor = board.tileAtIndex((0,1,1)).selectedColor
        let middleTile = board.tileAtIndex((0,5,4))
        
        let handler: (Puzzle -> ()) = {
            puzzle -> () in
            self.spinner.stopAnimating()
            middleTile.selectedColor = placeHolderColor
            
            self.puzzle = puzzle
            
            for cell in self.puzzle!.solution {
                let tile = self.board.tileAtIndex((cell.convertToTileIndex()))
                tile.backingCell = cell
                
            }
            for cell in self.puzzle!.initialValues{
                let tile = self.board.tileAtIndex(cell.convertToTileIndex())
                tile.backingCell = cell
                
            }
            
            self.board.userInteractionEnabled = true
            UIView.animateWithDuration(0.35) {
                self.navigationController?.navigationBarHidden = false
                self.longFetchLabel.hidden = true
            }
            
            
            /*
             if let time = dict?["time"] as? Double {
             self.storedTime = time
             }
             */
            
            self.puzzleReady()

        }
        
        PuzzleStore.sharedInstance.getPuzzleForController(self, withCompletionHandler: handler)
    }

    
    
    func replayCurrent() {
        if puzzle == nil {
            return
        }
        
        
        UIView.animateWithDuration(0.5) {
            for tile in self.startingNils {
                tile.userInteractionEnabled = true
                tile.setValue(0)
            }
        }
        
        
        
        for tile in givens {
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
            if selected.displayValue.rawValue == value {
                selected.setValue(0)
            } else {
                selected.setValue(value)
            }
        }
        numPad.refresh()
    }
    
    func noteValueChanged(value: Int) {
        if let selected = selectedTile {
            if selected.noteValues.contains(value) {
                selected.removeNoteValue(value)
            } else {
                selected.addNoteValue(value)
            }
        }
    }
    
    func currentValue() -> Int? {
        if selectedTile?.noteMode == true {
            return nil
        }
        if let sel = selectedTile {
           let val = sel.displayValue.rawValue
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
            return selected?.noteValues
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


