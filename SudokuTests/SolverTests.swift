import XCTest
@testable import Sudoku

final class SolverTests: XCTestCase {
    func testSolvesSamplePuzzle() {
        var grid = Board(puzzleString: Board.samplePuzzle).valueGrid()
        XCTAssertTrue(SudokuSolver.solve(&grid))
        XCTAssertNil(grid.flatMap { $0 }.first { $0 == nil })
    }

    func testUniqueSolutionForSample() {
        let grid = Board(puzzleString: Board.samplePuzzle).valueGrid()
        XCTAssertEqual(SudokuSolver.solutionCount(grid, limit: 2), 1)
    }

    func testInvalidDuplicateFailsValidation() {
        var grid = Array(repeating: Array(repeating: Int?.none, count: 9), count: 9)
        grid[0][0] = 5
        grid[0][1] = 5
        XCTAssertFalse(SudokuValidator.isValidValue(5, row: 0, col: 1, in: grid))
    }
}
