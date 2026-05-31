import Combine
import Foundation

final class GameViewModel: ObservableObject {
    @Published private(set) var state: GameState
    @Published var isGenerating = false
    @Published var showWinAlert = false
    @Published var showDifficultyChangeConfirm = false
    @Published var pendingDifficulty: Difficulty?
    @Published var numpadOnLeft: Bool

    private var generationTask: Task<Void, Never>?

    var conflictKeys: Set<String> {
        SudokuValidator.conflictPositions(in: state.board)
    }

    /// Digits 1–9 that already appear nine times on the board (all placements placed).
    var completedDigits: Set<Int> {
        var counts: [Int: Int] = [:]
        for row in 0..<Board.size {
            for col in 0..<Board.size {
                if let value = state.board.value(at: row, col: col) {
                    counts[value, default: 0] += 1
                }
            }
        }
        return Set(counts.filter { $0.value == Board.size }.map(\.key))
    }

    init() {
        numpadOnLeft = GameStore.loadNumpadOnLeft()
        if let saved = GameStore.load() {
            state = saved
            if state.solution == nil {
                scheduleSolutionComputation()
            }
        } else {
            state = GameState()
            scheduleSolutionComputation()
        }
    }

    func toggleNumpadSide() {
        numpadOnLeft.toggle()
        GameStore.saveNumpadOnLeft(numpadOnLeft)
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
        guard !state.board.isGiven(at: row, col: col) else { return }

        if state.inputMode == .notes {
            let hadNote = state.board.notes(at: row, col: col).contains(digit)
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
        guard !state.board.isGiven(at: row, col: col) else { return }

        if let from = state.board.value(at: row, col: col) {
            state.board.setValue(nil, at: row, col: col)
            pushMove(Move.setValue(row: row, col: col, from: from, to: nil))
            state.hasWon = false
            persist()
            return
        }

        let notes = state.board.notes(at: row, col: col)
        guard !notes.isEmpty else { return }
        _ = state.board.clearAllNotes(at: row, col: col)
        pushMove(Move.clearNotes(row: row, col: col, notes: notes))
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
        guard let solution = state.solution else {
            scheduleSolutionComputation()
            return
        }
        guard let hint = SudokuSolver.hint(for: state.board, solution: solution) else { return }

        let row = hint.row
        let col = hint.col
        let from = state.board.value(at: row, col: col)
        let value = hint.value
        guard from != value else { return }

        state.board.setValue(value, at: row, col: col)
        pushMove(Move.setValue(row: row, col: col, from: from, to: value))
        state.selectedRow = row
        state.selectedCol = col
        checkWin()
        persist()
    }

    func selectDifficulty(_ difficulty: Difficulty) {
        guard difficulty != state.difficulty else { return }
        pendingDifficulty = difficulty
        showDifficultyChangeConfirm = true
    }

    func confirmDifficultyChange() {
        guard let difficulty = pendingDifficulty else { return }
        pendingDifficulty = nil
        showDifficultyChangeConfirm = false
        state.difficulty = difficulty
        startNewGame()
    }

    func cancelDifficultyChange() {
        pendingDifficulty = nil
        showDifficultyChangeConfirm = false
        objectWillChange.send()
    }

    func startNewGame() {
        showDifficultyChangeConfirm = false
        pendingDifficulty = nil
        generationTask?.cancel()
        isGenerating = true
        let difficulty = state.difficulty
        generationTask = Task { @MainActor in
            let result: (puzzle: Board, solution: [[Int]])? = await Task.detached(priority: .userInitiated) {
                if Task.isCancelled { return nil }
                return PuzzleGenerator.generate(difficulty: difficulty)
            }.value
            guard !Task.isCancelled, let result else {
                isGenerating = false
                return
            }
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
            state.board.setNotePresent(digit, present: added, at: row, col: col)
        case let .clearNotes(row, col, _):
            _ = state.board.clearAllNotes(at: row, col: col)
        }
    }

    private func applyInverse(_ move: Move) {
        switch move {
        case let .setValue(row, col, from, _):
            state.board.setValue(from, at: row, col: col)
        case let .toggleNote(row, col, digit, added):
            state.board.setNotePresent(digit, present: !added, at: row, col: col)
        case let .clearNotes(row, col, notes):
            state.board.setNotes(notes, at: row, col: col)
        }
    }

    private func checkWin() {
        if SudokuValidator.isComplete(state.board) {
            state.hasWon = true
            showWinAlert = true
        }
    }

    private func scheduleSolutionComputation() {
        guard state.solution == nil else { return }
        let board = state.board
        Task { @MainActor in
            let solved = await Task.detached(priority: .utility) {
                var grid = board.valueGrid()
                guard SudokuSolver.solve(&grid) else { return nil as [[Int]]? }
                return grid.map { row in row.map { $0! } }
            }.value
            guard let solved, state.solution == nil else { return }
            state.solution = solved
            objectWillChange.send()
        }
    }

    private func persist() {
        let snapshot = state
        objectWillChange.send()
        Task.detached(priority: .utility) {
            GameStore.save(snapshot)
        }
    }
}
