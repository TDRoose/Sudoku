import SwiftUI

struct SudokuGridView: View {
    let board: Board
    let selectedRow: Int?
    let selectedCol: Int?
    let conflictKeys: Set<String>
    let onSelect: (Int, Int) -> Void

    var body: some View {
        GeometryReader { geometry in
            let cellSize = min(geometry.size.width, geometry.size.height) / 9
            VStack(spacing: 0) {
                ForEach(0..<9, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<9, id: \.self) { col in
                            cellButton(row: row, col: col, size: cellSize)
                            if col == 2 || col == 5 {
                                thickDivider(isVertical: true, length: cellSize)
                            }
                        }
                    }
                    if row == 2 || row == 5 {
                        thickDivider(isVertical: false, length: cellSize * 9 + 2)
                    }
                }
            }
            .overlay(borderOverlay)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func cellButton(row: Int, col: Int, size: CGFloat) -> some View {
        let key = "\(row),\(col)"
        let isSelected = selectedRow == row && selectedCol == col
        let highlightsPeer = highlightsSelection(row: row, col: col)

        return Button {
            onSelect(row, col)
        } label: {
            CellView(
                cell: board.cells[row][col],
                isSelected: isSelected,
                hasConflict: conflictKeys.contains(key),
                isHighlighted: highlightsPeer && !isSelected
            )
            .frame(width: size, height: size)
        }
        .buttonStyle(.plain)
        .overlay(
            Rectangle()
                .stroke(Color.primary.opacity(0.2), lineWidth: 0.5)
        )
    }

    private func highlightsSelection(row: Int, col: Int) -> Bool {
        guard let selectedRow, let selectedCol else { return false }
        if row == selectedRow || col == selectedCol { return true }
        let boxRow = (row / 3) * 3
        let boxCol = (col / 3) * 3
        let selBoxRow = (selectedRow / 3) * 3
        let selBoxCol = (selectedCol / 3) * 3
        return boxRow == selBoxRow && boxCol == selBoxCol
    }

    private func thickDivider(isVertical: Bool, length: CGFloat) -> some View {
        Rectangle()
            .fill(Color.primary)
            .frame(
                width: isVertical ? 2 : length,
                height: isVertical ? length : 2
            )
    }

    private var borderOverlay: some View {
        Rectangle()
            .stroke(Color.primary, lineWidth: 3)
    }
}
