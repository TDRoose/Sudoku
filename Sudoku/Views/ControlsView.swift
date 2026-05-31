import SwiftUI

struct ControlsView: View {
    private static let minKeySize: CGFloat = 44
    private static let maxKeySize: CGFloat = 80
    private static let selectorHeight: CGFloat = 36
    private static let sectionSpacing: CGFloat = 12

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

    var body: some View {
        GeometryReader { geometry in
            let layout = LayoutMetrics(containerSize: geometry.size)

            VStack(spacing: Self.sectionSpacing) {
                inputModeSelector

                HStack(alignment: .bottom) {
                    if numpadOnLeft {
                        numpad(layout: layout)
                        Spacer(minLength: 0)
                    } else {
                        Spacer(minLength: 0)
                        numpad(layout: layout)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
        }
        .frame(minHeight: Self.minKeySize * 4 + Self.selectorHeight + Self.sectionSpacing * 2)
    }

    private var inputModeSelection: Binding<InputMode> {
        Binding(
            get: { inputMode },
            set: { onModeChange($0) }
        )
    }

    private var inputModeSelector: some View {
        Picker("Input mode", selection: inputModeSelection) {
            Text("Number").tag(InputMode.number)
            Text("Notes").tag(InputMode.notes)
        }
        .pickerStyle(.segmented)
        .tint(inputMode.accentColor)
        .disabled(isGenerating)
    }

    private func numpad(layout: LayoutMetrics) -> some View {
        VStack(spacing: layout.keySpacing) {
            ForEach(numpadRows, id: \.self) { row in
                HStack(spacing: layout.keySpacing) {
                    ForEach(row, id: \.self) { digit in
                        numpadKey(digit: digit, layout: layout)
                    }
                }
            }

            Button(action: onErase) {
                Text("Erase")
                    .font(.system(size: layout.eraseFontSize, weight: .medium))
                    .foregroundColor(activeColor)
                    .frame(width: layout.numpadWidth, height: layout.keySize)
                    .background(
                        RoundedRectangle(cornerRadius: layout.cornerRadius)
                            .stroke(activeColor.opacity(0.35), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .disabled(isGenerating)
        }
    }

    private func numpadKey(digit: Int, layout: LayoutMetrics) -> some View {
        let isComplete = completedDigits.contains(digit)

        return Button {
            onDigit(digit)
        } label: {
            Text("\(digit)")
                .font(.system(size: layout.digitFontSize, weight: .semibold))
                .foregroundColor(activeColor)
                .frame(width: layout.keySize, height: layout.keySize)
                .background(
                    RoundedRectangle(cornerRadius: layout.cornerRadius)
                        .fill(isComplete ? SudokuColors.note.opacity(0.25) : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: layout.cornerRadius)
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

private extension ControlsView {
    struct LayoutMetrics {
        let keySize: CGFloat
        let keySpacing: CGFloat
        let digitFontSize: CGFloat
        let eraseFontSize: CGFloat
        let cornerRadius: CGFloat

        var numpadWidth: CGFloat {
            keySize * 3 + keySpacing * 2
        }

        init(containerSize: CGSize) {
            keySpacing = 8
            let rowCount: CGFloat = 4
            let verticalGaps = keySpacing * (rowCount - 1)
            let heightBudget = containerSize.height - ControlsView.selectorHeight - ControlsView.sectionSpacing
            let fromHeight = (heightBudget - verticalGaps) / rowCount
            let fromWidth = (containerSize.width - keySpacing * 2) / 3
            keySize = min(
                ControlsView.maxKeySize,
                max(ControlsView.minKeySize, min(fromHeight, fromWidth))
            )
            digitFontSize = keySize * 0.5
            eraseFontSize = keySize * 0.38
            cornerRadius = min(10, keySize * 0.2)
        }
    }
}
