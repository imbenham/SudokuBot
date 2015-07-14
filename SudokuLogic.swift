//
//  SudokuLogic.swift
//  SudokuCheat
//
//  Created by Isaac Benham on 4/17/15.
//  Copyright (c) 2015 Isaac Benham. All rights reserved.
//

import UIKit


class LinkedList<T:Equatable> {
    private var verticalHead: LinkedNode<T>
    private var lateralHead: LinkedNode<T>
    private var allNodes: [LinkedNode<T>]
    
    init() {
        verticalHead = LinkedNode<T>()
        verticalHead.up = verticalHead
        verticalHead.down = verticalHead
        lateralHead = LinkedNode<T>()
        lateralHead.left = lateralHead
        lateralHead.right = lateralHead
        allNodes = [lateralHead, verticalHead]
        
    }
    
    func addLateralLink(key: T) {
        if self.lateralHead.key == nil {
            lateralHead.key = key
            return
        }
        
        var current: LinkedNode<T>? = lateralHead
        
        while current != nil {
            if current!.right == nil {
                let newLink = LinkedNode<T>()
                allNodes.append(newLink)
                newLink.key = key
                newLink.left = current
                current!.getLateralHead().left = newLink
                current!.right = newLink
                newLink.latOrder = current!.latOrder+1
                newLink.right = newLink.getLateralHead()
                break
            } else if current!.right!.latOrder == 0 {
                let newLink = LinkedNode<T>()
                allNodes.append(newLink)
                newLink.key = key
                newLink.left = current
                current!.getLateralHead().left = newLink
                current!.right = newLink
                newLink.latOrder = current!.latOrder+1
                newLink.right = newLink.getLateralHead()
                break

            }
            current = current?.right
        }
        
    }
    
    func addVerticalLink(key: T) {
        if verticalHead.key == nil {
            verticalHead.key = key
            return
        }
        
        var current: LinkedNode<T>? = verticalHead
        
        while current != nil {
            if current!.down == nil {
                let newLink = LinkedNode<T>()
                allNodes.append(newLink)
                newLink.key = key
                newLink.up = current
                current!.getVerticalHead().up = newLink
                current!.down = newLink
                newLink.vertOrder = current!.vertOrder+1
                newLink.down = newLink.getVerticalHead()
                break
            } else if current!.down!.vertOrder == 0 {
                let newLink = LinkedNode<T>()
                allNodes.append(newLink)
                newLink.key = key
                newLink.up = current
                current!.getVerticalHead().up = newLink
                current!.down = newLink
                newLink.vertOrder = current!.vertOrder+1
                newLink.down = newLink.getVerticalHead()
                break
            }
            current = current?.down
        }
    }
    
    
    func addLateralLinkFromNode(node: LinkedNode<T>, toNewNode newNode: LinkedNode<T>) {
        newNode.latOrder = node.latOrder+1
        newNode.right = node.right
        newNode.left = node
        node.right = newNode
        allNodes.append(newNode)
        var current = newNode.right
        while current != nil {
            if current!.latOrder == 0 {
                break
            }
            current!.latOrder += 1
            current = current!.down
        }
        node.getLateralHead().left = node.getLateralTail()
    }
    
    func addVerticalLinkFromNode(node: LinkedNode<T>, toNewNode newNode: LinkedNode<T>) {
        allNodes.append(newNode)
        newNode.vertOrder = node.vertOrder+1
        newNode.down = node.down
        newNode.up = node
        node.down = newNode
        
        var current = newNode.down
        while current != nil {
            if current!.vertOrder == 0 {
                break
            }
            current!.vertOrder += 1
            current = current!.down
        }
        node.getVerticalHead().up = node.getVerticalTail()
    }
    
    func verticalCount() -> Int {
        var current:LinkedNode<T>? = verticalHead.down
        var count = 1
        while current != nil {
            if current!.key == verticalHead.key {
                break
            }
            count++
            current = current!.down
        }
        return count
    }
    
    
    func lateralCount() -> Int {
        var current:LinkedNode<T>? = lateralHead.right
        var count = 1
        while current != nil {
            if current!.latOrder == lateralHead.latOrder {
                break
            }
            count++
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
        //println(verticalHead.vertOrder)
        var current = verticalHead.down!
        var prevOrder = 0
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
        //println(lateralHead.latOrder)
        var current = lateralHead.right!
        var prevOrder = 0
        while current.latOrder != lateralHead.latOrder {
    
            var countString = " "
            /*if current!.countColumn() != 10 {
                countString += String(current!.countColumn())
            }*/
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
}

class LinkedNode<T> {
    var key: T? = nil
    var left: LinkedNode<T>? = nil
    var right: LinkedNode<T>? = nil
    var up: LinkedNode<T>? = nil
    var down: LinkedNode<T>? = nil
    var latOrder: Int = 0
    var vertOrder: Int = 0

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
            count++
            current = current!.down
        }
        return count
    }
    
    func countRow() -> Int {
        let head = self.getLateralHead()
        var current = self.getLateralHead()
        var count = 1
        while current.right != nil{
            if current.right!.latOrder == head.latOrder {
                break
            }
            count++
            current = current.right!
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
    
    
    func fromVertHead() -> Int {
        var current = self
        var count = 0
        
        while current.up != nil {
            if current.vertOrder == 0 {
                break
            }
            current = current.up!
            count++
        }
        
        return count
    }
    
    func fromLatHead() -> Int {
        var current = self
        var count = 0
        while current.left != nil {
            if current.latOrder == 0 {
                break
            }
            current = current.left!
            count++
        }
        return count
    }
    
    func connectedDownWithHead() -> Bool {
        var current = self.down!
        let vert = self.vertOrder
        if vert == 0 {
            return true
        }
        while current.vertOrder != vert {
            if current.vertOrder == 0 {
                return true
            }
            current = current.down!
        }
        return false
    }
}

struct PuzzleNode {

    var value:Int?
    var column:Int?
    var row:Int?
    var box:Int?
    

    
     init(value: Int, column: Int, row: Int, box: Int) {
        self.value = value
        self.column = column
        self.row = row
        self.box = box
    }
     init(value: Int, column: Int) {
        self.value = value
        self.column = column
    }
     init(value: Int, row: Int) {
        self.value = value
        self.row = row
    }
     init(row: Int, column: Int) {
        self.row = row
        self.column = column
    }
     init(value: Int, box: Int) {
        self.value = value
        self.box = box
    }
     init(node: PuzzleNode){
        self.value = node.value
        self.row = node.row
        self.column = node.column
        self.box = node.box
    }
}

func == (lhs:PuzzleNode, rhs:PuzzleNode) -> Bool {
    var boolList = [Bool]()
    if let val1 = lhs.value {
        if let val2 = rhs.value {
            boolList.append(val1==val2)
        }
    }
    
    if let row1 = lhs.row {
        if let row2 = rhs.row {
            boolList.append(row1==row2)
        }
    }
   
    if let col1 = lhs.column{
        if let col2 = rhs.column {
            boolList.append(col1==col2)
        }
    }
    
    if let box1 = lhs.box {
        if let box2 = rhs.box {
            boolList.append(box1==box2)
        }
    }
    
    if boolList.count > 1 {
        for b in boolList {
            if b == false {
                return false
            }
        }
        return true
    }
    return false
}

extension PuzzleNode: Equatable{}

enum PuzzleDifficulty: Int {
    case Easy = 100
    case Medium = 135
    case Hard = 170
    case Insane = 230
    
}

class Matrix {
    
    var rowsAndColumns = LinkedList<PuzzleNode>()
    typealias Choice = (Chosen: LinkedNode<PuzzleNode>, Columns:[LinkedNode<PuzzleNode>], Rows:[LinkedNode<PuzzleNode>], Root:Int)
    private var currentSolution = [Choice]()
    private var eliminated = [Choice]()
    typealias Solution = [LinkedNode<PuzzleNode>]
    private var solutions = [Solution]()
    
    init() {
        constructMatrix()
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
    
    func generatePuzzleOfDifficulty(difficulty: PuzzleDifficulty, withCompletion completion: Puzzle -> ()) {
        var puzz: [PuzzleCell] = []
        let initialChoice = selectColumn()!
        
        if !findFirstSolution(initialChoice, root: initialChoice.vertOrder) {
            // throw an error
        }
        
        puzz = cellsFromConstraints(solutions[0]).reverse()
        
        
        
        let last = puzz.removeLast()
        
        // get a list of minimal givens that need to be left in the grid for a valid puzzle and a list of all the values that are taken out
        let filtered = minValuesForPuzzle(puzz, withLastRemoved: last)
        // add removed values from the second list back into the first list until a puzzle of the desired difficulty level is achieved
        let finished = puzzleOfSpecifedDifficulty(difficulty, withGivens: filtered.Givens, andSolution: filtered.Solution)
        
        puzz = finished.Givens

        
        let aPuzzle = Puzzle(nonNilValues: puzz)
        aPuzzle.solution = finished.Solution

        completion(aPuzzle)
        
        rebuild()
        
    }

    private func puzzleOfSpecifedDifficulty(difficulty:PuzzleDifficulty, var withGivens givens:[PuzzleCell], var andSolution solution:[PuzzleCell]) -> (Givens: [PuzzleCell], Solution:[PuzzleCell]) {
        rebuild()
        
        let rawDiff = eliminatePuzzleGivens(givens)
        
        if rawDiff > difficulty.rawValue {
            let cellToAdd = solution.removeLast()
            givens.append(cellToAdd)
            return puzzleOfSpecifedDifficulty(difficulty, withGivens: givens, andSolution: solution)
        }
        
        return (givens, solution)
    }
    
    func minValuesForPuzzle(var allVals:[PuzzleCell], withLastRemoved lastRemoved:PuzzleCell, var andTried tried:[PuzzleCell]=[], var andSolution solution:[PuzzleCell]=[]) -> (Givens:[PuzzleCell], Solution:[PuzzleCell]) {
        defer {
            rebuild()
        }
        
        let difficulty = eliminatePuzzleGivens(allVals + tried)
        
        let numSolutions = countPuzzleSolutions()
        
        if allVals.count == 0 {
            if numSolutions == 1 {
                print("givens: \(tried.count); remaining possible assignments: \(difficulty)")
                return (tried, solution)
            }
        
            tried.append(lastRemoved)
            return (tried, solution)
        }
        
        
        let random = Int(arc4random_uniform((UInt32(allVals.count-1))))
        
        let next = allVals.removeAtIndex(random)
        
        if numSolutions > 1 {
            tried.append(lastRemoved)
            return minValuesForPuzzle(allVals, withLastRemoved: next, andTried: tried, andSolution: solution)
        } else {
            solution.append(lastRemoved)
            return minValuesForPuzzle(allVals, withLastRemoved: next, andTried: tried, andSolution: solution)
        }
    }
    
    func solutionForValidPuzzle(puzzle: [PuzzleCell]) -> [PuzzleCell]? {
        eliminatePuzzleGivens(puzzle)
        if countPuzzleSolutions() != 1 {
            rebuild()
            return nil
        }
        let nodes = solutions[0]
        rebuild()
        return cellsFromConstraints(nodes)
    }
    
    
   func eliminatePuzzleGivens(cells: [PuzzleCell]) -> Int {
        let givenValues = translateCellsToConstraintList(cells)
        var rowsToSolve = [LinkedNode<PuzzleNode>]()
        
        for val in givenValues {
            let solvedRow = findRowMatch(val).right!
            rowsToSolve.append(solvedRow)
        }
        
        for row in rowsToSolve {
            eliminated.append(solveForRow(row, root: row.vertOrder))
        }
    
        return rowsAndColumns.verticalCount()
    }
    
    
    func countPuzzleSolutions() -> Int {
        
        if self.solved() {
            return 1
        }
        
        if let bestColumn = selectColumn() {
            return allSolutionsForPuzzle(bestColumn, andRoot:bestColumn.vertOrder)
        }
        
        return 0
    }
    
    
    private func solved() -> Bool {
        
        if rowsAndColumns.lateralHead.key == nil {
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
        
        let elim = solveForRow(rowChoice, root:root)
        currentSolution.append(elim)
        
        
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
        
        let elim = solveForRow(rowChoice, root: root)
        currentSolution.append(elim)
        
        
        if solved() {
            addSolution()
           return true
        } else {
            /*
            let count = currentSolution.count
            let selectionFunc: () -> LinkedNode<PuzzleNode>? = count < 5 ? selectRandom : selectColumn*/

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
            rowsAndColumns.insertLateralLink(col)
        }
        
        for row in last.Rows.reverse()
        {
            insertRow(row)
        }

    }
    
    private func selectColumn() -> LinkedNode<PuzzleNode>? {
        let latHeadOrder = rowsAndColumns.lateralHead.latOrder
        var current:LinkedNode<PuzzleNode> = rowsAndColumns.lateralHead
        var numRows = current.countColumn()
        var minColumn: LinkedNode<PuzzleNode>?
        if numRows == 1 {
            return nil
        }
        current = current.right!
        
        while current.latOrder != latHeadOrder {
            let count = current.countColumn()
            if count == 1 {
                return nil
            }
            if count == 2 && minColumn == nil {
                minColumn = current
            }
            
            if count < numRows {
                numRows = count
            }
            current = current.right!
        }
        if let nextCol = minColumn {
            return nextCol.down!
        }
        
        var possibleChoices: [LinkedNode<PuzzleNode>] = []
        
        current = rowsAndColumns.lateralHead
        if current.countColumn() == numRows {
            possibleChoices.append(current)
        }
        current = current.right!
        while current.latOrder != latHeadOrder {
            if current.countColumn() == numRows {
                possibleChoices.append(current)
            }
            current  = current.right!
        }
        
        let random1 = Int(arc4random_uniform((UInt32(possibleChoices.count-1))))
        current = possibleChoices[random1]
        
        let random2 = Int(arc4random_uniform(UInt32(numRows-1)))+1
        var count = 0
        
        while count != random2 {
            current = current.down!
            count++
        }
        
        return current

    }
    /*
    private func selectRandom() -> LinkedNode<PuzzleNode>? {
       // print(rowsAndColumns.lateralCount())
        var current = rowsAndColumns.lateralHead
        let start = current.latOrder
        var availableColumns:[LinkedNode<PuzzleNode>] = []
        
        
       if current.countColumn() == 0 {
            return nil
       } else if current.countColumn() == 1 {
            return nil
       } else {
            availableColumns.append(current)
        }
        current = current.right!
        
        while current.latOrder != start {
            let count = current.countColumn()
            if count == 0 {
                return nil
            } else if count == 1{
                return nil
            } else {
                availableColumns.append(current)
            }
            current = current.right!
        }
        
        
        let random = Int(arc4random_uniform(UInt32(availableColumns.count)-1))
    
        current = availableColumns[random]
    
        let random2 = Int(arc4random_uniform(UInt32(current.countColumn()-1)))+1
        var count = 0
        
        while count != random2 {
            current = current.down!
            count++
        }
        
        return current
    }
    */
    
    func solveForRow(row: LinkedNode<PuzzleNode>, root: Int = 1) -> Choice {
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
        
        return (row, columnList, removedRows, root)
    }
    
    func coverColumn(column: LinkedNode<PuzzleNode>)->[LinkedNode<PuzzleNode>] {
        var rowsToRemove: [LinkedNode<PuzzleNode>] = []
        var current = column.down!
        while current.vertOrder != 0 {
            rowsToRemove.append(current)
            current = current.down!
        }
        rowsAndColumns.removeLateralLink(current)
        return rowsToRemove
    }
    
    func removeRow(row: LinkedNode<PuzzleNode>) {
        var current = row.getLateralHead().right!
        while current.latOrder !=  0 {
            current.up!.down = current.down
            current.down!.up = current.up
            current = current.right!
        }
        
        rowsAndColumns.removeVerticalLink(current)
    }
    
    func insertRow(row: LinkedNode<PuzzleNode>) {
        var current = row.getLateralHead().right!
        while current.latOrder != 0 {
            current.up!.down = current
            current.down!.up = current
            current = current.right!
        }
        rowsAndColumns.insertVerticalLink(current)
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
                let node = PuzzleNode(row: rowIndex, column: columnIndex)
                rowsAndColumns.addLateralLink(node)
            }
        }
        
    }
    
    private func buildColumnConstraints(){
        for aValue in 1...9 {
            for columnIndex in 1...9 {
                let node = PuzzleNode(value: aValue, column: columnIndex)
                rowsAndColumns.addLateralLink(node)
            }
        }
    }
    
    private func buildRowConstraints() {
        for aValue in 1...9 {
            for rowIndex in 1...9 {
                let node = PuzzleNode(value: aValue, row: rowIndex)
                rowsAndColumns.addLateralLink(node)
            }
        }
    }
    
    private func buildBoxConstraints() {
        for aValue in 1...9 {
            for boxIndex in 1...9 {
                let node = PuzzleNode(value: aValue, box: boxIndex)
                rowsAndColumns.addLateralLink(node)
            }
        }
    }
    
    private func buildRowChoices() {
        for rowIndex in 1...9 {
            for columnIndex in 1...9 {
                for aValue in 1...9 {
                    let node = PuzzleNode(value: aValue, column: columnIndex, row: rowIndex, box: getBox(columnIndex, row: rowIndex))
                    rowsAndColumns.addVerticalLink(node)
                }
            }
        }
    }
    
    private func buildOutMatrix() {
        var rowHead:LinkedNode<PuzzleNode>? = rowsAndColumns.verticalHead
        var constHead:LinkedNode<PuzzleNode>? = rowsAndColumns.lateralHead
        while rowHead != nil {
            if rowHead!.countRow() > 1 {
                break
            }
            var count = 0
            while constHead != nil && count < 1 {
                if constHead!.right!.latOrder == 0 {
                    count++
                }
                if rowHead!.key! == constHead!.key! {
                    let newKey = PuzzleNode(node: constHead!.key!)
                    let newNode = LinkedNode(key: newKey)
                    rowsAndColumns.addLateralLinkFromNode(rowHead!.getLateralTail(), toNewNode: newNode)
                    rowsAndColumns.addVerticalLinkFromNode(constHead!.getVerticalTail(), toNewNode: newNode)
                }
                constHead!.getVerticalTail().down = constHead!.getVerticalHead()
                constHead = constHead!.right
            } // end second while loop
            rowHead!.getLateralTail().right = rowHead!.getLateralHead()
            rowHead = rowHead!.down
            constHead = rowsAndColumns.lateralHead
            
        } // end first while loop
    }
    
    
    // matches given values against row choices -- move this to linked list class def
    private func findRowMatch(mRow: PuzzleNode) -> LinkedNode<PuzzleNode> {
    
        var current = rowsAndColumns.verticalHead.up!
        
        while current.vertOrder != rowsAndColumns.verticalHead.vertOrder {
            if current.key! == mRow {
                return current
            }
            current = current.up!
        }
        
        return current
    }

}



