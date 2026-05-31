import Foundation

enum PuzzleGenerator {
    private static let maxAttempts = 40

    static func generate(difficulty: Difficulty) -> (puzzle: Board, solution: [[Int]]) {
        for _ in 0..<maxAttempts {
            if let result = tryGenerate(difficulty: difficulty) {
                return result
            }
        }
        // Fallback: easier target if hard removal keeps failing uniqueness checks.
        if difficulty != .easy, let result = tryGenerate(difficulty: .medium) {
            return result
        }
        return tryGenerate(difficulty: .easy)!
    }

    private static func tryGenerate(difficulty: Difficulty) -> (puzzle: Board, solution: [[Int]])? {
        let solutionGrid = makeFullGrid()
        let solution = solutionGrid.map { row in row.map { $0! } }

        var puzzleGrid = solutionGrid
        let cellsToRemove = 81 - difficulty.targetGivens
        let positions = (0..<81).map { ($0 / 9, $0 % 9) }.shuffled()

        for (row, col) in positions.prefix(cellsToRemove) {
            puzzleGrid[row][col] = nil
        }

        guard SudokuSolver.solutionCount(puzzleGrid, limit: 2) == 1 else {
            return nil
        }

        var board = Board(values: puzzleGrid, givens: [])
        for row in 0..<Board.size {
            for col in 0..<Board.size {
                if board.value(at: row, col: col) != nil {
                    board.markAsGiven(at: row, col: col)
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
