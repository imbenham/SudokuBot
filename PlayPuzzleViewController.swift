//
//  PlayPuzzleViewController.swift
//  SudokuCheat
//
//  Created by Isaac Benham on 5/25/15.
//  Copyright (c) 2015 Isaac Benham. All rights reserved.
//

import Foundation
import iAd


class PlayPuzzleViewController: SudokuController {
    
   
    var clearButton: UIButton?
    var hintButton: UIButton = UIButton(tag: 1)
    let optionsButton: UIButton = UIButton(tag: 2)
    let playAgainButton: UIButton = UIButton(tag: 3)
    var noteButton: UIButton?
    var containerWidth: NSLayoutConstraint!
    var containerHeight: NSLayoutConstraint!
    var containerSubviews: (front: UIView, back: UIView)!
    
    var timed: Bool {
        get {
            let defaults = NSUserDefaults.standardUserDefaults()
            return defaults.boolForKey("timed")
        }
    }
    
    var timeElapsed: Double = 0
    private var timer: NSTimer?
    private let formatter = NSDateFormatter()
    
    struct Token {
        static var onceToken: dispatch_once_t = 0
    }
    
    class var token:dispatch_once_t {
        get {
        return Token.onceToken
        }
        set {
            Token.onceToken = newValue
        }
    }

    override func wakeFromBackground() {
        if puzzle == nil {
            let defaults = NSUserDefaults.standardUserDefaults()
            if let currentPuzzleData = defaults.objectForKey(currentPuzzleKey) as? NSData {
                let puzz = NSKeyedUnarchiver.unarchiveObjectWithData(currentPuzzleData) as! Puzzle
                puzzle = puzz
            }
        }
        
        activateInterface()
        
        if self.puzzle != nil && !canDisplayBannerAds {
            bannerLayoutComplete = false
            canDisplayBannerAds = true
        }
    }
    
    func showButtons(sender: AnyObject) {
        if iPhone4 {
            board.userInteractionEnabled = false
            containerView.userInteractionEnabled = false
            //board.alpha = 0.5
            if let theTimer = self.timer {
                theTimer.invalidate()
            }
            UIView.animateWithDuration(0.5) {
                self.hintButton.hidden = false
                self.optionsButton.hidden = false
            }
            
            optionsButton.userInteractionEnabled = true
            
        }
    }
    
    func hideButtons() {
        if iPhone4 {
            UIView.animateWithDuration(0.5) {
                self.hintButton.hidden = true
                self.optionsButton.hidden = true
                self.board.alpha = 1
            }
            board.userInteractionEnabled = true
           
        }
    }
    
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == UIEventSubtype.MotionShake {
            clearSolution()
        }
    }
    
    override func viewDidLoad() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(PlayPuzzleViewController.hideButtons))
        self.originalContentView.addGestureRecognizer(tapRecognizer)
        
        if iPhone4 {
            let bbItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(PlayPuzzleViewController.showButtons(_:)))
            self.navigationItem.rightBarButtonItem = bbItem
            optionsButton.hidden = true
            hintButton.hidden = true
            playAgainButton.hidden = true
        } else {
            noteButton =  UIButton(tag: 5)
            clearButton = UIButton(tag: 0)
        }
        
        containerSubviews = (front: hintButton, back:playAgainButton)
        super.viewDidLoad()
       
        self.originalContentView.backgroundColor = UIColor.orangeColor()
        
        if timed {
            navigationItem.title = "00:00"
        } else {
            navigationItem.title = ""
        }
    
        formatter.dateFormat = "mm:ss"
        
        inactivateInterface =  {
            if let theTimer = self.timer {
                theTimer.invalidate()
            }
            
            if !iPhone4 {
                self.optionsButton.enabled = false
                self.noteButton?.enabled = false
                self.clearButton?.enabled = false
            }
        
            self.board.userInteractionEnabled = false
            
           UIView.animateWithDuration(0.25) {
            if !iPhone4 {
                self.containerView.userInteractionEnabled = false
                self.noteButton?.alpha = 0.5
                self.clearButton?.alpha = 0.5
                self.containerSubviews.front.alpha = 0.5
                self.containerSubviews.back.alpha = 0
                self.optionsButton.alpha = 0.5
            }
            
            }
          

        }
        
        activateInterface = {
            let gameOver = self.nilTiles.count == 0
            if self.timed {
                if let theTimer = self.timer  {
                    if !theTimer.valid && !gameOver {
                        self.restartTimer()
                    }
                } else {
                    let timerInfo = ["start": CACurrentMediaTime()]
                    self.timer = NSTimer(timeInterval: 1.0, target: self, selector: #selector(PlayPuzzleViewController.timerFiredMethod(_:)), userInfo: timerInfo, repeats: true)
                    self.timer!.tolerance = 0.25
                    let loop = NSRunLoop.currentRunLoop()
                    loop.addTimer(self.timer!, forMode: NSDefaultRunLoopMode)
                }
            } else {
                self.timer?.invalidate()
                self.navigationItem.title = ""
            }
            
            
            
            if !iPhone4 {
                if self.containerView.subviews.count == 0  {
                    self.containerView.addSubview(self.hintButton)
                    self.containerView.addSubview(self.playAgainButton)
                    self.playAgainButton.alpha = 0
                    self.containerView.bringSubviewToFront(self.hintButton)
                    self.containerView.contentMode = .Center
                    self.hintButton.contentMode = .ScaleToFill
                    self.playAgainButton.contentMode = .ScaleToFill
                    self.containerView.translatesAutoresizingMaskIntoConstraints = false
                    
                }

                var animations: () -> ()
                if !gameOver {
                    
                    if !self.noteButton!.hidden {
                        self.noteButton!.enabled = true
                    }
                    
                    self.clearButton!.enabled = true
                    
                    
                    animations = {
                        self.optionsButton.alpha = 1.0
                        self.clearButton?.alpha = 1.0
                        if !self.noteButton!.hidden {
                            self.noteButton!.alpha = 1.0
                        }
                        self.containerSubviews.front.alpha = 1.0
                        self.containerSubviews.back.alpha = 0
                    }
                    UIView.animateWithDuration(0.25, animations: animations)
                    
                    
                } else {
                    animations = {
                        self.containerSubviews.front.alpha = 1.0
                    }
                    UIView.animateWithDuration(0.25, animations: animations)

                }
                self.optionsButton.enabled = true
                self.containerView.userInteractionEnabled = true
                self.board.userInteractionEnabled = true
                self.numPad.userInteractionEnabled = true
            } else {
                self.hideButtons()
            }
        
        }
    }
    

    override func viewDidAppear(animated: Bool) {
      
        super.viewDidAppear(animated)
        
        if iPhone4 {
            dispatch_once(&PlayPuzzleViewController.token) {
                
                let instructionAlert = UIAlertController(title: "Tips:", message: "When working with numeric values, long-press on a tile to turn note taking mode on/off for that tile.  Shake your phone to clear the puzzle and start over.  Use the '+' button to change the settings or get help with the puzzle.", preferredStyle: .Alert)
                let dismiss = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                instructionAlert.addAction(dismiss)
                self.presentViewController(instructionAlert, animated: true) { () in
                    
                }
            }

        }
        
        if self.puzzle == nil {
            let middleTile = self.board.tileAtIndex((self.board.index,5,4))
            middleTile.selectedColor = UIColor.blackColor()
            self.selectedTile = middleTile
            
            self.spinner.startAnimating()
            fetchPuzzle()
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !iPhone4 {
            let defaults = NSUserDefaults.standardUserDefaults()
            let symType = defaults.integerForKey(symbolSetKey)
            if symType == 0 {
                noteButton!.hidden = false
            } else {
                noteButton!.hidden = true
            }
        }

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        inactivateInterface()
        
       // let gameOver = self.nilTiles.count == 0
        
        // ADD LOGIC FOR SAVING PUZZLE
       /* if !gameOver {
            if self.navigationController!.viewControllers.indexOf(self) == nil {
                
                if let key = difficulty.currentKey {
                    let defaults = NSUserDefaults.standardUserDefaults()
                    let dictionaryToSave = dictionaryToSaveForController(self)
                    defaults.setObject(dictionaryToSave, forKey: key)
                }
                
            }
        }*/
        
    }
   
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
    
        configureButtons()
        
        if !iPhone4 {
            containerView.backgroundColor = UIColor.clearColor()
            containerView.clipsToBounds = true
            containerView.layer.cornerRadius = containerView.frame.size.height/2
            containerView.layer.borderWidth = 3.0

            
            let nestedButtons = [hintButton, playAgainButton]
            
            for button in nestedButtons {
                button.frame = containerView.bounds
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
    }
    
    
    override func setUpButtons() {
        
        if !iPhone4 {
            let buttons:[UIView] = [clearButton!, containerView, optionsButton]
            
            for viewItem in buttons {
                let tag = viewItem.tag
                
                originalContentView.addSubview(viewItem)
                
                viewItem.translatesAutoresizingMaskIntoConstraints = false
                
                let pinAttribute: NSLayoutAttribute = tag == 0 ? .Leading : .Trailing
                
                let widthMultiplier: CGFloat = tag == 4 ? 1/8 : 1/4
                
                let bottomPinOffset: CGFloat = tag == 4 ? -40 : -8
                
                let bottomPinRelation: NSLayoutRelation = tag == 4 ? .GreaterThanOrEqual : .Equal
                
                
                // lay out the buttons
                
                
                let bottomPin = NSLayoutConstraint(item: viewItem, attribute: .Bottom, relatedBy: bottomPinRelation, toItem: originalContentView, attribute: .Bottom, multiplier: 1, constant: bottomPinOffset)
                bottomPin.priority = 1000
                
                
                var constraints:[NSLayoutConstraint] = []
                
                if tag != 4 {
                    let sidePin =  NSLayoutConstraint(item: viewItem, attribute: pinAttribute, relatedBy: .Equal, toItem: numPad, attribute: pinAttribute, multiplier: 1, constant: 0)
                    let height =  NSLayoutConstraint(item: viewItem, attribute: .Height, relatedBy: .Equal, toItem: numPad, attribute: .Height, multiplier: 1, constant: 0)
                    let width = NSLayoutConstraint(item: viewItem, attribute: .Width, relatedBy: .Equal, toItem: numPad, attribute: .Width, multiplier: widthMultiplier, constant: 0)
                    
                    constraints = [width, height, bottomPin, sidePin]
                    
                }
                
                if tag == 4 {
                    let multiplier = containerSubviews.front == hintButton ? widthMultiplier : widthMultiplier * 2
                    
                    containerHeight = NSLayoutConstraint(item: viewItem, attribute: .Height, relatedBy: .Equal, toItem: numPad, attribute: .Width, multiplier: multiplier, constant: 0)
                    containerHeight.priority = 999
                    containerWidth = NSLayoutConstraint(item: viewItem, attribute: .Width, relatedBy: .Equal, toItem: numPad, attribute: .Width, multiplier: multiplier, constant: 0)
                    containerWidth.priority = 999
                    let topPin = NSLayoutConstraint(item: viewItem, attribute: .Top, relatedBy: .GreaterThanOrEqual, toItem: numPad, attribute: .Bottom, multiplier: 1, constant: 8)
                    topPin.priority = 1000
                    let bottomLimiter = NSLayoutConstraint(item: viewItem, attribute: .Bottom, relatedBy: .LessThanOrEqual, toItem: originalContentView, attribute: .Bottom, multiplier: 1, constant: -5)
                    bottomLimiter.priority = 1000
                    let centerY = NSLayoutConstraint(item: viewItem, attribute: .CenterY, relatedBy: .Equal, toItem: clearButton, attribute: .Top, multiplier: 1, constant: -15)
                    centerY.priority = 500
                    let centerX = NSLayoutConstraint(item: viewItem, attribute: .CenterX, relatedBy: .Equal, toItem: numPad, attribute: .CenterX, multiplier: 1, constant: 0)
                    constraints = [containerWidth, containerHeight, bottomPin, topPin, bottomLimiter, centerX, centerY]
                    
                }
                
                
                originalContentView.addConstraints(constraints)
                
                originalContentView.addSubview(noteButton!)
                noteButton!.translatesAutoresizingMaskIntoConstraints = false
                
                let nbTop =  NSLayoutConstraint(item: noteButton!, attribute: .Top, relatedBy: .Equal, toItem: numPad, attribute: .Bottom, multiplier: 1, constant: 8)
                let nbRightEdge = NSLayoutConstraint(item: noteButton!, attribute: .Trailing, relatedBy: .Equal, toItem: numPad, attribute: .Trailing, multiplier: 1, constant: 0)
                let nbHeight = NSLayoutConstraint(item: noteButton!, attribute: .Height, relatedBy: .Equal, toItem: numPad, attribute: .Height, multiplier: 1, constant: 0)
                let nbWidth = NSLayoutConstraint(item: noteButton!, attribute: .Width, relatedBy: .Equal, toItem: numPad, attribute: .Width, multiplier: 2/9, constant: 0)
                
                originalContentView.addConstraints([nbTop, nbRightEdge, nbHeight, nbWidth])
                
                
                
                // configure the buttons
                
                
                if tag != 4 {
                    let button = viewItem as! UIButton
                    let buttonInfo = buttonInfoForTag(tag)
                    
                    button.setTitleColor(UIColor.blackColor(), forState: .Normal)
                    button.setTitle(buttonInfo.title, forState: .Normal)
                    button.addTarget(self, action: Selector(buttonInfo.action), forControlEvents: .TouchUpInside)
                    
                    let npHeight = self.numPadHeight
                    let buttonRadius:CGFloat = tag == 1 || tag == 3 ? npHeight/2 : 5.0
                    button.layer.cornerRadius = buttonRadius
                    button.layer.borderColor = UIColor.blackColor().CGColor
                    button.layer.borderWidth = 3.0
                }
                
            }
        } else {
            
            let widthMultiplier: CGFloat =  1/4
            
            originalContentView.addSubview(playAgainButton)
            playAgainButton.translatesAutoresizingMaskIntoConstraints = false
            let playAgainCenterX = NSLayoutConstraint(item: playAgainButton, attribute: .CenterX, relatedBy: .Equal, toItem: board, attribute: .CenterX, multiplier: 1, constant: 0)
            let playAgainY = NSLayoutConstraint(item: playAgainButton, attribute: .CenterY, relatedBy: .Equal, toItem: board, attribute: .CenterY, multiplier: 1, constant: 0)
            let playAgainHeight = NSLayoutConstraint(item: playAgainButton, attribute: .Height, relatedBy: .Equal, toItem: numPad, attribute: .Width, multiplier: widthMultiplier, constant: 0)
            let playAgainWidth = NSLayoutConstraint(item: playAgainButton, attribute: .Width, relatedBy: .Equal, toItem: numPad, attribute: .Width, multiplier: widthMultiplier, constant: 0)
        
            
            originalContentView.addSubview(optionsButton)
            optionsButton.translatesAutoresizingMaskIntoConstraints = false
            let optionsCenterX = NSLayoutConstraint(item: optionsButton, attribute: .CenterX, relatedBy: .Equal, toItem: board, attribute: .CenterX, multiplier: 1, constant: 0)
            let optionsY = NSLayoutConstraint(item: optionsButton, attribute: .Top, relatedBy: .Equal, toItem: board, attribute: .CenterY, multiplier: 1, constant: 4)
            let optionsHeight = NSLayoutConstraint(item: optionsButton, attribute: .Height, relatedBy: .Equal, toItem: numPad, attribute: .Width, multiplier: widthMultiplier, constant: 0)
            let optionsWidth = NSLayoutConstraint(item: optionsButton, attribute: .Width, relatedBy: .Equal, toItem: numPad, attribute: .Width, multiplier: widthMultiplier, constant: 0)
            
            originalContentView.addSubview(hintButton)
            hintButton.translatesAutoresizingMaskIntoConstraints = false
            let hintCenterX =  NSLayoutConstraint(item: hintButton, attribute: .CenterX, relatedBy: .Equal, toItem: board, attribute: .CenterX, multiplier: 1, constant: 0)
            let hintY = NSLayoutConstraint(item: hintButton, attribute: .Bottom, relatedBy: .Equal, toItem: board, attribute: .CenterY, multiplier: 1, constant: -4)
            let hintHeight = NSLayoutConstraint(item: hintButton, attribute: .Height, relatedBy: .Equal, toItem: numPad, attribute: .Width, multiplier: widthMultiplier, constant: 0)
            let hintWidth = NSLayoutConstraint(item: hintButton, attribute: .Width, relatedBy: .Equal, toItem: numPad, attribute: .Width, multiplier: widthMultiplier, constant: 0)
            
            originalContentView.addConstraints([playAgainCenterX, playAgainY, optionsCenterX, optionsY, playAgainHeight, playAgainWidth, optionsHeight, optionsWidth, hintCenterX, hintY, hintHeight, hintWidth])
        }
    }
    
    func configureButtons() {
        
        let someButtons = iPhone4 ? [optionsButton, hintButton, playAgainButton] : [clearButton!, optionsButton, hintButton, playAgainButton, noteButton!]
        
        for button in someButtons {
            let tag = button.tag
            let buttonInfo = buttonInfoForTag(tag)
            
            if !iPhone4 {
                let titleColor = tag == 3 ? UIColor.whiteColor() : UIColor.blackColor()
                button.setTitleColor(titleColor, forState: .Normal)
                let bgColor = tag == 3 ? UIColor.blackColor() : UIColor.whiteColor()
                button.backgroundColor = bgColor
                
                if tag == 2 || tag == 0 || tag == 5 {
                    button.layer.cornerRadius = 5.0
                    button.layer.borderColor = UIColor.blackColor().CGColor
                    button.layer.borderWidth = 3.0
                } else {
                    button.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                }

            }
            
            button.setTitle(buttonInfo.title, forState: .Normal)
            button.addTarget(self, action: Selector(buttonInfo.action), forControlEvents: .TouchUpInside)
            
            
        }
        
        
        playAgainButton.titleLabel?.adjustsFontSizeToFitWidth = false
        playAgainButton.titleLabel?.numberOfLines = 0
        playAgainButton.titleLabel?.textAlignment = .Center
        
        if !iPhone4 {
            containerView.layer.borderColor = hintButton == containerSubviews.front ? UIColor.blackColor().CGColor : UIColor.whiteColor().CGColor
        }
        
        if iPhone4 {
            playAgainButton.backgroundColor = UIColor.whiteColor()
            playAgainButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
            playAgainButton.layer.borderColor = UIColor.blackColor().CGColor
            playAgainButton.layer.cornerRadius = playAgainButton.bounds.size.height * 0.5
            playAgainButton.layer.borderWidth = 3.0
          
            
            for button in [optionsButton, hintButton] {
                button.backgroundColor = UIColor.blackColor()
                button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                button.layer.borderColor = UIColor.whiteColor().CGColor
                button.layer.borderWidth = 3.0
                button.layer.cornerRadius = button.bounds.size.height * 0.5
            }
            optionsButton.alpha = 0.9
            hintButton.alpha = 0.9
            playAgainButton.alpha = 0.9
        }
        
    }
    
    override func refreshNoteButton() {
        if !iPhone4 {
            noteButton!.backgroundColor = UIColor.whiteColor()
            noteButton!.layer.borderColor = UIColor.blackColor().CGColor
            noteButton!.setTitleColor(UIColor.blackColor(), forState: .Normal)
            if let selected = selectedTile {
                if selected.noteMode {
                    noteButton!.backgroundColor = UIColor.blackColor()
                    noteButton!.layer.borderColor = UIColor.whiteColor().CGColor
                    noteButton!.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                }
            }

        }
    }
    
    func switchButton() {
        
        if !iPhone4 {
            var animations: () -> ()
            var options: UIViewAnimationOptions
            let front = containerSubviews.front
            let back = containerSubviews.back
            
            if (hintButton == front) {
                animations = { () in
                    
                    front.alpha = 0
                    back.alpha = 1
                    self.containerView.bringSubviewToFront(back)
                    self.view.layoutIfNeeded()
                    self.containerHeight.constant += self.containerView.bounds.size.height
                    self.view.layoutIfNeeded()
                    self.containerWidth.constant += self.containerView.bounds.size.width
                    self.view.layoutIfNeeded()
                    self.containerView.layer.cornerRadius = self.containerView.frame.size.height/2
                    self.containerView.layer.borderColor = UIColor.whiteColor().CGColor
                    
                }
                options = .TransitionFlipFromBottom
            } else {
                animations =  { () in
                    front.alpha = 0
                    back.alpha = 1
                    self.containerView.bringSubviewToFront(back)
                    self.view.layoutIfNeeded()
                    self.containerHeight.constant -= self.containerView.bounds.size.height/2
                    self.view.layoutIfNeeded()
                    self.containerWidth.constant -= self.containerView.bounds.size.width/2
                    self.view.layoutIfNeeded()
                    self.containerView.layer.cornerRadius = self.containerView.frame.size.height/2
                    self.containerView.layer.borderColor = UIColor.blackColor().CGColor
                    
                }
                options = .TransitionFlipFromTop
            }
            
            self.view.layoutIfNeeded()
            UIView.transitionWithView(containerView, duration: 0.2, options: options, animations: animations) { (finished) in
                if finished {
                    self.containerSubviews = (back, front)
                    self.activateInterface()
                }
            }
        } else {
            if playAgainButton.hidden {
                hideButtons()
                UIView.animateWithDuration(0.5) {
                    self.playAgainButton.hidden = false
                    self.playAgainButton.alpha = 0.8
                }
            } else {
                UIView.animateWithDuration(0.5) {
                    self.playAgainButton.hidden = true
                }
            }
        }
    }
    
    private func buttonInfoForTag(tag: Int) -> (title: String, action: String) {
        switch tag {
        case 0:
            return ("Clear", "clearSolution")
        case 1:
            let title = iPhone4 ? "Options" : "?"
            return (title, "showHelpMenu:")
        case 2:
            return ("Settings", "showOptions:")
        case 5:
            return ("Note+", "toggleNoteMode:")
        default:
            return ("Play Again", "playAgain:")
        }
    }
    
    
    override func puzzleReady() {
        for tile in givens {
            tile.userInteractionEnabled = false
            tile.labelColor = UIColor.blackColor()
        }
        
        if startingNils.count != 0 {
           selectedTile = startingNils[0]
        }
        
        
        for tile in startingNils {
            tile.userInteractionEnabled = true
        }
        
        
        if !iPhone4 {
            if hintButton == containerSubviews.back {
                switchButton()
            }
        } else {
            if !playAgainButton.hidden {
                UIView.animateWithDuration(0.5) {
                    self.playAgainButton.hidden = true
                    self.board.alpha = 1.0
                }
                board.userInteractionEnabled = true
            }
        }
        
        
        navigationItem.title = timed ? "00:00" : ""
        timeElapsed = 0
        
         super.puzzleReady()
    }
    
    
    // handler overrides
    
    
    override func toggleNoteMode(sender: AnyObject?) {
        if let press = sender as? UILongPressGestureRecognizer {
            if press.state == .Began {
                if let tile = (sender as! UIGestureRecognizer).view as? Tile {
                    if tile.symbolSet != .Standard {
                        return
                    }
                    if tile != selectedTile {
                        selectedTile?.noteMode = false
                        selectedTile?.selected = false
                        tile.noteMode = true
                        selectedTile = tile
                    } else {
                        tile.noteMode = !tile.noteMode
                    }
                    numPad.refresh()
                }
            }
        } else {
            if let selected = selectedTile {
                if selected.symbolSet != .Standard {
                    return
                }
                let nButton = sender as! UIButton
                let nbBGColor = nButton.backgroundColor
                let nbTextColor = nButton.titleColorForState(.Normal)
                
                nButton.backgroundColor = nbTextColor
                nButton.setTitleColor(nbBGColor, forState: .Normal)
                nButton.layer.borderColor = nbBGColor?.CGColor
                
                selected.noteMode = !selected.noteMode
                numPad.refresh()
            } else {
                return
            }
        }
    }
    
    func clearSolution() {
        
        let alert = UIAlertController(title: "Are you sure?", message: "This will cause all of the values you've entered to be removed and cannot be undone.", preferredStyle: .Alert)
        let oKay = UIAlertAction(title: "Clear", style: .Default) { (_) in
            let nils = self.startingNils
            
            for tile in nils {
                tile.backingCell!.notesArray = []
                tile.noteMode = false
                tile.value = .Nil
                tile.labelColor = tile.defaultTextColor
            }
            
            self.activateInterface()
            self.numPad.refresh()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .Default) {(_) in
            self.activateInterface()
        }
        
        alert.addAction(oKay)
        alert.addAction(cancel)
        
        presentViewController(alert, animated: true) { (_) in
            self.inactivateInterface()
        }
        
    }
    
    
    func clearAll() {
        
        let tiles = self.tiles
        for tile in tiles {
            tile.value = .Nil
            tile.labelColor = tile.defaultTextColor
        }

    }
    
    func showHint() {
        
        // pull a value from the puzzle solution and animate it onto the board
        let nils = nilTiles
        let nilsCount = nils.count
        
        let wrongs = wrongTiles
        let wrongsCount = wrongs.count
        
        if nilsCount < 2 && wrongsCount == 0 {
            let alert = UIAlertController(title: "Try harder.", message: "I think you can do this...", preferredStyle: .Alert)
            
            let oKay =  UIAlertAction(title: "OK", style: .Cancel) {
                (_) in
                self.activateInterface()
            }
            alert.addAction(oKay)
            
            self.presentViewController(alert, animated: true, completion: nil)
            
            return
        }
        
        
        let tile = wrongsCount > 0 ? wrongs[0] : nils[Int(arc4random_uniform((UInt32(nils.count))))]
       
        animateDiscoveredTile(tile)
        
    }
    
    func animateDiscoveredTile(tile: Tile, wrong:Bool = false, delay: Double = 0, handler: (()->Void)? = nil) {
        
        let lastSelected = selectedTile
        
        selectedTile = nil
        
        let label = tile.valueLabel
        
        tile.labelColor = UIColor.whiteColor()
        
        let flickerBlock: () -> Void = { () in
            UIView.setAnimationRepeatCount(1.0)
            label.alpha = 0
            label.alpha = 1
        }
        
        if let tv = tile.solutionValue {
            tile.value = TileValue(rawValue: tv)!
        }
        if wrong {
            tile.backgroundColor = tile.wrongColor
        }
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: [.Repeat, .CurveEaseIn, .Autoreverse], animations: flickerBlock) { (finished) in
            
            if finished {
                let colorBlock: () -> Void = { () in
                    label.alpha = 1
                }
                
                UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: colorBlock) { (finished) in
                    
                    UIView.animateWithDuration(0.5) { () in
                        //tile.backgroundColor = wrong ? tile.wrongColor : tile.defaultBackgroundColor
                        //tile.labelColor = wrong ? tile.defaultTextColor : tile.chosenTextColor
                        //tile.valueLabel.textColor = tile.labelColor
                        tile.revealed = true
                    }
                    
                    if finished {
                        let nils = self.nilTiles
                        let nilsCount = nils.count
                        let toSelect:Tile? = nilsCount > 0 ? nils[0] : nil
                        self.selectedTile = lastSelected?.value == .Nil ? lastSelected : toSelect
                        if let completionHandler = handler {
                            completionHandler()
                        }
                    }
                    
                }
            }
            
        }

    }
    
    func giveUp() {
        
        inactivateInterface()
        var lastTile: Tile?
        if !nilTiles.isEmpty {
            lastTile = nilTiles[nilTiles.count-1]
        }
        
        let completion: (()->()) = {
            for wrongTile in self.wrongTiles {
                self.animateDiscoveredTile(wrongTile, wrong: true)
                wrongTile.userInteractionEnabled = false
            }
            self.switchButton()
            self.board.userInteractionEnabled = false
            self.board.alpha = 1.0
            for tile in self.tiles {
                tile.userInteractionEnabled = false
            }
        }
       
        for nilTile in nilTiles {
            if lastTile == nil {
                animateDiscoveredTile(nilTile, handler: completion)
                
            } else {
                if nilTile == lastTile {
                    animateDiscoveredTile(nilTile, handler: completion)
                    
                } else {
                    animateDiscoveredTile(nilTile)
                }
            }
        }
    }
    
    func showOptions(sender: AnyObject) {
      
        let optionSheet = self.storyboard!.instantiateViewControllerWithIdentifier("options") as! PuzzleOptionsViewController
        optionSheet.modalTransitionStyle = .FlipHorizontal
        optionSheet.timedStatus = timed
        self.presentViewController(optionSheet, animated: true) {
            if let selected = self.selectedTile {
                selected.noteMode = false
            }
        }
    }
    
    func showHelpMenu(sender: AnyObject) {
        inactivateInterface()
        let helpAlert = UIAlertController(title: "Tough, eh?", message: "Request a hint to reveal one cell", preferredStyle: .Alert)
        
        
        let hintPlease = UIAlertAction(title: "Hint, please!", style: .Default) { (_) in
            self.showHint()
            self.activateInterface()
        }
        
        helpAlert.addAction(hintPlease)
        
        let givesUp = UIAlertAction(title: "I give up.", style: .Default) { (_) in
            self.giveUp()
        }
        
        helpAlert.addAction(givesUp)
        
        let cancel =  UIAlertAction(title: "Cancel", style: .Cancel) {
            (_) in
            self.activateInterface()
        }
        
        helpAlert.addAction(cancel)
        
        self.presentViewController(helpAlert, animated: true) {
            () in
            self.inactivateInterface()
        }
    }
    
    func playAgain(sender: AnyObject) {
        
        let puzzleSelectAlert = UIAlertController(title: "New Game", message: "Select a difficulty level, or choose replay puzzle", preferredStyle: .Alert)
        
        let easy = UIAlertAction(title: "Easy", style: UIAlertActionStyle.Default) { (_) in
            self.newPuzzleOfDifficulty(.Easy)
        }
        let medium = UIAlertAction(title: "Medium", style: .Default) { (_) in
            self.newPuzzleOfDifficulty(.Medium)
        }
        let hard = UIAlertAction(title: "Hard", style: .Default) { (_) in
            self.newPuzzleOfDifficulty(.Hard)
        }
        let insane = UIAlertAction(title: "Insane", style: .Default) { (_) in
            self.newPuzzleOfDifficulty(.Insane)
        }
        
        for action in [easy, medium, hard, insane] {
            puzzleSelectAlert.addAction(action)
        }
        
        
        if difficulty != .Easy {
            let pStore = PuzzleStore.sharedInstance
            let current = pStore.getPuzzleDifficulty()
            pStore.setPuzzleDifficulty(.Easy)
            let min = pStore.getPuzzleDifficulty()
            let newLevel = current - 10 < min ? PuzzleDifficulty.Easy : PuzzleDifficulty.Custom(current-10)

            
            let easier = UIAlertAction(title: "Slightly easier", style: .Default) { (_) in
                self.difficulty = newLevel
                self.clearAll()
                self.fetchPuzzle()
            }
            
            puzzleSelectAlert.addAction(easier)
        }
        
        let replay = UIAlertAction(title: "Re-play puzzle", style: .Default) { (_) in
            self.newPuzzleOfDifficulty(self.difficulty, replay: true)
        }
        
        puzzleSelectAlert.addAction(replay)
       
        self.presentViewController(puzzleSelectAlert, animated: true, completion: nil)
    }
    
    func newPuzzleOfDifficulty(difficulty: PuzzleDifficulty, replay:Bool = false) {
        if replay {
            replayCurrent()
            switchButton()
            activateInterface()
            for tile in nilTiles {
                tile.userInteractionEnabled = true
            }

        } else {
            clearAll()
            self.difficulty = difficulty
           
            fetchPuzzle()
        }
    }
    
        
    override func valueSelected(value: Int) {
        super.valueSelected(value)
        if nilTiles.count == 0 {
            checkSolution()
        }
    }
    
    func checkSolution() {

        if nilTiles.count == 0 && wrongTiles.count == 0 {
             puzzleSolved()
        }
    }
    
    func puzzleSolved() {
        
        if let theTimer = timer {
            theTimer.invalidate()
        }
        
        numPad.userInteractionEnabled = false
        
        for tile in tiles {
            tile.userInteractionEnabled = false
            tile.backgroundColor = tile.defaultBackgroundColor
        }
        
        let alertController = UIAlertController(title: "Puzzle Solved", message: "Well done!", preferredStyle: .Alert)
        
        let newPuzz = UIAlertAction(title: "Play Again!", style: .Default) {(_) in
            self.clearAll()
            self.fetchPuzzle()
        }
        
        alertController.addAction(newPuzz)
        
        
        if difficulty != .Insane {
            let pStore = PuzzleStore.sharedInstance
            let current = pStore.getPuzzleDifficulty()
            pStore.setPuzzleDifficulty(.Insane)
            let max = pStore.getPuzzleDifficulty()
            let newLevel = current + 10 > max ? PuzzleDifficulty.Insane : PuzzleDifficulty.Custom(current+10)

            
            let harderPuzz = UIAlertAction(title: "Slightly tougher", style: .Default) { (_) in
                self.difficulty = newLevel
                self.clearAll()
                self.fetchPuzzle()
            }
            alertController.addAction(harderPuzz)
        }
        
        
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (_) in
            self.navigationController!.popViewControllerAnimated(true)
        }
        alertController.addAction(OKAction)
        
        
        let indices = [4,2,6,5,3,1,8,0,7]
        var boxes:[Box] = []
        
        for index in indices {
            let aBox = board.boxes[index]
            boxes.append(aBox)
        }
        
        boxes = boxes.reverse()
        
        func flashBoxAnimationsWithBoxes(boxes: [Box]) {
            var boxes = boxes
            let tiles = boxes[0].boxes
            UIView.animateWithDuration(0.15, animations: {
                for tile in tiles {
                    tile.backgroundColor = tile.assignedBackgroundColor
                }
                }) { finished in
                    boxes.removeAtIndex(0)
                    if finished {
                        UIView.animateWithDuration(0.15, animations: {
                            for tile in tiles {
                                tile.backgroundColor = tile.defaultBackgroundColor
                            }
                        }) { finished in
                            if finished {
                                if boxes.isEmpty {
                                    UIView.animateWithDuration(0.15, animations: {
                                        for tile in self.tiles {
                                            tile.backgroundColor = tile.assignedBackgroundColor
                                        }
                                        }) { finished in
                                            if finished {
                                                self.presentViewController(alertController, animated: true, completion: nil)
                                            }
                                    }
                                
                                } else {
                                    flashBoxAnimationsWithBoxes(boxes)
                                }

                            }
                        }
                    }
            }
        }
        
        flashBoxAnimationsWithBoxes(boxes)
        
        
    }

    
    
    // Timer handlers
    
    func timerFiredMethod(timer: NSTimer) {
        
        let start = (timer.userInfo as! [String: CFTimeInterval])["start"]! //- storedTime
        let elapsed = CACurrentMediaTime() - start
        timeElapsed = elapsed + storedTime
        
        let overAnHour = elapsed >= 3600
        
        formatter.dateFormat = overAnHour ? "h:mm:ss" : "mm:ss"
        let dateString = overAnHour ? "0:00:00" : "00:00"
            
        
        let zeroDate = formatter.dateFromString(dateString)
        let endDate = zeroDate?.dateByAddingTimeInterval(elapsed+storedTime)
        
        
        let timeString = formatter.stringFromDate(endDate!)
        
        navigationItem.title = timeString
        
    }
    
    func restartTimer() {
        let startFrom = CACurrentMediaTime() - timeElapsed
        let timerInfo = ["start": startFrom]
        
        timer = NSTimer(timeInterval: 1.0, target: self, selector: #selector(PlayPuzzleViewController.timerFiredMethod(_:)), userInfo: timerInfo, repeats: true)
        
        let loop = NSRunLoop.currentRunLoop()
        loop.addTimer(timer!, forMode: NSDefaultRunLoopMode)
    }
    
    // banner delegate overrides
    
    override func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        
        let superImp = super.bannerViewActionShouldBegin(banner, willLeaveApplication: willLeave)
        if superImp == true {
            inactivateInterface()
        }
        return superImp
    }
    
    
    
    func bannerViewActionDidFinish(banner: ADBannerView!) {
        activateInterface()

    }
    
}