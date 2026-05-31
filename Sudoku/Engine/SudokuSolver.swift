import Foundation

enum SudokuSolver {
    /// Solves in place; returns true if a solution exists.
    @discardableResult
    static func solve(_ grid: inout [[Int?]]) -> Bool {
        guard let (row, col) = nextEmpty(in: grid) else { return true }
        for digit in 1...9 {
            if SudokuValidator.isValidValue(digit, row: row, col: col, in: grid) {
                grid[row][col] = digit
                if solve(&grid) { return true }
                grid[row][col] = nil
            }
        }
        return false
    }

    /// Counts solutions up to `limit` (stops early for uniqueness checks).
    static func solutionCount(_ grid: [[Int?]], limit: Int = 2) -> Int {
        var grid = grid
        return countSolutions(&grid, limit: limit)
    }

    private static func countSolutions(_ grid: inout [[Int?]], limit: Int) -> Int {
        guard let (row, col) = nextEmpty(in: grid) else { return 1 }
        var total = 0
        for digit in 1...9 {
            if SudokuValidator.isValidValue(digit, row: row, col: col, in: grid) {
                grid[row][col] = digit
                total += countSolutions(&grid, limit: limit)
                if total >= limit { return total }
                grid[row][col] = nil
            }
        }
        return total
    }

    /// First empty cell filled with solution digit (for hints).
    static func hint(for board: Board, solution: [[Int]]) -> (row: Int, col: Int, value: Int)? {
        for row in 0..<Board.size {
            for col in 0..<Board.size {
                if board.cells[row][col].isGiven { continue }
                if board.value(at: row, col: col) == nil {
                    return (row, col, solution[row][col])
                }
            }
        }
        return nil
    }

    private static func nextEmpty(in grid: [[Int?]]) -> (Int, Int)? {
        for row in 0..<Board.size {
            for col in 0..<Board.size where grid[row][col] == nil {
                return (row, col)
            }
        }
        return nil
    }
}
