# SudokuCheat
An app that let's you cheat at Sudoku.

This app will allow users to enter a puzzle, have it validated and, if they wish, solved for them. 
A user can also choose to solve the puzzle, or to draw on a library of other user-created puzzles and solve one of those. 
When a user solves a puzzle their time to solve is recorded and each puzzle will count down from the record time as a user 
works to solve the puzzle. 
Puzzles will also be categorized as Easy, Medium, and Hard.

The algorithm that powers the app will be based on Donald Knuth's "Dancing Links" approach to recursive 
backtracking. http://en.wikipedia.org/wiki/Dancing_Links
Parse will be used to store User and Puzzle objects. 
