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
    
    func containsNode(node: LinkedNode<T>) -> Bool {
        
        if !(node.up?.down?.vertOrder == node.vertOrder) {
            return false
        }
        
        if !(node.down?.up?.vertOrder == node.vertOrder) {
            return false
        }
        
        if !(node.left?.right?.latOrder == node.latOrder) {
            return false
        }
        
        if !(node.right?.left?.latOrder == node.latOrder) {
            return false
        }
        
        return true
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
        link.left?.right = link.right
        if link.latOrder == lateralHead.latOrder {
            if let newHead = link.right {
                if newHead.latOrder != link.latOrder {
                    lateralHead = newHead
                } else {
                    lateralHead = LinkedNode<T>()
                }
                lateralHead = newHead
            } else {
                lateralHead = LinkedNode<T>()
            }
        }
        link.right?.left = link.left
    }
    func removeVerticalLink(link: LinkedNode<T>) {
        link.up?.down = link.down
        if link.vertOrder == verticalHead.vertOrder {
            if let newHead = link.down {
                if newHead.vertOrder != link.vertOrder {
                    verticalHead = newHead
                } else {
                    verticalHead = LinkedNode<T>()
                }
            } else {
                verticalHead = LinkedNode<T>()
            }
        }
        link.down?.up = link.up
    }
    
    
    func insertLateralLink(link: LinkedNode<T>) {
        if lateralHead.key == nil {
            lateralHead = link
        }
        link.left?.right = link
        link.right?.left = link
        if link.latOrder <= lateralHead.latOrder {
            lateralHead = link
        }
    }
    
    func insertVerticalLink(link: LinkedNode<T>) {
        if verticalHead.key == nil {
            verticalHead = link
        }
        link.up?.down = link
        link.down?.up = link
        if link.vertOrder <= verticalHead.vertOrder {
            verticalHead = link
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
        var top: LinkedNode<T> = self.getVerticalHead()
        var count = 1
        while top.down != nil {
            if top.down!.vertOrder == self.getLateralHead().vertOrder {
                break
            }
            count++
            top = top.down!
        }
        return count
    }
    
    func countRow() -> Int {
        var current = self.getLateralHead()
        var count = 1
        while current.right != nil{
            if current.right!.latOrder == 0 {
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
    
    var allNodes:[LinkedNode<PuzzleNode>] = []
    
    var rowsAndColumns = LinkedList<PuzzleNode>()
    typealias Choice = (Row: LinkedNode<PuzzleNode>, Columns:[LinkedNode<PuzzleNode>])
    private var currentSolution = [Choice]()
    typealias Solution = [LinkedNode<PuzzleNode>]
    private var solutions = [Solution]()
    
    init() {
        constructMatrix()
        buildOutMatrix()
        //eliminatePuzzleGivens(initialValues)
    }
    
    func solutionForValidPuzzle(puzzle: [PuzzleCell]) -> [PuzzleCell]? {
        eliminatePuzzleGivens(puzzle)
        if countPuzzleSolutions() != 1 {
            return nil
        }
        let nodes = solutions[0]
        return cellsFromConstraints(nodes)
    }
    
   func eliminatePuzzleGivens(cells: [PuzzleCell]) {
        let givenValues = translateCellsToConstraintList(cells)
        var rowsToSolve = [LinkedNode<PuzzleNode>]()
        
        for val in givenValues {
            let solvedRow = findRowMatch(val).right!
            
            rowsToSolve.append(solvedRow)
        }
        
        for row in rowsToSolve {
            solveForRow(row)
        }
        
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
        let lH = rowsAndColumns.lateralHead
        if let latHeadDown = lH.down {
            if latHeadDown.vertOrder != lH.vertOrder {
                return false
            }
        }
        if let latHeadRight = lH.right {
            if latHeadRight.latOrder != lH.latOrder {
                return false
            }
        }
        return true
    }
    
    private func addSolution() {
        var solution: [LinkedNode<PuzzleNode>] = []
        
        for choice in currentSolution {
            solution.append(choice.Row.getLateralHead())
        }
        
        solutions.append(solution)
    }

    
    private func allSolutionsForPuzzle(rowChoice:LinkedNode<PuzzleNode>, andCount count:Int = 0, withCutOff cutOff:Int = 2) -> Int {
        
        if count == cutOff {
            return cutOff
        }
        
        let eliminated = solveForRow(rowChoice)
        
        currentSolution.append(eliminated)
        
        
        if solved() {
            addSolution()
            if let next = findNextRowChoice() {
                return allSolutionsForPuzzle(next, andCount: count+1)
            } else {
                return count+1
            }
        } else {
            if let next = selectColumn()?.down {
                return allSolutionsForPuzzle(next, andCount: count)
            } else {
                if let next = findNextRowChoice() {
                    return allSolutionsForPuzzle(next, andCount: count)
                } else {
                    return count
                }
            }
        }
    }
    
    private func findNextRowChoice()->LinkedNode<PuzzleNode>? {
        if let lastChoice = unchooseLast() {
            if lastChoice.down?.vertOrder == 0 {
                return findNextRowChoice()
            } else {
                return lastChoice.down
            }
        }
        return nil
    }
    
    private func unchooseLast() -> LinkedNode<PuzzleNode>? {
        if currentSolution.count == 0 {
            return nil
        }
        
        let lastChoice:Choice = self.currentSolution.removeLast()
        
        
        for col in lastChoice.Columns
        {
            self.insertColumn(col)
        }
        return lastChoice.Row
    }
    
    // grabs the next best column.  might want to combine this with check columns to create a function that checks if there are any possible solutions and then returns the next best guess, which would be an optional
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
    
    func solveForRow(row: LinkedNode<PuzzleNode>) -> Choice {
        var columnList: [LinkedNode<PuzzleNode>] = []
        var current = row.getLateralHead().right!
        while current.latOrder != 0 {
            removeColumn(current)
            columnList.append(current.getVerticalHead())
            current = current.right!
        }
        
        return (row, columnList)
    }
    
    func removeColumn(column: LinkedNode<PuzzleNode>) {
        var current = column.getVerticalHead().down!
        while current.vertOrder != 0 {
            removeRow(current, preservingColumn: current)
            current = current.down!
        }
        current = column.getVerticalHead()
        rowsAndColumns.removeLateralLink(current)
        current = current.down!
        while current.vertOrder != 0 {
            current.left?.right = current.right
            current.right?.left = current.left
            current = current.down!
        }
    }
    
    func removeRow(row: LinkedNode<PuzzleNode>, preservingColumn column: LinkedNode<PuzzleNode>) {
        if row.vertOrder == 0 {
            println("this isn't right")
        }
        var current = row.getLateralHead()
        rowsAndColumns.removeVerticalLink(current)
        current = current.right!
        while current.latOrder != column.latOrder {
            current.up?.down = current.down
            current.down?.up = current.up
            current = current.right!
        }
        current = current.right!
        while current.latOrder != 0 {
            current.up?.down = current.down
            current.down?.up = current.up
            current = current.right!
        }
    }
    
    func insertColumn(column: LinkedNode<PuzzleNode>){
        var current = column.getVerticalHead()
        rowsAndColumns.insertLateralLink(current)
        current = current.up!
        
        while current.vertOrder != 0 {
            current.left?.right = current
            current.right?.left = current
            self.insertRow(current)
            current = current.up!
        }
    }
    
    func insertRow(row: LinkedNode<PuzzleNode>) {
        var current = row.getLateralHead()
        rowsAndColumns.insertVerticalLink(current)
        current = current.right!
        while current.latOrder != 0 {
            current.up?.down = current
            current.down?.up = current
            current = current.right!
        }
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
            allNodes.append(rowHead!)
            var count = 0
            while constHead != nil && count < 1 {
                if constHead!.right!.latOrder == 0 {
                    count++
                }
                allNodes.append(constHead!)
                if rowHead!.key! == constHead!.key! {
                    let newKey = PuzzleNode()
                    newKey.constraint = constHead!.key!.constraint
                    let newNode = LinkedNode<PuzzleNode>()
                    newNode.key = newKey
                    rowsAndColumns.addLateralLinkFromNode(rowHead!.getLateralTail(), toNewNode: newNode)
                    rowsAndColumns.addVerticalLinkFromNode(constHead!.getVerticalTail(), toNewNode: newNode)
                    allNodes.append(newNode)
                }
                constHead!.getVerticalTail().down = constHead!.getVerticalHead()
                constHead = constHead!.right
            } // end second while loop
            rowHead!.getLateralTail().right = rowHead!.getLateralHead()
            rowHead = rowHead!.down
            constHead = rowsAndColumns.lateralHead
            
        } // end first while loop
    }
    
    func findRowMatch(mRow: Constraint) -> LinkedNode<PuzzleNode> {
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
    
    func translateCellsToConstraintList(cells:[PuzzleCell])->[Constraint] {
        var matrixRowArray = [Constraint]()
        for cell in cells {
            let cIndex = cell.column
            let rIndex = cell.row
            let mRow:Constraint = (cell.value, cIndex, rIndex, getBox(cIndex, rIndex))
            matrixRowArray.append(mRow)
        }
        return matrixRowArray
    }
}





