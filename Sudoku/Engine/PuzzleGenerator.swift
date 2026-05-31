import Foundation

enum PuzzleGenerator {
    static func generate(difficulty: Difficulty) -> (puzzle: Board, solution: [[Int]]) {
        var solutionGrid = makeFullGrid()
        let solution = solutionGrid.map { row in row.map { $0! } }

        var puzzleGrid = solutionGrid
        let cellsToRemove = 81 - difficulty.targetGivens
        var positions = (0..<81).map { ($0 / 9, $0 % 9) }.shuffled()

        var removed = 0
        for (row, col) in positions where removed < cellsToRemove {
            let backup = puzzleGrid[row][col]
            puzzleGrid[row][col] = nil
            if SudokuSolver.solutionCount(puzzleGrid, limit: 2) == 1 {
                removed += 1
            } else {
                puzzleGrid[row][col] = backup
            }
        }

        var board = Board(values: puzzleGrid, givens: [])
        for row in 0..<Board.size {
            for col in 0..<Board.size {
                if board.value(at: row, col: col) != nil {
                    board.cells[row][col].isGiven = true
                }
            }
        }

        return (board, solution)
    }

    private static func makeFullGrid() -> [[Int?]] {
        var grid = Array(repeating: Array(repeating: Int?.none, count: Board.size), count: Board.size)
        fillGrid(&grid)
        return grid
    }

    @discardableResult
    private static func fillGrid(_ grid: inout [[Int?]]) -> Bool {
        guard let (row, col) = nextEmpty(in: grid) else { return true }
        let digits = (1...9).shuffled()
        for digit in digits {
            if SudokuValidator.isValidValue(digit, row: row, col: col, in: grid) {
                grid[row][col] = digit
                if fillGrid(&grid) { return true }
                grid[row][col] = nil
            }
        }
        return false
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
