import XCTest
@testable import Sudoku

final class GeneratorTests: XCTestCase {
    func testGeneratedPuzzleHasUniqueSolution() {
        let result = PuzzleGenerator.generate(difficulty: .medium)
        let grid = result.puzzle.valueGrid()
        XCTAssertEqual(SudokuSolver.solutionCount(grid, limit: 2), 1)
    }

    func testGeneratedPuzzleRespectsGivensCountRoughly() {
        let result = PuzzleGenerator.generate(difficulty: .easy)
        let givens = result.puzzle.valueGrid().flatMap { $0 }.compactMap { $0 }.count
        XCTAssertGreaterThanOrEqual(givens, 30)
    }

    func testSolutionMatchesSolvedPuzzle() {
        let result = PuzzleGenerator.generate(difficulty: .hard)
        var grid = result.puzzle.valueGrid()
        XCTAssertTrue(SudokuSolver.solve(&grid))
        let solved = grid.map { row in row.map { $0! } }
        XCTAssertEqual(solved, result.solution)
    }
}
