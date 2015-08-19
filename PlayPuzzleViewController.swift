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
    
   
    let clearButton: UIButton = UIButton(tag: 0)
    var hintButton: UIButton = UIButton(tag: 1)
    let optionsButton: UIButton = UIButton(tag: 2)
    let playAgainButton: UIButton = UIButton(tag: 3)
    var containerWidth: NSLayoutConstraint!
    var containerHeight: NSLayoutConstraint!
    //var labelColor = UIColor.blackColor()
    var containerSubviews: (front: UIView, back: UIView)!
   
    
    var timed: Bool {
        get {
            let defaults = NSUserDefaults.standardUserDefaults()
            return defaults.boolForKey("timed")
        }
    }
    
    private var timer: NSTimer?
    private let formatter = NSDateFormatter()
    
    private var timeElapsed: Double = 0
    
    override func viewDidLoad() {
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
            
            self.optionsButton.enabled = false
            self.clearButton.enabled = false
            self.containerView.userInteractionEnabled = false
            self.board.userInteractionEnabled = false
            
           UIView.animateWithDuration(0.25) {
                self.optionsButton.alpha = 0.5
                self.clearButton.alpha = 0.5
                self.containerSubviews.front.alpha = 0.5
                self.containerSubviews.back.alpha = 0
            }
          

        }
        
        activateInterface = {
            let gameOver = self.containerSubviews.front == self.playAgainButton
            if self.timed {
                if let theTimer = self.timer  {
                    if !theTimer.valid && !gameOver {
                        self.restartTimer()
                    }
                } else {
                    let timerInfo = ["start": CACurrentMediaTime()]
                    self.timer = NSTimer(timeInterval: 1.0, target: self, selector: Selector("timerFiredMethod:"), userInfo: timerInfo, repeats: true)
                    self.timer!.tolerance = 0.25
                    let loop = NSRunLoop.currentRunLoop()
                    loop.addTimer(self.timer!, forMode: NSDefaultRunLoopMode)
                }
            } else {
                self.timer?.invalidate()
                self.navigationItem.title = ""
            }
            
            
            var animations: () -> ()
            if !gameOver {
                self.optionsButton.enabled = true
                self.clearButton.enabled = true
                animations = {
                    self.optionsButton.alpha = 1.0
                    self.clearButton.alpha = 1.0
                    self.containerSubviews.front.alpha = 1.0
                    self.containerSubviews.back.alpha = 0
                }
            } else {
                animations = {
                    self.containerSubviews.front.alpha = 1.0
                }
            }
           
            self.containerView.userInteractionEnabled = true
            self.board.userInteractionEnabled = true
            
            UIView.animateWithDuration(0.25, animations: animations)
        }
       
        containerView.addSubview(hintButton)
        containerView.addSubview(playAgainButton)
        playAgainButton.alpha = 0
        containerView.bringSubviewToFront(hintButton)
        containerView.contentMode = .Center
        hintButton.contentMode = .ScaleToFill
        playAgainButton.contentMode = .ScaleToFill
        containerView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if self.puzzle == nil {
            fetchPuzzle()
        }
        
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        inactivateInterface()
    }
   
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        containerView.backgroundColor = UIColor.clearColor()
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = containerView.frame.size.height/2
        containerView.layer.borderWidth = 2.0
        
        configureButtons()
        
        let nestedButtons = [hintButton, playAgainButton]
        
        for button in nestedButtons {
            button.frame = containerView.bounds
        }
        
        if canDisplayBannerAds {
            layoutAnimated(true)
        }
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
    }
    
    
    override func setUpButtons() {
        let buttons:[UIView] = [clearButton, containerView, optionsButton]
        
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
                button.layer.borderWidth = 2.0
            }
            
        }
        
        
    }
    
    func configureButtons() {
        for button in [clearButton, optionsButton, hintButton, playAgainButton] {
            let tag = button.tag
            let buttonInfo = buttonInfoForTag(tag)
            
            let titleColor = tag == 3 ? UIColor.whiteColor() : UIColor.blackColor()
            button.setTitleColor(titleColor, forState: .Normal)
            button.setTitle(buttonInfo.title, forState: .Normal)
            button.addTarget(self, action: Selector(buttonInfo.action), forControlEvents: .TouchUpInside)
            let bgColor = tag == 3 ? UIColor.blackColor() : UIColor.whiteColor()
            button.backgroundColor = bgColor
            
            if tag == 2 || tag == 0 {
                button.layer.cornerRadius = 5.0
                button.layer.borderColor = UIColor.blackColor().CGColor
                button.layer.borderWidth = 2.0
            } else {
                button.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            }
        }
        
        playAgainButton.titleLabel?.adjustsFontSizeToFitWidth = false
        playAgainButton.titleLabel?.numberOfLines = 0
        playAgainButton.titleLabel?.textAlignment = .Center
        containerView.layer.borderColor = hintButton == containerSubviews.front ? UIColor.blackColor().CGColor : UIColor.whiteColor().CGColor
    }
    
    func switchButton() {
        
        var animations: () -> ()
        var options: UIViewAnimationOptions
        let front = self.containerSubviews.front
        let back = self.containerSubviews.back
        
        
        
        
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
    
    }
    
    private func buttonInfoForTag(tag: Int) -> (title: String, action: String) {
        switch tag {
        case 0:
            return ("Clear", "clearSolution")
        case 1:
            return ("?", "showHelpMenu:")
        case 2:
            return ("Options", "showOptions:")
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
            board.selectedTile = startingNils[0]
        }
        
        
        for tile in startingNils {
            tile.userInteractionEnabled = true
        }
        
        if hintButton == containerSubviews.back {
            switchButton()
        }
        
        navigationItem.title = timed ? "00:00" : ""
        timeElapsed = 0
        
        super.puzzleReady()
    }
    
    func clearSolution() {
        let nils = self.startingNils
        
        for tile in nils {
            tile.value = .Nil
            tile.labelColor = tile.defaultTextColor
        }
        
        numPad.refresh()
    }
    
    
    func clearAll() {
        
        let tiles = self.tiles
        for tile in tiles {
            tile.value = .Nil
            tile.solutionValue = nil
            tile.labelColor = tile.defaultTextColor
        }
        
        startingNils = []

    }
    
    func showHint() {
        
        // pull a value from the puzzle solution and animate it onto the board
        let nils = nilTiles
        let nilsCount = nils.count
        
        let wrongs = wrongTiles
        let wrongsCount = wrongs.count
        
        
        
        if nilsCount < 2 && wrongsCount == 0 {
            let alert = UIAlertView(title: "Try harder.", message: "I think you can do this...", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        
        
        let tile = wrongsCount > 0 ? wrongs[0] : nils[Int(arc4random_uniform((UInt32(nils.count))))]
       
        animateSuppliedTile(tile)
        
        tile.userInteractionEnabled = false
        tile.solutionValue = nil
    }
    
    func animateSuppliedTile(tile: Tile, wrong:Bool = false, delay: Double = 0, handler: (()->Void)? = nil) {
        
        let lastSelected = board.selectedTile
        
        board.selectedTile = nil
        
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
                        tile.backgroundColor = wrong ? tile.wrongColor : tile.defaultBackgroundColor
                        tile.labelColor = wrong ? tile.defaultTextColor : tile.chosenTextColor
                        tile.valueLabel.textColor = tile.labelColor
                    }
                    
                    if finished {
                        let nils = self.nilTiles
                        let nilsCount = nils.count
                        let toSelect:Tile? = nilsCount > 0 ? nils[0] : nil
                        self.board.selectedTile = lastSelected?.value == .Nil ? lastSelected : toSelect
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
                self.animateSuppliedTile(wrongTile, wrong: true)
                wrongTile.userInteractionEnabled = false
            }
            self.switchButton()
        }
       
        for nilTile in nilTiles {
            if lastTile == nil {
                animateSuppliedTile(nilTile, handler: completion)
                
            } else {
                if nilTile == lastTile {
                    animateSuppliedTile(nilTile, handler: completion)
                    
                } else {
                    animateSuppliedTile(nilTile)
                }
            }

        }
        
    }
    
    func showOptions(sender: AnyObject) {
      
        let optionSheet = self.storyboard!.instantiateViewControllerWithIdentifier("options") as! PuzzleOptionsViewController
        optionSheet.modalTransitionStyle = .FlipHorizontal
        optionSheet.timedStatus = timed
        self.presentViewController(optionSheet, animated: true, completion: nil)
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
            let current = Matrix.sharedInstance.getRawDifficultyForPuzzle(difficulty)
            let min = Matrix.sharedInstance.getRawDifficultyForPuzzle(.Easy)
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
        
        let alertController = UIAlertController(title: "Puzzle Solved", message: "Well done!", preferredStyle: .Alert)
        
        let newPuzz = UIAlertAction(title: "Play Again!", style: .Default) {(_) in
            self.clearAll()
            self.fetchPuzzle()
        }
        
        alertController.addAction(newPuzz)
        
        
        if difficulty != .Insane {
            let current = Matrix.sharedInstance.getRawDifficultyForPuzzle(difficulty)
            let max = Matrix.sharedInstance.getRawDifficultyForPuzzle(.Insane)
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
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    
    // Timer handlers
    
    func timerFiredMethod(timer: NSTimer) {
        
        let start = (timer.userInfo as! [String: CFTimeInterval])["start"]
        let elapsed = CACurrentMediaTime() - start!
        timeElapsed = elapsed
        
        let overAnHour = elapsed >= 3600
        
        formatter.dateFormat = overAnHour ? "h:mm:ss" : "mm:ss"
        let dateString = overAnHour ? "0:00:00" : "00:00"
            
        
        let zeroDate = formatter.dateFromString(dateString)
        let endDate = zeroDate?.dateByAddingTimeInterval(elapsed)
        
        
        let timeString = formatter.stringFromDate(endDate!)
        
        navigationItem.title = timeString
        
    }
    
    func restartTimer() {
        let startFrom = CACurrentMediaTime() - timeElapsed
        let timerInfo = ["start": startFrom]
        
        timer = NSTimer(timeInterval: 1.0, target: self, selector: Selector("timerFiredMethod:"), userInfo: timerInfo, repeats: true)
        
        let loop = NSRunLoop.currentRunLoop()
        loop.addTimer(timer!, forMode: NSDefaultRunLoopMode)
    }
    
    // banner delegate overrides
    
    override func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        inactivateInterface()
        return super.bannerViewActionShouldBegin(banner, willLeaveApplication: willLeave)
    }
    
    
    override func layoutAnimated(animated: Bool) {
        super.layoutAnimated(true)
        //configureButtons()
    }
    
    func bannerViewActionDidFinish(banner: ADBannerView!) {
        activateInterface()

    }
    
}