import SwiftUI

struct ControlsView: View {
    private static let keySize: CGFloat = 40
    private static let keySpacing: CGFloat = 6

    let inputMode: InputMode
    let completedDigits: Set<Int>
    let numpadOnLeft: Bool
    let isGenerating: Bool
    let onModeChange: (InputMode) -> Void
    let onDigit: (Int) -> Void
    let onErase: () -> Void

    private var activeColor: Color { inputMode.accentColor }

    private let numpadRows: [[Int]] = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9],
    ]

    private var numpadWidth: CGFloat {
        Self.keySize * 3 + Self.keySpacing * 2
    }

    var body: some View {
        VStack(spacing: 12) {
            inputModeSelector

            HStack {
                if numpadOnLeft {
                    numpad
                    Spacer(minLength: 0)
                } else {
                    Spacer(minLength: 0)
                    numpad
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var inputModeSelector: some View {
        HStack(spacing: 0) {
            modeSegment(title: "Number", mode: .number)
            modeSegment(title: "Notes", mode: .notes)
        }
        .background(Color(.tertiarySystemFill))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .disabled(isGenerating)
    }

    private func modeSegment(title: String, mode: InputMode) -> some View {
        let isSelected = inputMode == mode
        let color = mode.accentColor

        return Button {
            onModeChange(mode)
        } label: {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(color.opacity(isSelected ? 1 : 0.5))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSelected ? color.opacity(0.2) : Color.clear)
        }
        .buttonStyle(.plain)
    }

    private var numpad: some View {
        VStack(spacing: Self.keySpacing) {
            ForEach(numpadRows, id: \.self) { row in
                HStack(spacing: Self.keySpacing) {
                    ForEach(row, id: \.self) { digit in
                        numpadKey(digit: digit)
                    }
                }
            }

            Button(action: onErase) {
                Text("Erase")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(activeColor)
                    .frame(width: numpadWidth, height: Self.keySize)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(activeColor.opacity(0.35), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .disabled(isGenerating)
        }
    }

    private func numpadKey(digit: Int) -> some View {
        let isComplete = completedDigits.contains(digit)

        return Button {
            onDigit(digit)
        } label: {
            Text("\(digit)")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(activeColor)
                .frame(width: Self.keySize, height: Self.keySize)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isComplete ? SudokuColors.note.opacity(0.25) : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            isComplete ? SudokuColors.note.opacity(0.7) : activeColor.opacity(0.35),
                            lineWidth: isComplete ? 2 : 1
                        )
                )
        }
        .buttonStyle(.plain)
        .disabled(isGenerating)
        .animation(.easeInOut(duration: 0.2), value: isComplete)
        .animation(.easeInOut(duration: 0.15), value: inputMode)
    }
}
