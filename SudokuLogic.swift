//
//  SudokuLogic.swift
//  SudokuCheat
//
//  Created by Isaac Benham on 4/17/15.
//  Copyright (c) 2015 Isaac Benham. All rights reserved.
//

import UIKit


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
        node.right!.left = newNode
        node.right = newNode
    }
    
    func addVerticalLinkFromNode(node: LinkedNode<T>, toNewNode newNode: LinkedNode<T>) {
        newNode.vertOrder = node.vertOrder+1
        newNode.down = node.down
        newNode.up = node
        node.down!.up = newNode
        node.down = newNode
    }


}


class SudokuMatrix<T:Equatable where T:Hashable>: LaterallyLinkable, VerticallyLinkable, TwoDimensionallyLinkable {

    var lateralHead = LinkedNode<T>()
    var verticalHead = LinkedNode<T>()
    
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
    
    func printRows() {
        var current = verticalHead
        let last = verticalHead.up!.vertOrder
        
        while current.vertOrder != last {
            let key = current.key!
            print("\(current.vertOrder): \(key)")
            
            current = current.down!
        }
        
        print("\(last): \(current.key!)")
    }
    
    func printColumns() {
        var current = lateralHead
        let last = current.left!.latOrder
        
        while current.latOrder != last {
            let key = current.key!
            print("\(current.latOrder): \(key)")
            
            current = current.right!
        }
        
        print("\(last): \(current.key!)")
    }
    
    func enumerateRows() {
        
        var current = verticalHead
        var count = 0
        
    
        while (current.vertOrder != verticalHead.vertOrder || count < 1) {
            if current.vertOrder == lateralHead.vertOrder {
                count += 1
            }
            
            var countString = " "
            current = current.right!
            while current.latOrder != 0 {
                countString += "-\(current.latOrder)"
                current = current.right!
            }
            
            let numRow = current.vertOrder
            
            print("\(numRow)" + countString)
            
            current = current.down!
        }
    }
    
    func enumerateColumns() {
        
        var current = lateralHead
        var count = 0
        
        while (current.latOrder != lateralHead.latOrder || count < 1) {
            if current.latOrder == lateralHead.latOrder {
                count += 1
            }
            var countString = " "
            
            current = current.down!
            while current.vertOrder != 0 {
                countString += "-\(current.vertOrder)"
                current = current.down!
            }
            let numCol = current.latOrder
            print("\(numCol)" + countString)
            
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



struct PuzzleKey: Hashable {
    
    var cell: PuzzleCell?
    var header: ColumnHeader?
    
    
    
    
    init(node: PuzzleKey){
        cell = node.cell
        header = node.header
    }
    
    init(cell: PuzzleCell) {
        self.cell = cell
    }
    
    init(header: ColumnHeader) {
        self.header = header
    }
    
    var hashValue: Int {
        guard let cell = cell else {
            return 0
        }
        return cell.hashValue
    }
    
    
}


func == (lhs:PuzzleKey, rhs:PuzzleKey) -> Bool {
    
    guard lhs.header == nil || rhs.header == nil else {
        return lhs.header! == rhs.header!
    }
    
    guard lhs.cell == nil || rhs.cell == nil else {
        return lhs.cell! == rhs.cell!
    }
    
    if let header = lhs.header {
        return header == rhs.cell!
    }
    
    return lhs.cell! == rhs.header!

}

extension PuzzleKey: Equatable {}


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
    
    var matrix = SudokuMatrix<PuzzleKey>()
    typealias Choice = (Chosen: LinkedNode<PuzzleKey>, Columns:[LinkedNode<PuzzleKey>], Rows:[LinkedNode<PuzzleKey>], Root:Int)
    private var currentSolution = [Choice]()
    private var eliminated = [Choice]()
    typealias Solution = [LinkedNode<PuzzleKey>]
    private var solutions = [Solution]()
    private var solutionDict: [PuzzleCell: LinkedNode<PuzzleKey>]?
    private var rawDiffDict: [PuzzleDifficulty:Int] = [.Easy : 130, .Medium: 160, .Hard: 190, .Insane: 240]
    var isSolved: Bool {
        get {
            return matrix.lateralHead.key == nil
        }
    }
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
                // throw an error?
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
        let rowList: [LinkedNode<PuzzleKey>] = vals.map({solutionDict![$0]!})
        
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
    
    
   private func getRowsFromCells(cells: [PuzzleCell]) -> [LinkedNode<PuzzleKey>] {
        
        var rowsToSolve = [LinkedNode<PuzzleKey>]()
        
        for cell in cells {
            let solvedRow = findRowMatchForCell(cell)
            rowsToSolve.append(solvedRow)
        }
        
        return rowsToSolve
    }
    
    
    private func countPuzzleSolutions() -> Int {
        
        if isSolved {
            return 1
        }
        
        if let bestColumn = selectColumn() {
            return allSolutionsForPuzzle(bestColumn, andRoot:bestColumn.vertOrder)
        }
        
        return 0
    }
    
    
    private func addSolution() {
        var solution: [LinkedNode<PuzzleKey>] = []
        
        for choice in currentSolution {
            solution.append(choice.Chosen.getLateralHead())
        }
        
        solutions.append(solution)
    }
  
    private func allSolutionsForPuzzle(rowChoice:LinkedNode<PuzzleKey>, andCount count:Int = 0, withCutOff cutOff:Int = 2, andRoot root:Int = 1) -> Int {
        
        if count == cutOff {
            return cutOff
        }
        
        solveForRow(rowChoice, root: root)
        
        
        if isSolved {
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

    
    private func findFirstSolution(rowChoice:LinkedNode<PuzzleKey>, root: Int) -> Bool {
        
        solveForRow(rowChoice, root: root)

        
        if isSolved {
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
    
    private func findNextRowChoice()->(Node: LinkedNode<PuzzleKey>, Root:Int)? {
        
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
            matrix.insertLateralLink(col)
        }
        
        for row in last.Rows.reverse()
        {
            insertRow(row)
        }

    }
    
    private func selectColumn() -> LinkedNode<PuzzleKey>? {
    
        var currentColumn:LinkedNode<PuzzleKey> = matrix.lateralHead
        var minColumns: [LinkedNode<PuzzleKey>] = []
        var minRows = currentColumn.countColumn()
        
        let last = currentColumn.left!
       
        
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
        
        let lastCount = last.countColumn()
        if lastCount == 1 {
            return nil
        } else if lastCount < minRows {
            minColumns = [last]
        } else if lastCount == minRows {
            minColumns.append(last)
        }

        
       // if minColumns.isEmpty { return nil }
           
        
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
    
    
    private func solveForRows(rows: [LinkedNode<PuzzleKey>], elims:Bool = false) -> Int {
        
        for row in rows {
            solveForRow(row, root: row.vertOrder, elims: elims)
        }
        
        return matrix.verticalCount()
    }
    
    private func solveForRow(row: LinkedNode<PuzzleKey>, root: Int = 1, elims: Bool = false) {
    
        var columnList: [LinkedNode<PuzzleKey>] = []
        var current = row.getLateralHead().right!
        while current.latOrder != 0 {
            let col = current.getVerticalHead()
            columnList.append(col)
            current = current.right!
        }
        
      
        var removedRows: [LinkedNode<PuzzleKey>] = []
        
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
    
    func coverColumn(column: LinkedNode<PuzzleKey>)->[LinkedNode<PuzzleKey>] {
       
        var rowsToRemove: [LinkedNode<PuzzleKey>] = []
        var current = column.down!
        while current.vertOrder != 0 {
            rowsToRemove.append(current)
            current = current.down!
        }
        matrix.removeLateralLink(current)
        return rowsToRemove
    }
    
    func removeRow(row: LinkedNode<PuzzleKey>) {
       
        var current = row.getLateralHead().right!
        while current.latOrder !=  0 {
            current.up!.down = current.down
            current.down!.up = current.up
            current = current.right!
        }
        
        matrix.removeVerticalLink(current)
    }
    
    func insertRow(row: LinkedNode<PuzzleKey>) {
    
        var current = row.getLateralHead().right!
        while current.latOrder != 0 {
            current.up!.down = current
            current.down!.up = current
            current = current.right!
        }
        matrix.insertVerticalLink(current)
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
                let node = PuzzleKey(header: header)
                matrix.addLateralLink(node)
            }
        }
        
        
    }
    
    private func buildColumnConstraints(){
        
        for aValue in 1...9 {
            for columnIndex in 1...9 {
                let header = ColumnHeader(value: aValue, column: columnIndex)
                let node = PuzzleKey(header: header)
                matrix.addLateralLink(node)
            }
        }
    }
    
    private func buildRowConstraints() {
        
        for aValue in 1...9 {
            for rowIndex in 1...9 {
                let header = ColumnHeader(value: aValue, row: rowIndex)
                let node = PuzzleKey(header: header)
                matrix.addLateralLink(node)
            }
        }
    }
    
    private func buildBoxConstraints() {
        
        for aValue in 1...9 {
            for boxIndex in 1...9 {
                let header = ColumnHeader(value: aValue, box: boxIndex)
                let node = PuzzleKey(header: header)
                matrix.addLateralLink(node)
            }
        }
    }
    
    private func buildRowChoices() {
        
        for rowIndex in 1...9 {
            for columnIndex in 1...9 {
                for aValue in 1...9 {
                    let cell = PuzzleCell(row: rowIndex, column: columnIndex, value: aValue)
                    let node = PuzzleKey(cell: cell)
                    matrix.addVerticalLink(node)
                }
            }
        }
        
    }
    
    private func buildOutMatrix() {
        
        let vertHead = matrix.verticalHead 
        
        var currentRow:LinkedNode<PuzzleKey> = vertHead
        let last = vertHead.up!
        
        RowLoop: while currentRow.key != last.key {
            
            connectMatchingConstraintsForRow(currentRow)
            currentRow = currentRow.down!
        }
        
        connectMatchingConstraintsForRow(last)
        
    }
    
    private func connectMatchingConstraintsForRow(row: LinkedNode<PuzzleKey>) {
        let latHead = matrix.lateralHead
        
        var currentHeader = latHead
        let last = latHead.left!
        
        let addNodeBlock = { (header: LinkedNode<PuzzleKey>) -> () in
            if header.key == row.key {
                let newNode = LinkedNode(key: row.key!)
                self.matrix.addLateralLinkFromNode(row.getLateralTail(), toNewNode: newNode)
                self.matrix.addVerticalLinkFromNode(header.getVerticalTail(), toNewNode: newNode)
                newNode.down = header
                newNode.right = row
            }
        }
        
        HeaderLoop: while currentHeader.key! != last.key {
            
            addNodeBlock(currentHeader)
            currentHeader = currentHeader.right!
        }
        
        addNodeBlock(last)
        
    }
    
    
    // matches given values against row choices -- move this to linked list class def? 

    private func findRowMatch(mRow: PuzzleKey) -> LinkedNode<PuzzleKey> {
    
        // if the node we're looking for is in the allRows dictionary, we can just look it up rather than traversing the row ladder
        /*if let hash = mRow.getHash(), rows = allRows {
            if let row = rows[hash] {
                return row
            }
        }*/
        
        var current = matrix.verticalHead.up!
        
        while current.vertOrder != matrix.verticalHead.vertOrder {
            if current.key! == mRow {
                return current
            }
            current = current.up!
        }
        return current
    }
    
    private func findRowMatchForCell(cell: PuzzleCell) -> LinkedNode<PuzzleKey> {
        var current = matrix.verticalHead.up!
        
        while current.vertOrder != matrix.verticalHead.vertOrder {
            if current.key!.cell == cell {
                return current
            }
            current = current.up!
        }
        return current
    }

}



