import SwiftUI

struct ControlsView: View {
    let inputMode: InputMode
    let canUndo: Bool
    let canRedo: Bool
    let isGenerating: Bool
    let onModeChange: (InputMode) -> Void
    let onDigit: (Int) -> Void
    let onErase: () -> Void
    let onHint: () -> Void
    let onUndo: () -> Void
    let onRedo: () -> Void

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

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 8) {
                ForEach(1...9, id: \.self) { digit in
                    Button("\(digit)") { onDigit(digit) }
                        .buttonStyle(.bordered)
                        .disabled(isGenerating)
                }
                Button("Erase", action: onErase)
                    .buttonStyle(.bordered)
                    .disabled(isGenerating)
                Button("Hint", action: onHint)
                    .buttonStyle(.bordered)
                    .disabled(isGenerating)
                Button("Undo", action: onUndo)
                    .buttonStyle(.bordered)
                    .disabled(!canUndo || isGenerating)
                Button("Redo", action: onRedo)
                    .buttonStyle(.bordered)
                    .disabled(!canRedo || isGenerating)
            }
        }
    }
}
