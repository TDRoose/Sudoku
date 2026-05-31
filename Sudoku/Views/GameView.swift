import SwiftUI

struct GameView: View {
    @StateObject private var viewModel = GameViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                if viewModel.isGenerating {
                    ProgressView("Generating puzzle…")
                        .padding()
                }

                SudokuGridView(
                    board: viewModel.state.board,
                    selectedRow: viewModel.state.selectedRow,
                    selectedCol: viewModel.state.selectedCol,
                    conflictKeys: viewModel.conflictKeys,
                    onSelect: { row, col in
                        viewModel.selectCell(row: row, col: col)
                    }
                )
                .padding(.horizontal)

                ControlsView(
                    inputMode: viewModel.state.inputMode,
                    completedDigits: viewModel.completedDigits,
                    numpadOnLeft: viewModel.numpadOnLeft,
                    isGenerating: viewModel.isGenerating,
                    onModeChange: { viewModel.setInputMode($0) },
                    onDigit: { viewModel.enterDigit($0) },
                    onErase: { viewModel.erase() }
                )
                .padding(.horizontal)

                Spacer(minLength: 0)
            }
            .navigationTitle("Sudoku")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Picker("Difficulty", selection: Binding(
                        get: { viewModel.state.difficulty },
                        set: { viewModel.setDifficulty($0) }
                    )) {
                        ForEach(Difficulty.allCases) { level in
                            Text(level.displayName).tag(level)
                        }
                    }
                    .pickerStyle(.menu)
                    .disabled(viewModel.isGenerating)
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.toggleNumpadSide()
                    } label: {
                        Image(systemName: viewModel.numpadOnLeft ? "hand.point.left.fill" : "hand.point.right.fill")
                    }
                    .accessibilityLabel(viewModel.numpadOnLeft ? "Numpad on left" : "Numpad on right")
                    .disabled(viewModel.isGenerating)
                    Button("Hint") {
                        viewModel.hint()
                    }
                    .disabled(viewModel.isGenerating)
                    Button("New Game") {
                        viewModel.requestNewGame()
                    }
                    .disabled(viewModel.isGenerating)
                }
            }
            .alert("You solved it!", isPresented: Binding(
                get: { viewModel.showWinAlert },
                set: { viewModel.showWinAlert = $0 }
            )) {
                Button("New Game") { viewModel.startNewGame() }
                Button("Keep Playing", role: .cancel) {}
            }
            .confirmationDialog(
                "Start a new puzzle?",
                isPresented: Binding(
                    get: { viewModel.showNewGameConfirm },
                    set: { viewModel.showNewGameConfirm = $0 }
                ),
                titleVisibility: .visible
            ) {
                Button("New Game", role: .destructive) {
                    viewModel.startNewGame()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
        .navigationViewStyle(.stack)
    }
}

#Preview {
    GameView()
}
