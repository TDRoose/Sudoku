import SwiftUI

struct GameView: View {
    @StateObject private var viewModel = GameViewModel()

    private var difficultySelection: Binding<Difficulty> {
        Binding(
            get: { viewModel.pendingDifficulty ?? viewModel.state.difficulty },
            set: { viewModel.selectDifficulty($0) }
        )
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                headerBar

                Picker("Difficulty", selection: difficultySelection) {
                    ForEach(Difficulty.allCases) { level in
                        Text(level.displayName).tag(level)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .disabled(viewModel.isGenerating)

                if viewModel.isGenerating {
                    ProgressView("Generating puzzle…")
                        .padding()
                }

                SudokuGridView(
                    board: viewModel.state.board,
                    inputMode: viewModel.state.inputMode,
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
            .navigationBarHidden(true)
            .alert("You solved it!", isPresented: Binding(
                get: { viewModel.showWinAlert },
                set: { viewModel.showWinAlert = $0 }
            )) {
                Button("New Game") { viewModel.startNewGame() }
                Button("Keep Playing", role: .cancel) {}
            }
            .confirmationDialog(
                difficultyChangeTitle,
                isPresented: Binding(
                    get: { viewModel.showDifficultyChangeConfirm },
                    set: { if !$0 { viewModel.cancelDifficultyChange() } }
                ),
                titleVisibility: .visible
            ) {
                Button("Start New Puzzle", role: .destructive) {
                    viewModel.confirmDifficultyChange()
                }
                Button("Cancel", role: .cancel) {
                    viewModel.cancelDifficultyChange()
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    private var headerBar: some View {
        HStack(alignment: .center, spacing: 12) {
            Text("Sudoku")
                .font(.title2)
                .fontWeight(.bold)

            Spacer(minLength: 0)

            Button {
                viewModel.toggleNumpadSide()
            } label: {
                Image(systemName: viewModel.numpadOnLeft ? "hand.point.left.fill" : "hand.point.right.fill")
                    .font(.body)
            }
            .buttonStyle(.plain)
            .foregroundColor(.primary)
            .accessibilityLabel(viewModel.numpadOnLeft ? "Numpad on left" : "Numpad on right")
            .disabled(viewModel.isGenerating)

            Button("Hint") {
                viewModel.hint()
            }
            .buttonStyle(.plain)
            .font(.body)
            .foregroundColor(.primary)
            .disabled(viewModel.isGenerating)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var difficultyChangeTitle: String {
        let name = (viewModel.pendingDifficulty ?? viewModel.state.difficulty).displayName
        return "Start a new \(name) puzzle?"
    }
}

#Preview {
    GameView()
}
