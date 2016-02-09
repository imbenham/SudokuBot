//
//  SudokuLogic.swift
//  SudokuCheat
//
//  Created by Isaac Benham on 4/17/15.
//  Copyright (c) 2015 Isaac Benham. All rights reserved.
//

import UIKit

class LinkedList<T:Equatable> {
    private var head: LinkedNode<T>
    
    init() {
        head = LinkedNode<T>()
    }

}


protocol LaterallyLinkable {
    typealias T:Equatable
    var lateralHead: LinkedNode<T> {get set}
    func addLateralLink(key: T)
}

extension LaterallyLinkable {
    func addLateralLink(key: T) {
        
        if lateralHead.key == nil {
            lateralHead.key = key
            lateralHead.left = lateralHead
            lateralHead.right = lateralHead
            lateralHead.up = lateralHead
            lateralHead.down = lateralHead
            return
        }
        
        var current = lateralHead.right!
        
        let newLinkBloc = { () in
            let newLink = LinkedNode<T>()
            newLink.key = key
            newLink.left = current
            newLink.right = current.right
            newLink.up = newLink
            newLink.down = newLink
            
            newLink.right!.left = newLink
            current.right = newLink
            
            newLink.latOrder = current.latOrder+1
            
        }
        
        if current.key == lateralHead.key {
            newLinkBloc()
            return
        }
        
        WhileLoop: while current.key != lateralHead.key {
            // print("current key: \(current!.key), current-right key: \(current!.right!.key), head key: \(head.key)")
            if current.right!.key == lateralHead.key! {
                newLinkBloc()
                break WhileLoop
            }
            current = current.right!
        }
        
    }
}

protocol VerticallyLinkable {
    typealias T: Equatable
    var verticalHead: LinkedNode<T> {get set}
    func addVerticalLink(key: T)
}

extension VerticallyLinkable {
    func addVerticalLink(key: T) {
        if verticalHead.key == nil {
            verticalHead.key = key
            verticalHead.down = verticalHead
            verticalHead.up = verticalHead
            verticalHead.left = verticalHead
            verticalHead.right = verticalHead
            return
        }
        
        
        var current = verticalHead.down!
        let newLinkBloc = { () in
            let newLink = LinkedNode<T>()
            newLink.key = key
            newLink.up = current
            newLink.down = current.down
            newLink.left = newLink
            newLink.right = newLink
            
            self.verticalHead.up = newLink
            current.down = newLink
            
            newLink.vertOrder = current.vertOrder+1
        }
        
        if current.key == verticalHead.key {
            newLinkBloc()
            return
        }
        
        WhileLoop: while current.key != verticalHead.key {
            if current.down!.key == verticalHead.key! {
                newLinkBloc()
                break WhileLoop
            }
            current = current.down!
        }
    }

}

protocol TwoDimensionallyLinkable: LaterallyLinkable, VerticallyLinkable {
    typealias T: Equatable
    
    func addLateralLinkFromNode(node: LinkedNode<T>, toNewNode newNode: LinkedNode<T>)
    func addVerticalLinkFromNode(node: LinkedNode<T>, toNewNode newNode: LinkedNode<T>)
    
    
    
}

extension TwoDimensionallyLinkable {
    
    func addLateralLinkFromNode(node: LinkedNode<T>, toNewNode newNode: LinkedNode<T>) {
        newNode.latOrder = node.latOrder+1
        newNode.right = node.right
        newNode.left = node
        node.right = newNode
        var current = newNode.right
        WhileLoop: while current != nil {
            if current!.latOrder == 0 {
                break WhileLoop
            }
            current!.latOrder += 1
            current = current!.down
        }
        node.getLateralHead().left = node.getLateralTail()
    }
    
    func addVerticalLinkFromNode(node: LinkedNode<T>, toNewNode newNode: LinkedNode<T>) {
        newNode.vertOrder = node.vertOrder+1
        newNode.down = node.down
        newNode.up = node
        node.down = newNode
        
        var current = newNode.down
        WhileLoop: while current != nil {
            if current!.vertOrder == 0 {
                break WhileLoop
            }
            current!.vertOrder += 1
            current = current!.down
        }
        node.getVerticalHead().up = node.getVerticalTail()
    }


}

class SudokuMatrix<T:Equatable where T:Hashable>: LinkedList<T>, VerticallyLinkable, LaterallyLinkable {
    var verticalHead = LinkedNode<T>()
    
    var lateralHead = LinkedNode<T>()
    
    lazy var rows: [Int : LinkedNode<T>] = {
        var rowDict:[Int : LinkedNode<T>] = [:]
        
        var current:LinkedNode<T>? = self.verticalHead
        if let hash = current?.key?.hashValue {
            rowDict[hash] = current!
        }
        current = current?.down
        while current != nil {
            if current!.key == self.verticalHead.key {
                break
            }
            if let hash = current?.key?.hashValue {
                rowDict[hash] = current!
            }
            current = current!.down
        }
        return rowDict
        
    }()
    
    
    func verticalCount() -> Int {
        var current:LinkedNode<T>? = verticalHead.down
        var count = 1
        WhileLoop: while current != nil {
            if current!.key == verticalHead.key {
                break WhileLoop
            }
            count+=1
            current = current!.down
        }
        return count
    }
    
    
    func lateralCount() -> Int {
        var current:LinkedNode<T>? = lateralHead.right
        var count = 1
        WhileLoop: while current != nil {
            if current!.latOrder == lateralHead.latOrder {
                break WhileLoop
            }
            count+=1
            current = current!.right
        }
        return count
    }
    
    func removeLateralLink(link: LinkedNode<T>) {
        
        if link.left?.latOrder == link.latOrder {
            lateralHead = LinkedNode<T>()
            lateralHead.key = nil
        } else {
            if link.latOrder == lateralHead.latOrder {
                if let newHead = link.right {
                    lateralHead = newHead
                }
            }
            link.left?.right = link.right
            link.right?.left = link.left
        }
    }
    
    func removeVerticalLink(link: LinkedNode<T>) {
        
        if link.up?.vertOrder == link.vertOrder {
            verticalHead = LinkedNode<T>()
            verticalHead.key = nil
        } else {
            if link.vertOrder == verticalHead.vertOrder {
                if let newHead = link.down {
                    verticalHead = newHead
                }
            }
            link.up?.down = link.down
            link.down?.up = link.up
        }
    }
    
    
    func insertLateralLink(link: LinkedNode<T>) {
        if lateralHead.key == nil {
            lateralHead = link
        } else {
            link.left?.right = link
            link.right?.left = link
            if link.latOrder <= lateralHead.latOrder {
                lateralHead = link
            }
        }
        
    }
    
    func insertVerticalLink(link: LinkedNode<T>) {
        if verticalHead.key == nil {
            verticalHead = link
        } else {
            link.up?.down = link
            link.down?.up = link
            if link.vertOrder <= verticalHead.vertOrder {
                verticalHead = link
            }
            
        }
    }
    
    func printRowHeadOrders() {
        
        var current = verticalHead.down!
        var prevOrder = 0
        print("\(verticalHead.vertOrder)")
        while current.vertOrder != verticalHead.vertOrder {
            
            
            var countString = " "
            current = current.right!
            while current.latOrder != 0 {
                countString += "-\(current.latOrder)"
                current = current.right!
            }
            
            let numRow = current.vertOrder
            
            if prevOrder + 1 != numRow {
                print("Jumps to: \(numRow)"+countString)
            } else {
                print("\(numRow)" + countString)
            }
            
            prevOrder = numRow
            current = current.down!
        }
    }
    
    func printColumnHeadOrders() {
        
        var current = lateralHead.right!
        var prevOrder = 0
        print("\(lateralHead.latOrder)")
        while current.latOrder != lateralHead.latOrder {
            
            var countString = " "
            
            current = current.down!
            while current.vertOrder != 0 {
                countString += "-\(current.vertOrder)"
                current = current.down!
            }
            let numCol = current.latOrder
            if prevOrder + 1 != numCol {
                print("Jumps to: \(numCol)"+countString)
            } else {
                print("\(numCol)" + countString)
            }
            
            prevOrder = numCol
            current = current.right!
        }
    }
    
    func countAllColumns() {
        let last = lateralHead.left!
        var current = lateralHead
        
        while current.latOrder != last.latOrder {
            
            print("column: \(current.latOrder) has \(countColumn(current)) nodes")
            current = current.right!
        }
    }
    
    func countColumn(node: LinkedNode<T>) -> Int {
        
        var current = node.down!
        var count = 1
        
        while current.vertOrder != node.vertOrder {
            count += 1
            current = current.down!
        }
        
        return count
    }
    
    func countAllRows() {
        print("count all rowss")
        let last = verticalHead.up!
        var current = verticalHead
        
        while current.vertOrder != last.vertOrder {
            print("row: \(current.vertOrder) has \(countRow(current)) nodes")
            current = current.down!
        }
        
    }
    
    func countRow(node: LinkedNode<T>) -> Int {
        var current = node.right!
        var count = 1
        
        while current.latOrder != node.latOrder {
            count += 1
            current = current.right!
        }
        
        return count
    }

}


extension SudokuMatrix: TwoDimensionallyLinkable {
    
}

class LinkedNode<T> {
    var key: T? = nil
    
    var left: LinkedNode<T>?
    var right: LinkedNode<T>?
    var up: LinkedNode<T>?
    var down: LinkedNode<T>?
    
    var latOrder: Int = 0
    var vertOrder: Int = 0
}





extension LinkedNode  {
    
    convenience init(key: T) {
        self.init()
        self.key = key
    }
    

    func countColumn() -> Int {
        let start = self.vertOrder
        var count = 1
        var current = self.down
        while current != nil {
            if current!.vertOrder == start {
                break
            }
            count+=1
            current = current!.down
        }
        return count
    }
    
    
    func getVerticalHead() -> LinkedNode<T> {
        var current:LinkedNode<T> = self
        
        while current.up != nil {
            if current.vertOrder <= current.up!.vertOrder {
                break
            }
            current = current.up!
        }
        
        return current
    }
    
    func getLateralHead() -> LinkedNode<T> {
        var current = self
        while current.left != nil {
            if current.latOrder <= current.left!.latOrder {
                break
            }
            current = current.left!
        }
        return current
    }
    
    func getVerticalTail() -> LinkedNode<T> {
        var current = self
        while current.down != nil {
            if current.down!.vertOrder == 0 {
                break
            }
            current = current.down!
        }
        return current
    }
    
    func getLateralTail() -> LinkedNode<T> {
        var current:LinkedNode<T> = self
        while current.right != nil {
            if current.right!.latOrder == 0 {
                break
            }
            current = current.right!
        }
        return current
    }
    
  }



struct PuzzleNode: Hashable {
    
    var cell: PuzzleCell?
    var header: ColumnHeader?
    

    var value:Int? {
        get {
            guard let val = cell?.value else{
                return header?.value
            }
            return val
        }
    }
    var column:Int? {
        get {
            guard let col = cell?.column else {
                return header?.column
            }
            return col
        }
        
    }
    var row:Int? {
        get {
            guard let row = cell?.row else {
                return header?.row
            }
            return row
        }
    }
   var box:Int? {
    mutating get {
        guard let box = cell?.box else{
            return header?.box
        }
        return box
    }
    }
    
    var hashValue: Int {
        guard let cell = cell else {
            return 0
        }
        return cell.hashValue
    }
    
     init(value: Int, column: Int, row: Int) {
        cell = PuzzleCell(row: row, column: column, value: value)
    }
    
    init(node: PuzzleNode){
        cell = node.cell
        header = node.header
    }
    
    init(cell: PuzzleCell) {
        self.cell = cell
    }
    
    init(header: ColumnHeader) {
        self.header = header
    }
    
    
}


func == (lhs:PuzzleNode, rhs:PuzzleNode) -> Bool {
    
    guard lhs.header == nil || rhs.header == nil else {
        return lhs.header! == rhs.header!
    }
    
    guard lhs.cell == nil || rhs.cell == nil else {
        return lhs.cell! == rhs.cell!
    }
    
    let header = lhs.header != nil ? lhs.header! : rhs.header!
    
    let cell = lhs.cell != nil ? lhs.cell! : rhs.cell!
    
    return header == cell

    
}

extension PuzzleNode: Equatable {}


enum PuzzleDifficulty: Equatable, Hashable {
    case Easy
    case Medium
    case Hard
    case Insane
    case Custom (Int)
    
    static func fromCacheString(cacheString: String) -> PuzzleDifficulty {
        let dict:[String: PuzzleDifficulty] = [PuzzleDifficulty.Easy.cacheString(): .Easy, PuzzleDifficulty.Medium.cacheString(): .Medium, PuzzleDifficulty.Hard.cacheString(): .Hard, PuzzleDifficulty.Insane.cacheString(): Insane]
        if let diff = dict[cacheString] {
            return diff
        } else {
            return Custom(0)
        }
    }
    
    var isCachable: Bool {
        switch self{
        case .Custom (_):
            return false
        default:
            return true
        }
    }
    
    var currentKey: String? {
        switch self {
        case .Easy:
            return currentEasyPuzzleKey
        case .Medium:
            return currentMediumPuzzleKey
        case .Hard:
            return currentHardPuzzleKey
        case .Insane:
            return currentInsanePuzzleKey
        default:
            return nil
        }
    }
    
    var hashValue: Int {
        get {
            return self.toInt()
        }
    }
    
    
    func toInt() -> Int {
        switch self{
        case .Easy:
            return 0
        case .Medium:
            return 1
        case .Hard:
            return 2
        case .Insane:
            return 3
        case .Custom(let diff):
            return 4 + diff
        }
    }
    
    func cacheString() -> String {
        switch self{
        case .Easy:
            return easyPuzzleKey
        case .Medium:
            return mediumPuzzleKey
        case .Hard:
            return hardPuzzleKey
        case .Insane:
            return insanePuzzleKey
        default:
            return "caching unavailable"
        }
    }
    
    func notificationString() -> String {
        switch self{
        case .Easy:
            return easyPuzzleReady
        case .Medium:
            return mediumPuzzleReady
        case .Hard:
            return hardPuzzleReady
        case .Insane:
            return insanePuzzleReady
        default:
            return customPuzzleReady
        }
    }

    func cachePath() -> NSURL {
        switch self{
        case .Easy:
            return easyCacheFilePath
        case .Medium:
            return mediumCacheFilePath
        case .Hard:
            return hardCacheFilePath
        default:
            return insaneCacheFilePath
        }
    }
    
}

func == (lhs:PuzzleDifficulty, rhs:PuzzleDifficulty) -> Bool{
    return lhs.toInt() == rhs.toInt()
}



class Matrix {
    
    static let sharedInstance: Matrix = Matrix()
    
    var rowsAndColumns: SudokuMatrix<PuzzleNode>? = SudokuMatrix<PuzzleNode>()
    typealias Choice = (Chosen: LinkedNode<PuzzleNode>, Columns:[LinkedNode<PuzzleNode>], Rows:[LinkedNode<PuzzleNode>], Root:Int)
    private var currentSolution = [Choice]()
    private var eliminated = [Choice]()
    typealias Solution = [LinkedNode<PuzzleNode>]
    private var solutions = [Solution]()
    private var solutionDict: [PuzzleCell: LinkedNode<PuzzleNode>]?
    private var rawDiffDict: [PuzzleDifficulty:Int] = [.Easy : 130, .Medium: 160, .Hard: 190, .Insane: 240]
    //var allRows: [Int: LinkedNode<PuzzleNode>]?
    
    
    init() {
        constructMatrix()
    }
    
    
    func getRawDifficultyForPuzzle(difficulty: PuzzleDifficulty) -> Int {
        switch difficulty{
        case .Custom(let diff):
            return diff
        default:
            return rawDiffDict[difficulty]!
        }
    }
   func rebuild() {
        while currentSolution.count != 0 {
            let lastChoice:Choice = currentSolution.removeLast()
            reinsertLast(lastChoice)
        }
        while eliminated.count != 0 {
            let lastChoice:Choice = eliminated.removeLast()
            reinsertLast(lastChoice)
        }
        
        solutions = []
    }
    
    func generatePuzzleOfDifficulty(difficulty: PuzzleDifficulty) {
        var puzz: [PuzzleCell] = []
        
        
        dispatch_barrier_async(concurrentPuzzleQueue) {
            let initialChoice = self.selectColumn()!
            
            if !self.findFirstSolution(initialChoice, root: initialChoice.vertOrder) {
                // throw an error
            }
            
            let sol = self.solutions[0]
            
            puzz = cellsFromConstraints(sol)
            
            self.solutionDict = cellNodeDictFromNodes(sol)
            
            let last = puzz.removeLast()
            
            // get a list of minimal givens that need to be left in the grid for a valid puzzle and a list of all the values that are taken out
            let filtered = self.puzzleOfSpecifiedDifficulty(puzz, withLastRemoved: last, forTargetDifficulty: difficulty)
            
            
            //self.rebuild()
            // add removed values from the second list back into the first list until a puzzle of the desired difficulty level is achieved
           // let finished = self.puzzleOfSpecifedDifficulty(difficulty, withGivens: filtered.Givens, andSolution: filtered.Solution)
            puzz = filtered.Givens

            let aPuzzle = Puzzle(nonNilValues: puzz)
            aPuzzle.solution = filtered.Solution
            
            
            self.rebuild()
            
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName(difficulty.notificationString(), object: self, userInfo: ["puzzle": aPuzzle])

        }
            }

    private func puzzleOfSpecifiedDifficulty(var allVals:[PuzzleCell], withLastRemoved lastRemoved:PuzzleCell, var andTried tried:[PuzzleCell]=[], var andSolution solution:[PuzzleCell]=[], forTargetDifficulty targetDifficulty:PuzzleDifficulty) -> (Givens:[PuzzleCell], Solution:[PuzzleCell]) {
        
        rebuild()
        
        let targetDiff = getRawDifficultyForPuzzle(targetDifficulty)
        
        //var rowList:[LinkedNode<PuzzleNode>] = []
        let vals = allVals + tried
        let rowList: [LinkedNode<PuzzleNode>] = vals.map({solutionDict![$0]!})
        
        let rawDiff = solveForRows(rowList, elims:true)
        
        let numSolutions = countPuzzleSolutions()
        
        if numSolutions != 1 {
            if allVals.isEmpty {
                tried.append(lastRemoved)
                return (tried+allVals, solution)
            }
            
            let random = Int(arc4random_uniform((UInt32(allVals.count))))
            
            let next = allVals.removeAtIndex(random)
            
            tried.append(lastRemoved)
            return puzzleOfSpecifiedDifficulty(allVals, withLastRemoved: next, andTried: tried, andSolution: solution, forTargetDifficulty: targetDifficulty)
        }
        
        if rawDiff < targetDiff {
            
            if allVals.isEmpty {
                tried.append(lastRemoved)
                return (tried+allVals, solution)
            }
            
            let random = Int(arc4random_uniform((UInt32(allVals.count))))
            
            let next = allVals.removeAtIndex(random)
            
            solution.append(lastRemoved)
            return puzzleOfSpecifiedDifficulty(allVals, withLastRemoved: next, andTried: tried, andSolution: solution, forTargetDifficulty: targetDifficulty)
            
        } else {
            solution.append(lastRemoved)
            return (tried+allVals, solution)
        }
    }
    
    func solutionForValidPuzzle(puzzle: [PuzzleCell]) -> [PuzzleCell]? {
        defer {
            rebuild()
        }
        let givens = getRowsFromCells(puzzle)
        solveForRows(givens, elims:true)
        if countPuzzleSolutions() != 1 {
            return nil
        }
        let nodes = solutions[0]
        return cellsFromConstraints(nodes)
    }
    
    
   private func getRowsFromCells(cells: [PuzzleCell]) -> [LinkedNode<PuzzleNode>] {
        
        var rowsToSolve = [LinkedNode<PuzzleNode>]()
        
        for cell in cells {
            let solvedRow = findRowMatchForCell(cell)
            rowsToSolve.append(solvedRow)
        }
        
        return rowsToSolve
    }
    
    
    private func countPuzzleSolutions() -> Int {
        
        if self.solved() {
            return 1
        }
        
        if let bestColumn = selectColumn() {
            return allSolutionsForPuzzle(bestColumn, andRoot:bestColumn.vertOrder)
        }
        
        return 0
    }
    
    
    private func solved() -> Bool {
        
        if rowsAndColumns!.lateralHead.key == nil {
            return true
        }
        
        return false
    }
    
    private func addSolution() {
        var solution: [LinkedNode<PuzzleNode>] = []
        
        for choice in currentSolution {
            solution.append(choice.Chosen.getLateralHead())
        }
        
        solutions.append(solution)
    }
  
    private func allSolutionsForPuzzle(rowChoice:LinkedNode<PuzzleNode>, andCount count:Int = 0, withCutOff cutOff:Int = 2, andRoot root:Int = 1) -> Int {
        
        if count == cutOff {
            return cutOff
        }
        
        solveForRow(rowChoice, root: root)
        
        
        if solved() {
            addSolution()
            
            if let next = findNextRowChoice() {
                return allSolutionsForPuzzle(next.Node, andCount: count+1, withCutOff: cutOff, andRoot: next.Root)
            } else {
                return count+1
            }
        } else {
            if let next = selectColumn() {
                return allSolutionsForPuzzle(next, andCount: count, withCutOff: cutOff, andRoot:next.vertOrder)
            } else {
                if let next = findNextRowChoice() {
                    return allSolutionsForPuzzle(next.Node, andCount: count, withCutOff: cutOff, andRoot: next.Root)
                } else {
                    return count
                }
            }
        }
    }

    
    private func findFirstSolution(rowChoice:LinkedNode<PuzzleNode>, root: Int) -> Bool {
        
        solveForRow(rowChoice, root: root)

        
        if solved() {
            addSolution()
           return true
        } else {

            if let next = selectColumn() {
                return findFirstSolution(next, root: next.vertOrder)
            } else {
                if let next = findNextRowChoice() {
                    return findFirstSolution(next.Node, root: next.Root)
                } else {
                    return false
                }
            }
        }
    }
    
    private func findNextRowChoice()->(Node: LinkedNode<PuzzleNode>, Root:Int)? {
        
        if currentSolution.count == 0 {
            return nil
        }
    
        let lastChoice:Choice = self.currentSolution.removeLast()
        reinsertLast(lastChoice)
        
        let lcDown = lastChoice.Chosen.down!.vertOrder != 0 ? lastChoice.Chosen.down! : lastChoice.Chosen.down!.down!
        
        if lcDown.vertOrder == lastChoice.Root {
            return findNextRowChoice()
        }
       
        return (lcDown, lastChoice.Root)
    }
    
    private func reinsertLast(last: Choice) {
        
        for col in last.Columns.reverse() {
            rowsAndColumns!.insertLateralLink(col)
        }
        
        for row in last.Rows.reverse()
        {
            insertRow(row)
        }

    }
    
    private func selectColumn() -> LinkedNode<PuzzleNode>? {
    
        var currentColumn:LinkedNode<PuzzleNode> = rowsAndColumns!.lateralHead
        var minColumns: [LinkedNode<PuzzleNode>] = []
        var minRows = currentColumn.countColumn()
        
        let last = currentColumn.left!
        
        defer {
            let lastCount = last.countColumn()
            if (lastCount > 1) && (last.countColumn() < minRows) {
                minColumns.append(last)
            }
        }
        
        CountLoop: while currentColumn.key != last.key {
            
            let count = currentColumn.countColumn()
            if count == 1 { // if we have a one-row column, we have an unsatisfiable constraint and therefore an invalid puzzle
                return nil
            } else if count < minRows {
                minRows = count
                minColumns = [currentColumn]
            } else if count == minRows {
                minColumns.append(currentColumn)
            }
            currentColumn = currentColumn.right!
        }
        
        if minColumns.isEmpty { return nil }
           
        
        let random1 = Int(arc4random_uniform((UInt32(minColumns.count))))
        currentColumn = minColumns[random1]
        
        let random2 = Int(arc4random_uniform(UInt32(minRows-1)))+1
        var count = 0
        
        while count != random2 {
            currentColumn = currentColumn.down!
            count+=1
        }
        
        return currentColumn

    }
    
    
    private func solveForRows(rows: [LinkedNode<PuzzleNode>], elims:Bool = false) -> Int {
        
        for row in rows {
            solveForRow(row, root: row.vertOrder, elims: elims)
        }
        
        return rowsAndColumns!.verticalCount()
    }
    
    private func solveForRow(row: LinkedNode<PuzzleNode>, root: Int = 1, elims: Bool = false) {
    
        var columnList: [LinkedNode<PuzzleNode>] = []
        var current = row.getLateralHead().right!
        while current.latOrder != 0 {
            let col = current.getVerticalHead()
            columnList.append(col)
            current = current.right!
        }
        
      
        var removedRows: [LinkedNode<PuzzleNode>] = []
        
        for column in columnList {
            let rowsToRemove = coverColumn(column)
            removedRows += rowsToRemove
            for aRow in rowsToRemove {
                removeRow(aRow)
            }
        }
        
        let choiceTup = (row, columnList, removedRows, root)
        
        if elims {
            eliminated.append(choiceTup)
        } else {
            currentSolution.append(choiceTup)
        }
        
    }
    
    func coverColumn(column: LinkedNode<PuzzleNode>)->[LinkedNode<PuzzleNode>] {
       
        var rowsToRemove: [LinkedNode<PuzzleNode>] = []
        var current = column.down!
        while current.vertOrder != 0 {
            rowsToRemove.append(current)
            current = current.down!
        }
        rowsAndColumns!.removeLateralLink(current)
        return rowsToRemove
    }
    
    func removeRow(row: LinkedNode<PuzzleNode>) {
       
        var current = row.getLateralHead().right!
        while current.latOrder !=  0 {
            current.up!.down = current.down
            current.down!.up = current.up
            current = current.right!
        }
        
        rowsAndColumns!.removeVerticalLink(current)
    }
    
    func insertRow(row: LinkedNode<PuzzleNode>) {
    
        var current = row.getLateralHead().right!
        while current.latOrder != 0 {
            current.up!.down = current
            current.down!.up = current
            current = current.right!
        }
        rowsAndColumns!.insertVerticalLink(current)
    }
    
    private func resetSolution() {
        while currentSolution.count != 0 {
            let lastChoice:Choice = currentSolution.removeLast()
            reinsertLast(lastChoice)
        }
        solutions = []
    }
    

    
    // Constructing matrix
    private func constructMatrix() {

        if rowsAndColumns == nil {
            rowsAndColumns = SudokuMatrix<PuzzleNode>()
        }
        
        //allRows = rowsAndColumns!.rows
        buildRowChoices()
        
        buildCellConstraints()
        buildColumnConstraints()
        buildRowConstraints()
        buildBoxConstraints()
       
        buildOutMatrix()
        
    }
    
    private func buildCellConstraints(){
        
        for columnIndex in 1...9 {
            for rowIndex in 1...9 {
                /*if columnIndex == 2 {
                    rowsAndColumns!.countAllColumns()
                }*/
                let header = ColumnHeader(row: rowIndex, column: columnIndex)
                let node = PuzzleNode(header: header)
                rowsAndColumns!.addLateralLink(node)
            }
        }
        
        
    }
    
    private func buildColumnConstraints(){
        
        for aValue in 1...9 {
            for columnIndex in 1...9 {
                let header = ColumnHeader(value: aValue, column: columnIndex)
                let node = PuzzleNode(header: header)
                rowsAndColumns!.addLateralLink(node)
            }
        }
    }
    
    private func buildRowConstraints() {
        
        for aValue in 1...9 {
            for rowIndex in 1...9 {
                let header = ColumnHeader(value: aValue, row: rowIndex)
                let node = PuzzleNode(header: header)
                rowsAndColumns!.addLateralLink(node)
            }
        }
    }
    
    private func buildBoxConstraints() {
        
        for aValue in 1...9 {
            for boxIndex in 1...9 {
                let header = ColumnHeader(value: aValue, box: boxIndex)
                let node = PuzzleNode(header: header)
                rowsAndColumns!.addLateralLink(node)
            }
        }
    }
    
    private func buildRowChoices() {
        
        for rowIndex in 1...9 {
            for columnIndex in 1...9 {
                for aValue in 1...9 {
                    let cell = PuzzleCell(row: rowIndex, column: columnIndex, value: aValue)
                    let node = PuzzleNode(cell: cell)
                    rowsAndColumns!.addVerticalLink(node)
                }
            }
        }
    }
    
    private func buildOutMatrix() {
        
        guard let vertHead = rowsAndColumns?.verticalHead else {
            print("Matrix setup failed because the vertically linked list was headless")
            return
        }
        
        var currentRow:LinkedNode<PuzzleNode> = vertHead
        let last = vertHead.up!
        
        defer {
            connectMatchingConstraintsForRow(last)
        }
        
        RowLoop: while currentRow.key != last.key {
            
            connectMatchingConstraintsForRow(currentRow)
            currentRow = currentRow.down!
        }
        
    }
    
    func connectMatchingConstraintsForRow(row: LinkedNode<PuzzleNode>) {
        guard let latHead = rowsAndColumns?.lateralHead else {
            print("Matrix setup failed because the laterally linked list was headless")
            return
        }
        var currentHeader = latHead
        let last = latHead.left!
        
        let addNodeBlock = { (header: LinkedNode<PuzzleNode>) -> () in
            if header.key == row.key {
                let newKey = PuzzleNode(node: row.key!) // changed from constHead!.key!
                let newNode = LinkedNode(key: newKey)
                self.rowsAndColumns!.addLateralLinkFromNode(row.getLateralTail(), toNewNode: newNode)
                self.rowsAndColumns!.addVerticalLinkFromNode(header.getVerticalTail(), toNewNode: newNode)
                newNode.down = header
                newNode.right = row
            }
        }
        
        defer {
            addNodeBlock(last)
        }
        
        HeaderLoop: while currentHeader.key! != last.key {
            
            addNodeBlock(currentHeader)
            currentHeader = currentHeader.right!
        }
        
    }
    
    
    // matches given values against row choices -- move this to linked list class def? 

    private func findRowMatch(mRow: PuzzleNode) -> LinkedNode<PuzzleNode> {
    
        // if the node we're looking for is in the allRows dictionary, we can just look it up rather than traversing the row ladder
        /*if let hash = mRow.getHash(), rows = allRows {
            if let row = rows[hash] {
                return row
            }
        }*/
        
        var current = rowsAndColumns!.verticalHead.up!
        
        while current.vertOrder != rowsAndColumns!.verticalHead.vertOrder {
            if current.key! == mRow {
                return current
            }
            current = current.up!
        }
        return current
    }
    
    private func findRowMatchForCell(cell: PuzzleCell) -> LinkedNode<PuzzleNode> {
        var current = rowsAndColumns!.verticalHead.up!
        
        while current.vertOrder != rowsAndColumns!.verticalHead.vertOrder {
            if current.key!.cell == cell {
                return current
            }
            current = current.up!
        }
        return current
    }

}



