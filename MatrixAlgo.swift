//
//  MatrixAlgo.swift
//  SudokuBot
//
//  Created by Isaac Benham on 4/6/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import Foundation

extension Matrix {
    func generatePuzzle() {
        var puzz: [PuzzleCell] = []
        
        let initialChoice = self.selectRowToSolve()!
        
        if !self.findFirstSolution(initialChoice, root: initialChoice.vertOrder) {
            // throw an error?
        }
        
        let sol = self.solutions[0]
        
        puzz = cellsFromConstraints(sol)
        
        self.solutionDict = cellNodeDictFromNodes(sol)
        
        let last = puzz.removeLast()
        
        // get a list of minimal givens that need to be left in the grid for a valid puzzle and a list of all the values that are taken out
        let filtered = self.packagePuzzle(puzz, withLastRemoved: last)
        
        
        //self.rebuild()
        // add removed values from the second list back into the first list until a puzzle of the desired difficulty level is achieved
        // let finished = self.puzzleOfSpecifedDifficulty(difficulty, withGivens: filtered.Givens, andSolution: filtered.Solution)
        puzz = filtered.Givens
        
        let puzzSolution = filtered.Solution
        
        PuzzleStore.sharedInstance.puzzleReady(puzz, solution: puzzSolution)
        
        self.rebuild()

    }
    
    internal func packagePuzzle(allVals:[PuzzleCell], withLastRemoved lastRemoved:PuzzleCell, andTried tried:[PuzzleCell]=[], andSolution solution:[PuzzleCell]=[]) -> (Givens:[PuzzleCell], Solution:[PuzzleCell]) {
        
        var allVals = allVals
        var tried = tried
        var solution = solution
        
        rebuild()
        
        let targetDiff = rawDifficultyForPuzzle
        
        
        //var rowList:[LinkedNode<PuzzleNode>] = []
        let vals = allVals + tried
        let rowList: [LinkedNode<PuzzleKey>] = vals.map({solutionDict![$0]!})
        
        let rawDiff = eliminateRows(rowList);
        
        let numSolutions = countPuzzleSolutions()
        
        if numSolutions != 1 {
            if allVals.isEmpty {
                tried.append(lastRemoved)
                return (tried+allVals, solution)
            }
            
            let random = Int(arc4random_uniform((UInt32(allVals.count))))
            
            let next = allVals.removeAtIndex(random)
            
            tried.append(lastRemoved)
            return packagePuzzle(allVals, withLastRemoved: next, andTried: tried, andSolution: solution)
        }
        
        if rawDiff < targetDiff {
            
            if allVals.isEmpty {
                tried.append(lastRemoved)
                return (tried+allVals, solution)
            }
            
            let random = Int(arc4random_uniform((UInt32(allVals.count))))
            
            let next = allVals.removeAtIndex(random)
            
            solution.append(lastRemoved)
            return packagePuzzle(allVals, withLastRemoved: next, andTried: tried, andSolution: solution)
            
        } else {
            solution.append(lastRemoved)
            return (tried+allVals, solution)
        }
    }
    
    
    // function for "cheat mode" -- checks that there is only one solution given list of given cells and returns solution for the puzzle
    internal func solutionForValidPuzzle(puzzle: [PuzzleCell]) -> [PuzzleCell]? {
        defer {
            rebuild()
        }
        
        // helper function to translate the given list of puzzle cells into matrix rows
        
        func getRowsFromCells(cells: [PuzzleCell]) -> [LinkedNode<PuzzleKey>] {
            
            var rowsToSolve = [LinkedNode<PuzzleKey>]()
            
            for cell in cells {
                let solvedRow = findRowMatchForCell(cell)
                rowsToSolve.append(solvedRow)
            }
            
            return rowsToSolve
        }
        
        let givens = getRowsFromCells(puzzle)
        eliminateRows(givens)
        if countPuzzleSolutions() != 1 {
            return nil
        }
        let nodes = solutions[0]
        return cellsFromConstraints(nodes)
    }
    
    
    
    
    internal func countPuzzleSolutions() -> Int {
        
        if isSolved {
            return 1
        }
        
        if let bestColumn = selectRowToSolve() {
            return allSolutionsForPuzzle(bestColumn, andRoot:bestColumn.vertOrder)
        }
        
        return 0
    }
    
    
    internal func addSolution() {
        var solution: [LinkedNode<PuzzleKey>] = []
        
        for choice in currentSolution {
            solution.append(choice.Chosen.getLateralHead())
        }
        
        solutions.append(solution)
    }
    
    
    internal func allSolutionsForPuzzle(rowChoice:LinkedNode<PuzzleKey>, andCount count:Int = 0, withCutOff cutOff:Int = 2, andRoot root:Int = 1) -> Int {
        
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
    
    
    internal func findFirstSolution(rowChoice:LinkedNode<PuzzleKey>, root: Int) -> Bool {
        
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
    
    internal func findNextRowChoice()->(Node: LinkedNode<PuzzleKey>, Root:Int)? {
        
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
    
    
    internal func reinsertLast(last: Choice) {
        
        var current = last.Chosen.getLateralTail() // start at last node and work back to the head reconnecting each node with its column
        
        repeat {
            uncoverColumn(current)
            current = current.left!
        } while current.latOrder != 0
        
    }
    
    
    
    internal func selectRowToSolve() -> LinkedNode<PuzzleKey>? {
        
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
    
    
    
    
    internal func solveForRow(row: LinkedNode<PuzzleKey>, root: Int = 1){
        removeRowFromMatrix(row, root: root)
        currentSolution.append((row, root))
    }
    
    internal func eliminateRows(rows: [LinkedNode<PuzzleKey>]) -> Int {
        for row in rows {
            eliminateRow(row, root: row.vertOrder)
        }
        
        return matrix.verticalCount()
    }
    
    
    internal func eliminateRow(row: LinkedNode<PuzzleKey>, root: Int = 1){
        removeRowFromMatrix(row, root: root)
        eliminated.append((row, root))
    }
    
    
    internal func removeRowFromMatrix(row: LinkedNode<PuzzleKey>, root: Int = 1) {
        
        var current = row.getLateralHead().right!
        while current.latOrder != 0 {
            let col = current.getVerticalHead()  // go to the top of the column
            coverColumn(col)                     // "cover" the column
            current = current.right!
        }
        
    }
    
    
    internal func coverColumn(column: LinkedNode<PuzzleKey>)  {
        
        var current = column.down!
        while current.vertOrder != 0 {      // start at top of column and remove each row until we get to the column head
            removeRow(current)
            current = current.down!
        }
        
        matrix.removeLateralLink(column)  // unlink the column head so it doesn't get read during row selection
        
    }
    
    
    internal func uncoverColumn(column: LinkedNode<PuzzleKey>) {
        var current = column.getVerticalTail()
        
        repeat {  // we start at the bottom of the column and insert each row until we get back to the top
            insertRow(current)
            current = current.up!
        } while current.vertOrder != 0
        
        matrix.insertLateralLink(current) // we reinsert the column head laterally
        
    }
    
    
    internal func removeRow(row: LinkedNode<PuzzleKey>) {
        let skip = row.latOrder  // skip the column we're choosing on
        var current = row.getLateralHead() // start at leftmost node and remove each from left to right
        repeat {
            if current.latOrder == skip {
                current = current.right!
                continue
            }
            matrix.removeVerticalLink(current)
            current = current.right!
        } while current.latOrder !=  0
        
        
    }
    
    internal func insertRow(row: LinkedNode<PuzzleKey>) {
        
        let skip = row.latOrder
        var current = row.getLateralTail()
        
        repeat {                                // start at the last node and go backwards reconnecting nodes with their columns
            if current.latOrder == skip {
                current = current.left!
                continue
            }
            matrix.insertVerticalLink(current)
            current = current.left!
            
        } while current.latOrder != 4
    }
}