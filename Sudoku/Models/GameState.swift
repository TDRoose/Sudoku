import Foundation

enum Difficulty: String, Codable, CaseIterable, Identifiable {
    case easy
    case medium
    case hard

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }

    var targetGivens: Int {
        switch self {
        case .easy: return 40
        case .medium: return 32
        case .hard: return 24
        }
    }
}

enum InputMode: String, Codable {
    case number
    case notes
}

enum Move: Codable, Equatable {
    case setValue(row: Int, col: Int, from: Int?, to: Int?)
    case toggleNote(row: Int, col: Int, digit: Int, added: Bool)
    case clearNotes(row: Int, col: Int, notes: Set<Int>)
}

struct GameState: Codable, Equatable {
    var board: Board
    var difficulty: Difficulty
    var selectedRow: Int?
    var selectedCol: Int?
    var inputMode: InputMode
    var undoStack: [Move]
    var redoStack: [Move]
    var solution: [[Int]]?
    var hasWon: Bool

    init(
        board: Board = Board(puzzleString: Board.samplePuzzle),
        difficulty: Difficulty = .medium,
        selectedRow: Int? = nil,
        selectedCol: Int? = nil,
        inputMode: InputMode = .number,
        undoStack: [Move] = [],
        redoStack: [Move] = [],
        solution: [[Int]]? = nil,
        hasWon: Bool = false
    ) {
        self.board = board
        self.difficulty = difficulty
        self.selectedRow = selectedRow
        self.selectedCol = selectedCol
        self.inputMode = inputMode
        self.undoStack = undoStack
        self.redoStack = redoStack
        self.solution = solution
        self.hasWon = hasWon
    }
}
