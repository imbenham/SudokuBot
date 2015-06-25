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
    
    init() {
        verticalHead = LinkedNode<T>()
        verticalHead.up = verticalHead
        verticalHead.down = verticalHead
        lateralHead = LinkedNode<T>()
        lateralHead.left = lateralHead
        lateralHead.right = lateralHead
        
    }
    
    func addLateralLink(key: T) {
        if self.lateralHead.key == nil {
            lateralHead.key = key
            return
        }
        
        var current: LinkedNode<T>? = lateralHead
        
        while current != nil {
            if current!.right == nil {
                var newLink = LinkedNode<T>()
                
                newLink.key = key
                newLink.left = current
                current!.getLateralHead().left = newLink
                current!.right = newLink
                newLink.latOrder = current!.latOrder+1
                newLink.right = newLink.getLateralHead()
                break
            } else if current!.right!.latOrder == 0 {
                var newLink = LinkedNode<T>()
                
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
                var newLink = LinkedNode<T>()
                
                newLink.key = key
                newLink.up = current
                current!.getVerticalHead().up = newLink
                current!.down = newLink
                newLink.vertOrder = current!.vertOrder+1
                newLink.down = newLink.getVerticalHead()
                break
            } else if current!.down!.vertOrder == 0 {
                var newLink = LinkedNode<T>()
                
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
        println(verticalHead.vertOrder)
        var current = verticalHead.down
        var prevOrder = 0
        while current != nil {
            if current!.vertOrder == verticalHead.vertOrder {
                break
            }
            
            var countString = "- "
            if current!.countRow() != 5 {
                countString += String(current!.countRow())
            }

            let numRow = current!.vertOrder
            
            if prevOrder + 1 != numRow {
                 println("Jumps to: \(numRow)"+countString)
            } else {
                println("\(numRow)" + countString)
            }
            
            prevOrder = numRow
            current = current!.down
        }
    }
    
    func printColumnHeadOrders() {
        println(lateralHead.latOrder)
        var current = lateralHead.right
        var prevOrder = 0
        while current != nil {
            if current!.latOrder == lateralHead.latOrder {
                break
            }
            
            var countString = "- "
            if current!.countColumn() != 10 {
                countString += String(current!.countColumn())
            }
            let numCol = current!.latOrder
            if prevOrder + 1 != numCol {
                println("Jumps to: \(numCol)"+countString)
            } else {
                println("\(numCol)" + countString)
            }
            
            prevOrder = numCol
            current = current!.right
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
}

typealias Constraint = (Value: Int?, Column: Int?, Row: Int?, Box: Int?)

class PuzzleNode {
    var constraint: Constraint = (nil, nil, nil, nil)
    var inserted = 0
    var removed = 0
}

func == (lhs:PuzzleNode, rhs:PuzzleNode) -> Bool {
    var boolList = [Bool]()
    if let val1 = lhs.constraint.Value {
        if let val2 = rhs.constraint.Value {
            boolList.append(val1==val2)
        }
    }
    
    if let row1 = lhs.constraint.Row {
        if let row2 = rhs.constraint.Row {
            boolList.append(row1==row2)
        }
    }
   
    if let col1 = lhs.constraint.Column{
        if let col2 = rhs.constraint.Column {
            boolList.append(col1==col2)
        }
    }
    
    if let box1 = lhs.constraint.Box {
        if let box2 = rhs.constraint.Box {
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


class Matrix {
    
    var rowsAndColumns = LinkedList<PuzzleNode>()
    typealias Choice = (Chosen: LinkedNode<PuzzleNode>, Columns:[LinkedNode<PuzzleNode>], Root:Int)
    private var currentSolution = [Choice]()
    typealias Solution = [LinkedNode<PuzzleNode>]
    private var solutions = [Solution]()
    
    init() {
        constructMatrix()
        buildOutMatrix()
        //eliminatePuzzleGivens(initialValues)
    }
    
    func rebuild() {
        /*
        rowsAndColumns = LinkedList<PuzzleNode>()
        constructMatrix()
        buildOutMatrix()
        solutions = []
    */
        while currentSolution.count != 0 {
            unchooseLast()
        }
        
    }
    
    func generatePuzzle()->[PuzzleCell]? {
        var puzz: [PuzzleCell] = []
        let initialChoice = selectRandom()!
        
        if !findFirstSolution(initialChoice, root: initialChoice.vertOrder) {
            return nil
        }
        
        rebuild()
        
        puzz = cellsFromConstraints(solutions[0])
        // test 2
        println("solutions should have 81 objects and actually has \(puzz.count)")
        
        
        puzz.removeRange(Range(start:1,end:39))
        
        let last = puzz.removeLast()
        
        puzz = minValuesForPuzzle(puzz, withLastRemoved: last)
        
        return puzz
    }
    
    func minValuesForPuzzle(allVals:[PuzzleCell], withLastRemoved lastRemoved:PuzzleCell) -> [PuzzleCell] {
        var initials = allVals
        
        eliminatePuzzleGivens(allVals)
        
        if countPuzzleSolutions() == 1 {
            rebuild()
            let last = initials.removeLast()
            return minValuesForPuzzle(initials, withLastRemoved: last)
        }
        
        initials.append(lastRemoved)

        return initials
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
            solveForRow(row, root: row.vertOrder)
        }
    
        return rowsAndColumns.verticalCount()
        
    }
    
    
    func countPuzzleSolutions() -> Int {
        let bestColumn = selectColumn()
        
        if self.solved() {
            return 1
        }
        
        if let bcDown = bestColumn?.down {
            return allSolutionsForPuzzle(bcDown)
        }
        
        return 0
    }
    

    private func solved() -> Bool {
        
        if rowsAndColumns.lateralCount() == 1 {
            return true
        }
        
        return false
        var current = rowsAndColumns.lateralHead
        let start = current.latOrder
        if current.down!.down!.vertOrder != current.vertOrder {
            return false
        }
        current = current.right!
        
        while current.latOrder != start {
            if current.down!.down!.vertOrder != current.vertOrder {
                return false
            }
            current = current.right!
        }
        return true
    }
    
    private func addSolution() {
        var solution: [LinkedNode<PuzzleNode>] = []
        
        for choice in currentSolution {
            solution.append(choice.Chosen.getLateralHead())
        }
        
        solutions.append(solution)
    }
  
    private func allSolutionsForPuzzle(rowChoice:LinkedNode<PuzzleNode>, andCount count:Int = 0, withCutOff cutOff:Int = 2, andRoot root:Int = 0) -> Int {
        
        if count == cutOff {
            return cutOff
        }
        
        let eliminated = solveForRow(rowChoice)
        
        currentSolution.append(eliminated)
        
        
        if solved() {
            addSolution()
            if let next = findNextRowChoice() {
                return allSolutionsForPuzzle(next.Node, andCount: count+1)
            } else {
                return count+1
            }
        } else {
            if let next = selectColumn()?.down {
                return allSolutionsForPuzzle(next, andCount: count)
            } else {
                if let next = findNextRowChoice() {
                    return allSolutionsForPuzzle(next.Node, andCount: count)
                } else {
                    return count
                }
            }
        }
    }

    
    private func findFirstSolution(rowChoice:LinkedNode<PuzzleNode>, root: Int) -> Bool {
       /*
        if currentSolution.count >= 50 {
            
            let eliminated = solveForRow(rowChoice, root: root)
            
            currentSolution.append(eliminated)
            
            let last = unchooseLast()
            
            rowsAndColumns.printColumnHeadOrders()
            
        }
    
*/
        
        let eliminated = solveForRow(rowChoice, root: root)
        
        currentSolution.append(eliminated)
        
    
  
        if currentSolution.count >= 75 {
            
            rowsAndColumns.printColumnHeadOrders()
            //rowsAndColumns.printRowHeadOrders()
            
            unchooseLast()
            
            rowsAndColumns.printColumnHeadOrders()
            //rowsAndColumns.printRowHeadOrders()

        }

        

        
        if currentSolution.count >= 80 {
            
            println("getting close")
        }
        
        if solved() {
            
            addSolution()
           return true
        } else {
            if let next = selectRandom() {
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
        if let lastChoice = unchooseLast() {
            let next = lastChoice.Chosen.down!
            return (next, lastChoice.Root)
        }
        return nil
    }
    
    private func unchooseLast() -> Choice? {
        let csCount = currentSolution.count
        if csCount == 0 {
            return nil
        }
    
        let lastChoice:Choice = self.currentSolution.removeLast()
        
        let lcDown = lastChoice.Chosen.down!
        
        for col in lastChoice.Columns
        {
            insertColumn(col)
        }
        var current = lastChoice.Chosen // YOU ARE ALSO HERE--NEED TO FIX REINSERTION
        
        if lcDown.vertOrder == 0 {
            return unchooseLast()
        }
       
        return lastChoice
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
        if minColumn != nil {
            return minColumn
        }
        
        current = rowsAndColumns.lateralHead
        while current.latOrder != latHeadOrder {
            if current.countColumn() == numRows {
                break
            }
            current  = current.right!
        }
        
        return current
    }
    
    private func selectRandom() -> LinkedNode<PuzzleNode>? {
        var current = rowsAndColumns.lateralHead
        let start = current.latOrder
        var availableColumns:[LinkedNode<PuzzleNode>] = []
        
        
       if current.countColumn() == 1 {
            return nil
       } else {
            availableColumns.append(current)
        }
        current = current.right!
        
        while current.latOrder != start {
            let count = current.countColumn()
            if count == 1 {
                return nil
            } else {
                availableColumns.append(current)
            }
            current = current.right!
        }
        
        println("available columns: \(availableColumns.count)")
        
        let random = Int(arc4random_uniform(UInt32(availableColumns.count)-1))
    
        current = availableColumns[random]
        
        /*
        let random2 = Int(arc4random_uniform(UInt32(current.countColumn()-1)))+1
        var count = 0
        
        while count != random2 {
            current = current.down!
            count++
        }*/
        
        return current.down!
        
    }
    
    func solveForRow(row: LinkedNode<PuzzleNode>, root: Int = 0) -> Choice {
        // YOU ARE HERE.  YOU JUST CHANGED TO SOLVING FOR THE CHOSEN ROW'S COLUMN FIRST, RATHER THAN THE FIRST COLUMN FROM THE LEFT
        var columnList: [LinkedNode<PuzzleNode>] = [row]
        var current = row.right!
        while current.latOrder != row.latOrder {
            if row.latOrder != 0 {
                columnList.append(current)
            }
            
            current = current.right!
        }
      
        for column in columnList {
            rowsAndColumns.removeLateralLink(column.getVerticalHead())
            let rowsToRemove = coverColumn(column)
            
            for row in rowsToRemove {
                removeRow(row)
            }
        }
        
        /*
       for row in rowList {
            removeRow(row)
        }*/
        
        return (row, columnList, root)
    }
    
    func coverColumn(column: LinkedNode<PuzzleNode>)->[LinkedNode<PuzzleNode>] {
        var current = column
        var rowsToRemove: [LinkedNode<PuzzleNode>] = []
        while current.vertOrder != column.vertOrder {
            if current.vertOrder != 0 {
                rowsToRemove.append(current)
            }
            current = current.down!
        }
    
        return rowsToRemove
    }
    
    func removeRow(row: LinkedNode<PuzzleNode>) {
        let rowOrder = row.latOrder
        var current = row.right!
        
        /*while current.latOrder != column.latOrder {
            current.up?.down = current.down
            current.down?.up = current.up
            current = current.right!
        }*/
        //current = current.right!
        while current.latOrder !=  rowOrder{
            rowsAndColumns.removeVerticalLink(current)
            current = current.right!
        }
        
    }
    
    
    func insertColumn(column: LinkedNode<PuzzleNode>){
       
        var current = column.up!
        
        while current.vertOrder != column.vertOrder {
            if current.vertOrder != 0 {
                insertRow(current)
            }
            current = current.up!
        }
        rowsAndColumns.insertLateralLink(current)
        
    }

    func insertRow(row: LinkedNode<PuzzleNode>) {
        var current = row.getLateralHead().left!
        while current.latOrder != 0 {
            current.up?.down = current
            current.down?.up = current
            current = current.left!
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
    }
    
    private func buildCellConstraints(){
        for columnIndex in 1...9 {
            for rowIndex in 1...9 {
                var node = PuzzleNode()
                node.constraint = (nil, columnIndex, rowIndex, nil)
                rowsAndColumns.addLateralLink(node)
            }
        }
        
    }
    
    private func buildColumnConstraints(){
        for aValue in 1...9 {
            for columnIndex in 1...9 {
                var node = PuzzleNode()
                node.constraint = (aValue, columnIndex, nil, nil)
                rowsAndColumns.addLateralLink(node)
            }
        }
    }
    
    private func buildRowConstraints() {
        for aValue in 1...9 {
            for rowIndex in 1...9 {
                var node = PuzzleNode()
                node.constraint = (aValue, nil, rowIndex, nil)
                rowsAndColumns.addLateralLink(node)
            }
        }
    }
    
    private func buildBoxConstraints() {
        for aValue in 1...9 {
            for boxIndex in 1...9 {
                var node = PuzzleNode()
                node.constraint = (aValue, nil, nil, boxIndex)
                rowsAndColumns.addLateralLink(node)
                
            }
        }
    }
    
    private func buildRowChoices() {
        for rowIndex in 1...9 {
            for columnIndex in 1...9 {
                for aValue in 1...9 {
                    var node = PuzzleNode()
                    node.constraint = (aValue, columnIndex, rowIndex, getBox(columnIndex, rowIndex))
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
                    let newKey = PuzzleNode()
                    newKey.constraint = constHead!.key!.constraint
                    let newNode = LinkedNode<PuzzleNode>()
                    newNode.key = newKey
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
    
    
    // only use these functions for initial matrix set up
    private func findRowMatch(mRow: Constraint) -> LinkedNode<PuzzleNode> {
    let aNode = matchValueWithinCell(mRow, node: findFirstNodeOfSameColumn(mRow, node: findFirstNodeOfSameRow(mRow, node: rowsAndColumns.verticalHead)))
    
    return aNode
    
    }
    
    private func jumpVerticallyFromNode(node: LinkedNode<PuzzleNode>, numberOfSpaces spaces:Int) -> LinkedNode<PuzzleNode> {
    var count = 0
    var currentNode = node
    while count < spaces {
    if currentNode.down != nil {
    currentNode = currentNode.down!
    }
    count++
    }
    return currentNode
    }
    
    private func findFirstNodeOfSameColumn(mRow:Constraint, node:LinkedNode<PuzzleNode>) -> LinkedNode<PuzzleNode> {
    let currentColumn = node.key!.constraint.Column!
    if mRow.Column! != node.key!.constraint.Column! {
    return findFirstNodeOfSameColumn(mRow, node: jumpVerticallyFromNode(node, numberOfSpaces:9))
    }
    
    return node
    
    }
    
    private func findFirstNodeOfSameRow(mRow: Constraint, node:LinkedNode<PuzzleNode>) -> LinkedNode<PuzzleNode> {
    let currentRow = node.key!.constraint.Row!
    if mRow.Row! != node.key!.constraint.Row! {
    return findFirstNodeOfSameRow(mRow, node: jumpVerticallyFromNode(node, numberOfSpaces:81))
    }
    return node
    }
    
    private func matchValueWithinCell(mRow: Constraint, node:LinkedNode<PuzzleNode>) -> LinkedNode<PuzzleNode> {
    if mRow.Value! != node.key!.constraint.Value! {
    return matchValueWithinCell(mRow, node: node.down!)
    }
    
    return node
    }
    
}





