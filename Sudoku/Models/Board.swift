import Foundation

struct Board: Codable, Equatable {
    static let size = 9
    private(set) var cells: [[Cell]]

    init(values: [[Int?]], givens: Set<String> = []) {
        cells = (0..<Self.size).map { row in
            (0..<Self.size).map { col in
                let key = "\(row),\(col)"
                let value = values[row][col]
                return Cell(
                    value: value,
                    notes: [],
                    isGiven: givens.contains(key) || value != nil
                )
            }
        }
        // Mark givens explicitly when values provided at start
        for row in 0..<Self.size {
            for col in 0..<Self.size {
                if let v = values[row][col], v != nil {
                    cells[row][col].isGiven = true
                }
            }
        }
    }

    /// 81-char string: digits 1-9, `.` or `0` for empty.
    init(puzzleString: String, maskGivens: Bool = true) {
        let chars = Array(puzzleString.prefix(81))
        var values: [[Int?]] = []
        var givenKeys = Set<String>()
        for row in 0..<Self.size {
            var rowValues: [Int?] = []
            for col in 0..<Self.size {
                let index = row * Self.size + col
                let ch = index < chars.count ? chars[index] : "."
                if let digit = Int(String(ch)), (1...9).contains(digit) {
                    rowValues.append(digit)
                    if maskGivens {
                        givenKeys.insert("\(row),\(col)")
                    }
                } else {
                    rowValues.append(nil)
                }
            }
            values.append(rowValues)
        }
        self.init(values: values, givens: maskGivens ? givenKeys : [])
    }

    func value(at row: Int, col: Int) -> Int? {
        cells[row][col].value
    }

    mutating func setValue(_ value: Int?, at row: Int, col: Int) {
        guard !cells[row][col].isGiven else { return }
        cells[row][col].value = value
        if value != nil {
            cells[row][col].notes = []
        }
    }

    mutating func toggleNote(_ digit: Int, at row: Int, col: Int) {
        guard !cells[row][col].isGiven, cells[row][col].value == nil else { return }
        if cells[row][col].notes.contains(digit) {
            cells[row][col].notes.remove(digit)
        } else {
            cells[row][col].notes.insert(digit)
        }
    }

    /// Flat 9×9 grid of values only (nil = 0 for solver).
    func valueGrid() -> [[Int?]] {
        cells.map { row in row.map(\.value) }
    }

    mutating func applyValueGrid(_ grid: [[Int?]], maskGivens: Bool) {
        for row in 0..<Self.size {
            for col in 0..<Self.size {
                let v = grid[row][col]
                if maskGivens && cells[row][col].isGiven {
                    continue
                }
                cells[row][col].value = v
                if v != nil {
                    cells[row][col].notes = []
                }
            }
        }
    }

    static let samplePuzzle = """
        530070000
        600195000
        098000060
        000803006
        000000000
        600000000
        000020030
        000000000
        000000000
        """
}
