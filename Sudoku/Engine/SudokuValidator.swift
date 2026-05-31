import Foundation

enum SudokuValidator {
    static func isValidValue(_ value: Int, row: Int, col: Int, in grid: [[Int?]]) -> Bool {
        guard (1...9).contains(value) else { return false }
        for c in 0..<Board.size where c != col {
            if grid[row][c] == value { return false }
        }
        for r in 0..<Board.size where r != row {
            if grid[r][col] == value { return false }
        }
        let boxRow = (row / 3) * 3
        let boxCol = (col / 3) * 3
        for r in boxRow..<(boxRow + 3) {
            for c in boxCol..<(boxCol + 3) where r != row || c != col {
                if grid[r][c] == value { return false }
            }
        }
        return true
    }

    /// Cells that conflict with Sudoku rules (duplicate in row, column, or box).
    static func conflictPositions(in board: Board) -> Set<String> {
        var conflicts = Set<String>()
        let grid = board.valueGrid()

        for row in 0..<Board.size {
            var seen: [Int: [String]] = [:]
            for col in 0..<Board.size {
                guard let value = grid[row][col] else { continue }
                let key = "\(row),\(col)"
                seen[value, default: []].append(key)
            }
            for positions in seen.values where positions.count > 1 {
                conflicts.formUnion(positions)
            }
        }

        for col in 0..<Board.size {
            var seen: [Int: [String]] = [:]
            for row in 0..<Board.size {
                guard let value = grid[row][col] else { continue }
                let key = "\(row),\(col)"
                seen[value, default: []].append(key)
            }
            for positions in seen.values where positions.count > 1 {
                conflicts.formUnion(positions)
            }
        }

        for boxRow in stride(from: 0, to: Board.size, by: 3) {
            for boxCol in stride(from: 0, to: Board.size, by: 3) {
                var seen: [Int: [String]] = [:]
                for row in boxRow..<(boxRow + 3) {
                    for col in boxCol..<(boxCol + 3) {
                        guard let value = grid[row][col] else { continue }
                        let key = "\(row),\(col)"
                        seen[value, default: []].append(key)
                    }
                }
                for positions in seen.values where positions.count > 1 {
                    conflicts.formUnion(positions)
                }
            }
        }

        return conflicts
    }

    static func isComplete(_ board: Board) -> Bool {
        let grid = board.valueGrid()
        for row in grid {
            for value in row where value == nil {
                return false
            }
        }
        return conflictPositions(in: board).isEmpty
    }
}
