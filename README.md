# Sudoku (personal iOS app)

A native **SwiftUI** Sudoku app for learning iOS development. Play on the Simulator or your own iPhone.

## Open and run

1. Install **Xcode** from the Mac App Store.
2. Open `Sudoku.xcodeproj` in this folder.
3. Select an **iPhone** simulator (e.g. iPhone 13).
4. Press **Run** (⌘R).

**Install on your iPhone:** see **[INSTALL-ON-IPHONE.md](INSTALL-ON-IPHONE.md)** for a full walkthrough (signing, Developer Mode, trust, and troubleshooting).

## Project layout

| Folder | Purpose |
|--------|---------|
| `Sudoku/Models/` | `Board`, `Cell`, `GameState` — game data |
| `Sudoku/Engine/` | Validation, solver, puzzle generator (pure Swift) |
| `Sudoku/ViewModels/` | `GameViewModel` — `ObservableObject` state and actions |
| `Sudoku/Views/` | SwiftUI screens and controls |
| `Sudoku/Persistence/` | Save/load via `UserDefaults` |
| `SudokuTests/` | Unit tests for solver and generator |

## Features

- 9×9 grid with 3×3 box borders
- **Number** and **Notes** (pencil marks) modes
- Conflict highlighting, row/column/box highlight for selection
- **Easy / Medium / Hard** new puzzles
- **Hint**, **Undo**, **Redo**
- Progress restored on next launch

## Concepts to explore

- **View vs ViewModel**: Views only display and forward taps; `GameViewModel` owns rules and undo.
- **ObservableObject**: SwiftUI updates when `viewModel` publishes changes (iOS 15+).
- **Codable + UserDefaults**: `GameStore` persists `GameState` as JSON.

## Tests

In Xcode: **Product → Test** (⌘U). Tests verify the solver and that generated puzzles have a unique solution.
