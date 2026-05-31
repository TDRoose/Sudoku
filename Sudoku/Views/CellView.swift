import SwiftUI

struct CellView: View {
    let cell: Cell
    let isSelected: Bool
    let hasConflict: Bool
    let isHighlighted: Bool

    var body: some View {
        ZStack {
            backgroundColor
            if let value = cell.value {
                Text("\(value)")
                    .font(.system(size: 22, weight: cell.isGiven ? .bold : .semibold))
                    .foregroundStyle(cell.isGiven ? Color.primary : Color.blue)
            } else if !cell.notes.isEmpty {
                notesGrid
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var backgroundColor: Color {
        if hasConflict { return Color.red.opacity(0.35) }
        if isSelected { return Color.yellow.opacity(0.45) }
        if isHighlighted { return Color.blue.opacity(0.08) }
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
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(2)
    }
}
