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
            Picker("Mode", selection: Binding(
                get: { inputMode },
                set: { onModeChange($0) }
            )) {
                Text("Number").tag(InputMode.number)
                Text("Notes").tag(InputMode.notes)
            }
            .pickerStyle(.segmented)

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
                    .frame(width: numpadWidth, height: Self.keySize)
            }
            .buttonStyle(.bordered)
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
                .frame(width: Self.keySize, height: Self.keySize)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isComplete ? Color.green.opacity(0.28) : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isComplete ? Color.green.opacity(0.65) : Color.clear, lineWidth: 2)
                )
        }
        .buttonStyle(.bordered)
        .disabled(isGenerating)
        .animation(.easeInOut(duration: 0.2), value: isComplete)
    }
}
