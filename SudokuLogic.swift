//
//  SudokuLogic.swift
//  SudokuCheat
//
//  Created by Isaac Benham on 4/17/15.
//  Copyright (c) 2015 Isaac Benham. All rights reserved.
//

import UIKit






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
            let initialChoice = self.selectRowToSolve()!
            
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
        
        if let bestColumn = selectRowToSolve() {
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
            if let next = selectRowToSolve() {
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

            if let next = selectRowToSolve() {
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
    
    private func selectRowToSolve() -> LinkedNode<PuzzleKey>? {
    
        var currentColumn:LinkedNode<PuzzleKey> = matrix.lateralHead.left!
        var minColumns: [LinkedNode<PuzzleKey>] = []
        var minRows = currentColumn.countColumn()
        let last = currentColumn.key
       
        
        repeat {
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
        }  while currentColumn.key != last
        
        func rowRandomizer() -> LinkedNode<PuzzleKey> {
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
        
        return rowRandomizer()

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



