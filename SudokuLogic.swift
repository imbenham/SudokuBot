//
//  SudokuLogic.swift
//  SudokuCheat
//
//  Created by Isaac Benham on 4/17/15.
//  Copyright (c) 2015 Isaac Benham. All rights reserved.
//

import UIKit


class LinkedList<T:Equatable> {
    private var verticalHead: LinkedNode<T> = LinkedNode<T>()
    private var lateralHead: LinkedNode<T> = LinkedNode<T>()
    
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
                current!.right = newLink
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
                current!.down = newLink
                newLink.order = current!.order+1
                break
            }
            current = current?.down
        }
    }
    
    
    func addLateralLinkFromNode(node: LinkedNode<T>, toNode: LinkedNode<T>) {
        /*
        if containsNode(node) {
            node.right = toNode
            toNode.left = node
        }*/
        node.right = toNode
        toNode.left = node
    }
    
    func addVerticalLinkFromNode(node: LinkedNode<T>, toNode: LinkedNode<T>) {
        /*if containsNode(node) {
            node.down = toNode
            toNode.up = node
        }*/
        toNode.order = node.order+1
        node.down = toNode
        toNode.up = node
    }
    
    func containsNode(node: LinkedNode<T>) -> Bool {
        
        if let lhKey = lateralHead.key {
            if node.getLateralHead().key! == lhKey {
                return true
            }
            if node.getVerticalHead().getLateralHead().key! == lhKey {
                return true
            }
        }
        
        if let vhKey =  verticalHead.key {
            if node.getVerticalHead().key! == vhKey {
                return true
            }
            if node.getLateralHead().getVerticalHead().key! == vhKey {
                return true
            }
        }
        
        return false
    }
    
    func verticalCount() -> Int {
        var current:LinkedNode<T>? = verticalHead
        var count = 0
        while current != nil {
            count++
            current = current!.down
        }
        return count
    }
    
    
    func lateralCount() -> Int {
        var current:LinkedNode<T>? = lateralHead
        var count = 0
        while current != nil {
            count++
            current = current!.right
        }
        return count
    }

    
    func removeLateralLink(link: LinkedNode<T>) {
        let leftNeighbor = link.left
        let rightNeighbor = link.right
        
        if leftNeighbor == nil {
            if rightNeighbor == nil {
                lateralHead = LinkedNode<T>()
            } else {
                rightNeighbor!.left = nil
                lateralHead = rightNeighbor!
            }
        } else {
            leftNeighbor!.right = link.right
            if rightNeighbor != nil {
                rightNeighbor!.left = leftNeighbor
            }
        }
    }
    func removeVerticalLink(link: LinkedNode<T>) {
        let topNeighbor = link.up
        let bottomNeighbor = link.down
        
        if topNeighbor == nil {
            if bottomNeighbor == nil {
                verticalHead = LinkedNode<T>()
            } else {
                bottomNeighbor!.up = nil
                verticalHead = bottomNeighbor!
            }
        } else {
            topNeighbor!.down = bottomNeighbor
        }
    }
    
    
    func lateralHeadDescription() -> String {
        if self.lateralHead.key != nil {
            return "\(self.lateralHead.key)"
        }
        return "I'm laterally headless!"
    }
    
    func verticalNodeList() -> [LinkedNode<T>] {
        var current:LinkedNode<T>? = verticalHead
        var nodeList = [LinkedNode<T>]()
        while current != nil {
            nodeList.append(current!)
            current = current!.down
        }
        return nodeList
    }
    
    func lateralNodeList() -> [LinkedNode<T>] {
        var current:LinkedNode<T>? = lateralHead
        var nodeList = [LinkedNode<T>]()
        while current != nil {
            nodeList.append(current!)
            current = current!.right
        }
        return nodeList
    }
 
    
    func printRowsAndColumns() {
        var lH: LinkedNode<T>? = lateralHead
        var count = 1
        while lH != nil {
            println("Col. \(count) has \(lH!.countColumn()) values")
            count++
            lH = lH!.right
        }
    }
}

class LinkedNode<T> {
    var key: T? = nil
    var left: LinkedNode<T>? = nil
    var right: LinkedNode<T>? = nil
    var up: LinkedNode<T>? = nil
    var down: LinkedNode<T>? = nil
    var selectedHead = false
    var order: Int = 0
    
    
    func countColumn() -> Int {
        var top: LinkedNode<T>? = self.getVerticalHead()
        var count = 1
        while top!.down != nil {
            count++
            top = top!.down
        }
        //println("Column count = \(count)")
        return count
    }
    
    func countRow() -> Int {
        var start: LinkedNode<T>? = self.getLateralHead()
        var count = 0
        while start != nil {
            count++
            start = start?.right
        }
        return count
    }
    
    func getVerticalHead() -> LinkedNode<T> {
        var current = self
        
        while current.up != nil {
            current = current.up!
        }
        
        return current
    }
    
    func getLateralHead() -> LinkedNode<T> {
        var current = self
        while current.left != nil {
            current = current.left!
        }
        return current
    }
    
    func getVerticalTail() -> LinkedNode<T> {
        var current = self
        while current.down != nil {
            current = current.down!
        }
        return current
    }
    
    func getLateralTail() -> LinkedNode<T> {
        var current:LinkedNode<T> = self
        while current.right != nil {
            current = current.right!
        }
        return current
    }
    
    func removed() -> Bool {
       return self.getLateralHead().selectedHead
    }
    
    func fromVertHead() -> Int {
        var current = self
        var count = 0
        
        while current.up != nil {
            current = current.up!
            count++
        }
        
        return count
    }
    
    func fromLatHead() -> Int {
        var current = self
        var count = 0
        while current.left != nil {
            current = current.left!
            count++
        }
        return count
    }
    
    func downOwner() -> LinkedNode<T>? {
        var current: LinkedNode<T>? = self.getVerticalHead()
        
        while current != nil {
            if let cDown = current!.down {
                if cDown.order == self.order {
                    return current
                }
            }
            current = current!.down
        }
        
        return nil
    }
    
    func linkedWithVerticalHead()->Bool {
        var current:LinkedNode<T>? = self.getVerticalHead()
        while current != nil {
            if current!.order == self.order {
                return true
            }
            current = current!.down
        }
        return false
    }
    
    func getNodeAbove() -> LinkedNode<T>? {
        if let nodeUp = self.up {
            var current:LinkedNode<T>? = nodeUp
            while current != nil {
                if current!.linkedWithVerticalHead() {
                    return current
                }
                current = current!.up
            }
        }
        return nil
    }

    func downLink() {
        if let upLink = self.getNodeAbove() {
            if upLink.down != nil {
                let pK = upLink.down!
                upLink.down = self
                pK.downLink()
            } else {
                upLink.down = self
            }
            
        }
    }
}



typealias Constraint = (Value: TileValue?, Column: Int?, Row: Int?, Box: Int?)


class PuzzleNode {
    var constraint: Constraint = (nil, nil, nil, nil)
}

func == (lhs:PuzzleNode, rhs:PuzzleNode) -> Bool {
    var boolList = [Bool]()
    if let val1 = lhs.constraint.Value {
        if let val2 = rhs.constraint.Value {
            boolList.append(val1.rawValue==val2.rawValue)
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

class Puzzle: PFObject, PFSubclassing {
    
    // PFSubclassing
    static func parseClassName() -> String {
        return "Puzzle"
    }
    
    var startingValues: [Cell]
    var board: SudokuBoard
    var matrix = Matrix()
    
    var boxes:[Box]
    var tiles: [Tile]
    var tileRows = [TileValue]()
    var tileColumns = [TileValue]()
    
    
    init(nonNilValues: [Cell], andBoard: SudokuBoard){
        
        startingValues = nonNilValues
        board = andBoard
        let someBoxes = board.boxes as! [Box]
        boxes = someBoxes
        tiles = {
            var mutableTiles = [Tile]()
            for box in someBoxes {
                let containedTiles = box.boxes as! [Tile]
                mutableTiles.extend(containedTiles)
            }
            return mutableTiles
            }()
        for pair in nonNilValues {
            let index = pair.0
            let value = pair.1
            
            board.tileAtIndex(index).value = value
        }
        super.init()
        
        constructMatrix()
        
        matrix.buildOutMatrix()
        
        matrix.eliminatePuzzleGivens(startingValues)
        
        let numSolutions = matrix.countPuzzleSolutions()
        
        for node in matrix.solutions[0] {
            if let key = node.getLateralHead().key {
                if let matchingTile = tileForConstraint(key) {
                    matchingTile.value = key.constraint.Value!
                }
            }
        }
       
    }
    
    func tileForConstraint(node: PuzzleNode) -> Tile? {
        if let cRow = node.constraint.Row {
            if let cCol = node.constraint.Column {
                for t in tiles {
                    if t.getColumnIndex() == cCol && t.getRowIndex() == cRow {
                        return t
                    }
                }
            }
        }
        return nil
    }
    
    private func constructMatrix() {
        
        buildRowChoices()
        buildCellConstraints()
        buildColumnConstraints()
        buildRowConstraints()
        buildBoxConstraints()
    }
    
    private func buildCellConstraints(){
       // var cellConstraintColumn = LinkedList<PuzzleNode>()
        for columnIndex in 1...9 {
            for rowIndex in 1...9 {
                var node = PuzzleNode()
                node.constraint = (nil, columnIndex, rowIndex, nil)
                matrix.rowsAndColumns.addLateralLink(node)
            }
        }
        
    }
    
    private func buildColumnConstraints(){
        var columnConstraintColumn = LinkedList<PuzzleNode>()
        for aValue in 1...9 {
            for columnIndex in 1...9 {
                var node = PuzzleNode()
                node.constraint = (TileValue(rawValue: aValue)!, columnIndex, nil, nil)
                matrix.rowsAndColumns.addLateralLink(node)
            }
        }
    }
    
    private func buildRowConstraints() {
        var rowConstraintColumn = LinkedList<PuzzleNode>()
        for aValue in 1...9 {
            for rowIndex in 1...9 {
                var node = PuzzleNode()
                node.constraint = (TileValue(rawValue: aValue)!, nil, rowIndex, nil)
                matrix.rowsAndColumns.addLateralLink(node)
            }
        }
    }
    
    private func buildBoxConstraints() {
        var boxConstraintColumn = LinkedList<PuzzleNode>()
        for aValue in 1...9 {
            for boxIndex in 1...9 {
                var node = PuzzleNode()
                node.constraint = (TileValue(rawValue: aValue), nil, nil, boxIndex)
                matrix.rowsAndColumns.addLateralLink(node)

            }
        }
    }
    
    private func buildRowChoices() {
        for rowIndex in 1...9 {
            for columnIndex in 1...9 {
                for aValue in 1...9 {
                    var node = PuzzleNode()
                    node.constraint = (TileValue(rawValue: aValue), columnIndex, rowIndex, getBox(columnIndex, rowIndex))
                    matrix.rowsAndColumns.addVerticalLink(node)
                }
            }
        }
    }
    
    func tilesForColumn(column: Int) -> [Tile] {
        var mutableTiles = [Tile]()
        for tile:Tile in tiles {
            if tile.getColumnIndex() == column {
                mutableTiles.append(tile)
            }
        }
        return mutableTiles
    }
    typealias TileSet = [Int:[TileValue]]
    
    func tilesByColumn() -> TileSet {
        var dict: [Int: [TileValue]] = [1:[TileValue](), 2:[TileValue](), 3:[TileValue](), 4:[TileValue](), 5:[TileValue](), 6:[TileValue](), 7:[TileValue](), 8:[TileValue](), 9:[TileValue]()]
        
        for tile in tiles {
            dict[tile.getColumnIndex()]!.append(tile.value)
        }
        
        return dict
    }
    
    func tilesByRow() -> TileSet {
        var dict: TileSet = [1:[TileValue](), 2:[TileValue](), 3:[TileValue](), 4:[TileValue](), 5:[TileValue](), 6:[TileValue](), 7:[TileValue](), 8:[TileValue](), 9:[TileValue]()]
        
        for tile in tiles {
            dict[tile.getRowIndex()]!.append(tile.value)
        }
        
        return dict
    }
    
    func nonNilTiles(tiles: [Tile])->[Tile]{
        var nonNilTiles = [Tile]()
        for tile in tiles {
            if tile.value != .Nil {
                nonNilTiles.append(tile)
            }
        }
        
        return nonNilTiles
    }
    
    func cellsFromConstraints(constraints: [LinkedNode<PuzzleNode>]) -> [Cell] {
        var puzzleNodes: [PuzzleNode] = []
        for node in constraints {
            if node.key != nil {
                puzzleNodes.append(node.key!)
            }
        }
        
        var cells: [Cell] = []
        for node in puzzleNodes {
            cells.append((getTileIndexForRow(node.constraint.Row!, andColumn: node.constraint.Column!), node.constraint.Value!))
        }
        return cells
    }
}

class Matrix {
    
    var rowsAndColumns = LinkedList<PuzzleNode>()
    typealias Choice = (Node: LinkedNode<PuzzleNode>, NodeList:[LinkedNode<PuzzleNode>])
    private var coveredRows = [Choice]()
    typealias Solution = [LinkedNode<PuzzleNode>]
    private var solutions = [Solution]()

    private func buildOutMatrix() {
        var rowHead:LinkedNode<PuzzleNode>? = rowsAndColumns.verticalHead
        var constHead:LinkedNode<PuzzleNode>? = rowsAndColumns.lateralHead
        while rowHead != nil {
            while constHead != nil {
                if rowHead!.key! == constHead!.key! {
                    let newKey = PuzzleNode()
                    newKey.constraint = constHead!.key!.constraint
                    let newNode = LinkedNode<PuzzleNode>()
                    newNode.key = newKey
                    rowsAndColumns.addLateralLinkFromNode(rowHead!.getLateralTail(), toNode: newNode)
                    rowsAndColumns.addVerticalLinkFromNode(constHead!.getVerticalTail(), toNode: newNode)
                }
                constHead = constHead?.right
            } // end second while loop
            rowHead = rowHead?.down
            constHead = rowsAndColumns.lateralHead
    
        } // end first while loop
    }

    // MARK - removing rows and columns
    private func eliminatePuzzleGivens(cells: [Cell]) {
        let givenValues = translateCellsToConstraintList(cells)
        var rowsToSolve = [LinkedNode<PuzzleNode>]()
        
        for val in givenValues {
            let solvedRow = findRowMatch(val).right!
            
            rowsToSolve.append(solvedRow)
        }
        
        var solvedRows = [LinkedNode<PuzzleNode>]()
        
        for row in rowsToSolve {
            solvedRows += coverRow(row)
        }
        
    }


    func countPuzzleSolutions() -> Int {
        let bestColumn = selectColumn()
        
        if let bcDown = bestColumn.down {
            return allSolutionsForPuzzle(bcDown)
        }
        
        if self.solved() {
            return 1
        }
        return 0
    }
    
    func isValidPuzzle() -> Bool {
        return countPuzzleSolutions() == 1
    }
    
    private func addSolution() {
        var solution: [LinkedNode<PuzzleNode>] = []
        
        for node in currentSolutionList(){
            solution.append(node)
        }
        
        let solCount = solutions.count
        if solCount == 422 || solCount == 421 || solCount == 22  {
            println("Stop!")
        }
        solutions.append(solution)

        println("added solution")
    }
    
   
    
    private func allSolutionsForPuzzle(rowChoice:LinkedNode<PuzzleNode>, andCount count:Int = 0) -> Int {
        
        let eliminated = coverRow(rowChoice)
        
        coveredRows.append((rowChoice, eliminated))
        
        
        if solved() {
            addSolution()
            
            if let next = findNextRowChoice() {
                return allSolutionsForPuzzle(next, andCount: count+1)
            } else {
                return count+1
            }
        } else {
            if checkColumns() {
                let next = selectColumn().down!
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



    // checks if there are any columns without any remaining row choices
    private func checkColumns() -> Bool {
        
        var current: LinkedNode<PuzzleNode>? = rowsAndColumns.lateralHead
        while current != nil {
            if current!.countColumn() < 2 {
                return false
            }
            current = current!.right
        }
        
        return true
    }
    
    private func solved() -> Bool {
        var current: LinkedNode<PuzzleNode>? = rowsAndColumns.lateralHead
        while current != nil {
            if current!.countColumn() != 2 {
                return false
            }
            current = current!.right
        }
        return true
    }
    
    private func columnsEmpty() -> Bool {
        var current: LinkedNode<PuzzleNode>? = rowsAndColumns.lateralHead
        while current != nil {
            if current!.countColumn() > 1 {
                return false
            }
            current = current!.right
        }
        return true
    }
    
    // grabs the next best column.  might want to combine this with check columns to create a function that checks if there are any possible solutions and then returns the next best guess, which would be an optional
    private func selectColumn() -> LinkedNode<PuzzleNode> {
        var current:LinkedNode<PuzzleNode>? = rowsAndColumns.lateralHead
        var numRows = 100
        while current != nil {
            let count = current!.countColumn()
            if count > 2 && count < numRows {
                numRows = count
            }
            current = current!.right
        }
        println(numRows)
        current = rowsAndColumns.lateralHead
        while current != nil {
            if current!.countColumn() == numRows {
                break
            }
            current  = current!.right
        }
        
        return current!
    }
    
    private func findNextRowChoice()->LinkedNode<PuzzleNode>? {
        if let lastChoice = unchooseLast() {
            if let nextChoice = lastChoice.down {
                return nextChoice
            } else {
                return findNextRowChoice()
            }
        }
        return nil
    }
    
    
    private func unchooseLast() -> LinkedNode<PuzzleNode>? {
        if coveredRows.count == 0 {
            return nil
        }
        
        let lastChoice:Choice = self.coveredRows.removeLast()
            
        
        
        for row in lastChoice.NodeList
        {
            self.insertRow(row)
        }
        return lastChoice.Node
    }
    
    
    private func coverRows(rowsToRemove: [LinkedNode<PuzzleNode>]) -> [LinkedNode<PuzzleNode>]{
        var removedColumns: [LinkedNode<PuzzleNode>] = []
        for row in rowsToRemove {
            removedColumns += coverRow(row)
        }
        return removedColumns
        
    }
    
    private func coverRow(rowToKeep: LinkedNode<PuzzleNode>) -> [LinkedNode<PuzzleNode>]{
      
        var removedRows: [LinkedNode<PuzzleNode>] = []
        
        var rowHeadRight = rowToKeep.getLateralHead().right
        
        while rowHeadRight != nil {
            let moreRows = drillToNilSkippingNode(rowHeadRight!)
            removedRows += moreRows
            rowHeadRight = rowHeadRight!.right
        }
        
        return removedRows
    }
    
    private func removeRow(node: LinkedNode<PuzzleNode>) {
        
        if node.up == nil {
            return
        }
        
        var rowHeadRight:LinkedNode<PuzzleNode>? = node.getLateralHead().right
        while rowHeadRight != nil {
            if let downPointer = rowHeadRight!.downOwner() {
                downPointer.down = rowHeadRight!.down
                rowHeadRight!.down = nil
            }
            let count = rowHeadRight!.countColumn()
            rowHeadRight = rowHeadRight!.right
        }
        
    }
    
    private func drillToNilSkippingNode(node: LinkedNode<PuzzleNode>) -> [LinkedNode<PuzzleNode>] {
        var removedRows: [LinkedNode<PuzzleNode>] = []
        var vertHead = node.getVerticalHead().down
        while vertHead != nil {
            if vertHead!.order != node.order {
                removedRows.append(vertHead!)
                removeRow(vertHead!)
            }
            vertHead = vertHead!.down
        }
        
        node.getLateralHead().selectedHead = true
        return removedRows
    }
    
    //
    private func insertRow(node: LinkedNode<PuzzleNode>) {
    
        if node.linkedWithVerticalHead() {
            return
        }
        var rowHead = node.getLateralHead().right
        while rowHead != nil {
            if let rowUp = rowHead!.getNodeAbove() {
                rowHead!.down = rowUp.down
                rowUp.down = rowHead
            }
            rowHead = rowHead!.right
        }
    }
    

    func translateCellsToConstraintList(cells:[Cell])->[Constraint] {
        var matrixRowArray = [Constraint]()
        for cell in cells {
            let cIndex = getColumnIndexFromTileIndex(cell.Index)
            let rIndex = getRowIndexFromTileIndex(cell.Index)
            let mRow:Constraint = (cell.Value, cIndex, rIndex, getBox(cIndex, rIndex))
            matrixRowArray.append(mRow)
        }
        return matrixRowArray
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
        if mRow.Value!.rawValue != node.key!.constraint.Value!.rawValue {
            return matchValueWithinCell(mRow, node: node.down!)
        }
        
        return node
    }
    
    private func countSolvedRows() -> Int {
        var current: LinkedNode<PuzzleNode>? = rowsAndColumns.verticalHead
        var count = 0
        
        while current != nil {
            if current!.selectedHead {
                count++
            }
            current = current!.down
        }
        return count
    }
    
    private func currentSolutionList() -> [LinkedNode<PuzzleNode>] {
        var solutionList: [LinkedNode<PuzzleNode>] = []
        for tup in coveredRows {
            solutionList.append(tup.Node)
        }
        
        return solutionList
    }

}



