# AGENTS.md

Guidance for AI agents working in this repository.

## Project summary

Personal **iOS Sudoku** app (SwiftUI, iOS 17+). Not a web app, the app lives under `Sudoku/` and `Sudoku.xcodeproj`.

- **Owner goal**: learning iOS; keep changes small and teachable.
- **Remote**: `git@github.com:TDRoose/Sudoku.git`
- **Feature branch example**: `cursor/ios-sudoku-swiftui`

## Tech stack

| Layer | Choice |
|-------|--------|
| UI | SwiftUI |
| State | `@Observable` `GameViewModel` (Observation framework) |
| Min OS | iOS 17.0 |
| Persistence | `Codable` + `UserDefaults` via `GameStore` |
| Tests | XCTest in `SudokuTests/` |

## Repository layout

```
Sudoku.xcodeproj/     # Open this in Xcode
Sudoku/
  SudokuApp.swift     # @main
  Models/             # Board, Cell, GameState, Move, Difficulty
  Engine/             # Pure Swift: validator, solver, generator
  ViewModels/         # GameViewModel — all game actions
  Views/              # SwiftUI only; no business logic
  Persistence/        # GameStore
SudokuTests/          # Solver + generator tests
README.md             # Human run instructions
```

## Architecture rules (important)

1. **Views are dumb.** `Sudoku/Views/*` display state and call `GameViewModel` methods. Do not put Sudoku rules, solving, or undo logic in views.

2. **Engine is pure Swift.** `Sudoku/Engine/*` must not import SwiftUI. Reuse `SudokuValidator`, `SudokuSolver`, and `PuzzleGenerator` for validation, hints, uniqueness checks, and new puzzles.

3. **Single source of game actions.** User input (digit, notes, erase, hint, undo, redo, new game) goes through `GameViewModel`. Each mutating action should push a `Move` onto `state.undoStack` and clear `redoStack` (see existing patterns).

4. **Persistence.** After meaningful state changes, `GameViewModel` calls `GameStore.save(state)`. Do not write to `UserDefaults` from views.

5. **Givens are immutable.** Never clear or overwrite cells where `cell.isGiven == true`.

6. **Puzzle generation is expensive.** Run `PuzzleGenerator.generate` off the main actor (see `startNewGame()` in `GameViewModel`); show `isGenerating` in the UI.

## Key types

- `Board` — 9×9 `[[Cell]]`; puzzle string init for samples.
- `GameState` — board, difficulty, selection, `inputMode`, undo/redo stacks, cached `solution`, `hasWon`.
- `Move` — `setValue` or `toggleNote`; undo applies inverse.
- `Difficulty` — `easy` / `medium` / `hard` with `targetGivens` (40 / 32 / 24).

## Build and test

Requires **Xcode** on macOS.

```bash
# From repo root — use an available simulator name from:
xcrun simctl list devices available

xcodebuild -scheme Sudoku -destination 'platform=iOS Simulator,name=iPhone 16' build
xcodebuild -scheme Sudoku -destination 'platform=iOS Simulator,name=iPhone 16' test
```

If the named simulator is missing, pick any available iPhone simulator or use `generic/platform=iOS Simulator` for build-only.

**Signing**: `DEVELOPMENT_TEAM` may be empty in the project. User must set their Apple ID in Xcode for device builds. Do not commit secrets or provisioning profiles.

## Coding conventions

- Match existing style: minimal comments, no over-abstraction, focused diffs.
- Prefer extending existing types over new parallel helpers.
- New game logic → `Engine/` or `Models/`; UI wiring → `Views/` + `GameViewModel`.
- When adding `GameState` fields, update `Codable` conformance and consider migration in `GameStore.load()`.

## Out of scope (unless user explicitly asks)

- App Store release, subscriptions, analytics, iCloud sync
- iPad-specific layouts, widgets, Game Center
- Advanced Sudoku solving strategies in hints (hints = one correct digit from stored solution)
- Rewriting in React Native, Flutter, or a web stack

## Git workflow for agents

- Use branch prefix `cursor/` for agent work (e.g. `cursor/fix-hint-loop`).
- **Only commit when the user asks.** Use clear, complete-sentence commit messages.
- **Do not push** unless the user asks.
- Stage only files related to this repo (`Sudoku/`, `SudokuTests/`, `Sudoku.xcodeproj/`, `README.md`, `AGENTS.md`, `.gitignore`)—not parent-directory or unrelated paths.

## Common tasks

| Task | Where to change |
|------|-----------------|
| UI layout / styling | `Sudoku/Views/` |
| New button / action | `GameViewModel` + `ControlsView` or `GameView` toolbar |
| Rule validation / conflicts | `SudokuValidator` |
| Hint / solve / uniqueness | `SudokuSolver` |
| Difficulty / generation | `PuzzleGenerator`, `Difficulty` |
| Save / restore | `GameStore`, `GameState` |
| Add unit test | `SudokuTests/` |

## Adding a new Xcode source file

1. Create the `.swift` file under the correct `Sudoku/` subfolder.
2. Add a `PBXFileReference` and `PBXBuildFile` entry in `Sudoku.xcodeproj/project.pbxproj`, and include it in the `Sources` build phase for the Sudoku target (and test target if applicable).

## Human docs

See [README.md](README.md) for opening the project and feature list. Do not edit `.cursor/plans/` plan files unless the user requests it.
