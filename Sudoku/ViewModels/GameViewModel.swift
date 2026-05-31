import Combine
import Foundation

final class GameViewModel: ObservableObject {
    @Published private(set) var state: GameState
    @Published var isGenerating = false
    @Published var showWinAlert = false
    @Published var showNewGameConfirm = false

    var conflictKeys: Set<String> {
        SudokuValidator.conflictPositions(in: state.board)
    }

    var canUndo: Bool { !state.undoStack.isEmpty }
    var canRedo: Bool { !state.redoStack.isEmpty }

    init() {
        if let saved = GameStore.load() {
            state = saved
        } else {
            state = GameState()
            computeSolutionIfNeeded()
        }
    }

    func selectCell(row: Int, col: Int) {
        state.selectedRow = row
        state.selectedCol = col
        persist()
    }

    func setInputMode(_ mode: InputMode) {
        state.inputMode = mode
        persist()
    }

    func enterDigit(_ digit: Int) {
        guard let row = state.selectedRow, let col = state.selectedCol else { return }
        guard !state.board.cells[row][col].isGiven else { return }

        if state.inputMode == .notes {
            let hadNote = state.board.cells[row][col].notes.contains(digit)
            let move = Move.toggleNote(row: row, col: col, digit: digit, added: !hadNote)
            state.board.toggleNote(digit, at: row, col: col)
            pushMove(move)
            checkWin()
            persist()
            return
        }

        let from = state.board.value(at: row, col: col)
        guard from != digit else { return }
        state.board.setValue(digit, at: row, col: col)
        pushMove(Move.setValue(row: row, col: col, from: from, to: digit))
        checkWin()
        persist()
    }

    func erase() {
        guard let row = state.selectedRow, let col = state.selectedCol else { return }
        guard !state.board.cells[row][col].isGiven else { return }

        if state.inputMode == .notes {
            return
        }

        let from = state.board.value(at: row, col: col)
        guard from != nil else { return }
        state.board.setValue(nil, at: row, col: col)
        pushMove(Move.setValue(row: row, col: col, from: from, to: nil))
        state.hasWon = false
        persist()
    }

    func undo() {
        guard let move = state.undoStack.popLast() else { return }
        applyInverse(move)
        state.redoStack.append(move)
        state.hasWon = false
        showWinAlert = false
        persist()
    }

    func redo() {
        guard let move = state.redoStack.popLast() else { return }
        applyMove(move)
        state.undoStack.append(move)
        checkWin()
        persist()
    }

    func hint() {
        computeSolutionIfNeeded()
        guard let solution = state.solution,
              let hint = SudokuSolver.hint(for: state.board, solution: solution) else { return }

        let row = hint.row
        let col = hint.col
        let from = state.board.value(at: row, col: col)
        let value = hint.value
        guard from != value else { return }

        state.board.setValue(value, at: row, col: col)
        state.board.cells[row][col].isGiven = false
        pushMove(Move.setValue(row: row, col: col, from: from, to: value))
        state.selectedRow = row
        state.selectedCol = col
        checkWin()
        persist()
    }

    func setDifficulty(_ difficulty: Difficulty) {
        state.difficulty = difficulty
        persist()
    }

    func requestNewGame() {
        if hasUserProgress() {
            showNewGameConfirm = true
        } else {
            startNewGame()
        }
    }

    func startNewGame() {
        showNewGameConfirm = false
        isGenerating = true
        let difficulty = state.difficulty
        Task { @MainActor in
            let result = await Task.detached(priority: .userInitiated) {
                PuzzleGenerator.generate(difficulty: difficulty)
            }.value
            state = GameState(
                board: result.puzzle,
                difficulty: difficulty,
                solution: result.solution,
                hasWon: false
            )
            isGenerating = false
            showWinAlert = false
            persist()
        }
    }

    private func hasUserProgress() -> Bool {
        !state.undoStack.isEmpty
    }

    private func pushMove(_ move: Move) {
        state.undoStack.append(move)
        state.redoStack = []
    }

    private func applyMove(_ move: Move) {
        switch move {
        case let .setValue(row, col, _, to):
            state.board.setValue(to, at: row, col: col)
        case let .toggleNote(row, col, digit, added):
            if added {
                state.board.cells[row][col].notes.insert(digit)
            } else {
                state.board.cells[row][col].notes.remove(digit)
            }
        }
    }

    private func applyInverse(_ move: Move) {
        switch move {
        case let .setValue(row, col, from, _):
            state.board.setValue(from, at: row, col: col)
        case let .toggleNote(row, col, digit, added):
            if added {
                state.board.cells[row][col].notes.remove(digit)
            } else {
                state.board.cells[row][col].notes.insert(digit)
            }
        }
    }

    private func checkWin() {
        if SudokuValidator.isComplete(state.board) {
            state.hasWon = true
            showWinAlert = true
        }
    }

    private func computeSolutionIfNeeded() {
        guard state.solution == nil else { return }
        var grid = state.board.valueGrid()
        if SudokuSolver.solve(&grid) {
            state.solution = grid.map { row in row.map { $0! } }
        }
    }

    private func persist() {
        objectWillChange.send()
        GameStore.save(state)
    }
}
