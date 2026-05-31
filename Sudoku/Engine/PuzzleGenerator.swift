import Foundation

enum PuzzleGenerator {
    private static let maxAttempts = 25

    static func generate(difficulty: Difficulty) -> (puzzle: Board, solution: [[Int]]) {
        for level in fallbackLevels(for: difficulty) {
            for _ in 0..<maxAttempts {
                if let result = tryGenerateIncremental(difficulty: level) {
                    return result
                }
            }
        }
        return fallbackPuzzle(matching: difficulty)
    }

    private static func fallbackLevels(for difficulty: Difficulty) -> [Difficulty] {
        switch difficulty {
        case .easy:
            return [.easy]
        case .medium:
            return [.medium, .easy]
        case .hard:
            return [.hard, .medium, .easy]
        }
    }

    /// Removes clues one at a time so the grid stays uniquely solvable (reliable for hard).
    private static func tryGenerateIncremental(difficulty: Difficulty) -> (puzzle: Board, solution: [[Int]])? {
        guard let solutionGrid = makeFullGrid() else { return nil }
        guard solutionGrid.allSatisfy({ row in row.allSatisfy { $0 != nil } }) else { return nil }

        let solution = solutionGrid.map { row in row.map { $0! } }
        var puzzleGrid = solutionGrid
        let targetGivens = difficulty.targetGivens
        let cellsToRemove = 81 - targetGivens
        let positions = (0..<81).map { ($0 / 9, $0 % 9) }.shuffled()

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

        let givens = puzzleGrid.flatMap { $0 }.compactMap { $0 }.count
        let tolerance = 4
        guard givens >= targetGivens - tolerance, givens <= targetGivens + tolerance else {
            return nil
        }
        guard SudokuSolver.solutionCount(puzzleGrid, limit: 2) == 1 else { return nil }

        return makeBoard(puzzleGrid: puzzleGrid, solution: solution)
    }

    private static func makeBoard(puzzleGrid: [[Int?]], solution: [[Int]]) -> (puzzle: Board, solution: [[Int]]) {
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

    /// Guaranteed puzzle when random generation fails (avoids force-unwrap crashes).
    private static func fallbackPuzzle(matching difficulty: Difficulty) -> (puzzle: Board, solution: [[Int]]) {
        _ = difficulty
        let board = Board(puzzleString: Board.samplePuzzle)
        var grid = board.valueGrid()
        if SudokuSolver.solve(&grid) {
            let solution = grid.map { row in row.map { $0! } }
            return (board, solution)
        }
        let empty = Board(puzzleString: String(repeating: ".", count: 81))
        return (empty, Array(repeating: Array(repeating: 1, count: 9), count: 9))
    }

    private static func makeFullGrid() -> [[Int?]]? {
        for _ in 0..<maxAttempts {
            var grid = Array(repeating: Array(repeating: Int?.none, count: Board.size), count: Board.size)
            if fillGrid(&grid) {
                return grid
            }
        }
        return nil
    }

    @discardableResult
    private static func fillGrid(_ grid: inout [[Int?]]) -> Bool {
        guard let (row, col) = nextEmpty(in: grid) else { return true }
        for digit in (1...9).shuffled() {
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
