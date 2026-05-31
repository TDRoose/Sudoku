import SwiftUI

struct CellView: View {
    let cell: Cell
    let inputMode: InputMode
    let isSelected: Bool
    let hasConflict: Bool
    let isHighlighted: Bool

    var body: some View {
        ZStack {
            backgroundColor
            if let value = cell.value {
                Text("\(value)")
                    .font(.system(size: 22, weight: cell.isGiven ? .bold : .semibold))
                    .foregroundColor(cell.isGiven ? Color.primary : SudokuColors.number)
            } else if !cell.notes.isEmpty {
                notesGrid
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private static let selectionYellow = Color.yellow.opacity(0.42)
    private static let peerHighlightYellow = Color.yellow.opacity(0.16)

    private var backgroundColor: Color {
        if hasConflict { return Color.red.opacity(0.35) }
        if isSelected { return Self.selectionYellow }
        if isHighlighted { return Self.peerHighlightYellow }
        return Color(.systemBackground)
    }

    private var notesGrid: some View {
        let sorted = cell.notes.sorted()
        return VStack(spacing: 0) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<3, id: \.self) { col in
                        let digit = row * 3 + col + 1
                        Text(sorted.contains(digit) ? "\(digit)" : " ")
                            .font(.system(size: 8))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .foregroundColor(SudokuColors.note)
                    }
                }
            }
        }
        .padding(2)
    }
}
