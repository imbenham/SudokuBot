//
//  Matrix.swift
//  SudokuBot
//
//  Created by Isaac Benham on 4/6/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import Foundation

class Matrix {
    
    static let sharedInstance: Matrix = Matrix()
    // let puzzleStore: PuzzleStore = PuzzleStore.sharedInstance
    
    var matrix = SudokuMatrix<PuzzleKey>()
    typealias Choice = (Chosen: LinkedNode<PuzzleKey>, Root:Int)
    internal var currentSolution = [Choice]()
    internal var eliminated = [Choice]()
    typealias Solution = [LinkedNode<PuzzleKey>]
    internal var solutions = [Solution]()
    internal var solutionDict: [PuzzleCell: LinkedNode<PuzzleKey>]?
    var rawDifficultyForPuzzle:Int {
        get {
            return PuzzleStore.sharedInstance.getPuzzleDifficulty()
        }
    }
    var isSolved: Bool {
        get {
            return matrix.lateralHead.key == nil
        }
    }
    //var allRows: [Int: LinkedNode<PuzzleNode>]?
    
    
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
    
    
    
    func resetSolution() {
        while currentSolution.count != 0 {
            let lastChoice:Choice = currentSolution.removeLast()
            reinsertLast(lastChoice)
        }
        solutions = []
    }
    
    
    
    // Constructing matrix
    func constructMatrix() {
        
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
        
        while currentRow.key != last.key {
            
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
    
    func findRowMatch(mRow: PuzzleKey) -> LinkedNode<PuzzleKey> {
        
        
        var current = matrix.verticalHead.up!
        
        while current.vertOrder != matrix.verticalHead.vertOrder {
            if current.key! == mRow {
                return current
            }
            current = current.up!
        }
        return current
    }
    
    func findRowMatchForCell(cell: PuzzleCell) -> LinkedNode<PuzzleKey> {
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
