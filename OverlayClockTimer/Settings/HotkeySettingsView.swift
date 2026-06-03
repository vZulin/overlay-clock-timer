import AppKit
import SwiftUI

struct HotkeySettingsView: View {
    @ObservedObject var coordinator: AppCoordinator
    @State private var recordingCommand: HotkeyCommand?
    @State private var conflict: PendingHotkeyConflict?

    private var bindings: HotkeyBindingSet {
        HotkeyBindingSet(coordinator.preferences.hotkeyBindings)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Hotkeys")
                .font(.title2.weight(.semibold))

            ForEach(HotkeyCommand.allCases) { command in
                hotkeyRow(for: command)
            }

            if let conflict {
                VStack(alignment: .leading, spacing: 8) {
                    Text("This shortcut is already assigned to \(conflict.conflictingCommand.title).")
                        .foregroundStyle(.red)

                    HStack {
                        Button("Replace") {
                            replaceConflict(conflict)
                        }
                        Button("Cancel") {
                            self.conflict = nil
                        }
                    }
                }
            }

            Spacer()
        }
    }

    private func hotkeyRow(for command: HotkeyCommand) -> some View {
        HStack(spacing: 12) {
            Text(command.title)
                .frame(width: 110, alignment: .leading)

            Text(bindings.binding(for: command)?.displayText ?? "Not set")
                .monospacedDigit()
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(recordingCommand == command ? "Press shortcut" : "Record") {
                conflict = nil
                recordingCommand = command
            }

            Button("Clear") {
                clear(command)
            }
            .disabled(bindings.binding(for: command) == nil)
        }
        .overlay(alignment: .bottomLeading) {
            if recordingCommand == command {
                HotkeyCaptureField { keyCode, modifiers in
                    capture(command: command, keyCode: keyCode, modifiers: modifiers)
                }
                .frame(width: 1, height: 1)
                .opacity(0.01)
            }
        }
    }

    private func capture(command: HotkeyCommand, keyCode: UInt16, modifiers: UInt) {
        let binding = HotkeyBinding(
            command: command,
            keyCode: keyCode,
            modifiers: modifiers,
            isEnabled: true
        )
        let result = coordinator.updateHotkeyBinding(binding, replacingConflicts: false)

        switch result {
        case .accepted:
            conflict = nil
            recordingCommand = nil
        case .rejected(let conflictingCommand):
            conflict = PendingHotkeyConflict(
                attemptedBinding: binding,
                conflictingCommand: conflictingCommand
            )
        }
    }

    private func replaceConflict(_ conflict: PendingHotkeyConflict) {
        _ = coordinator.updateHotkeyBinding(conflict.attemptedBinding, replacingConflicts: true)
        self.conflict = nil
        recordingCommand = nil
    }

    private func clear(_ command: HotkeyCommand) {
        _ = coordinator.updateHotkeyBinding(
            HotkeyBinding(command: command, keyCode: 0, modifiers: 0, isEnabled: false),
            replacingConflicts: true
        )
    }
}

private struct PendingHotkeyConflict {
    let attemptedBinding: HotkeyBinding
    let conflictingCommand: HotkeyCommand
}

private struct HotkeyCaptureField: NSViewRepresentable {
    let onCapture: (UInt16, UInt) -> Void

    func makeNSView(context: Context) -> CapturingKeyView {
        CapturingKeyView(onCapture: onCapture)
    }

    func updateNSView(_ nsView: CapturingKeyView, context: Context) {
        nsView.onCapture = onCapture
        nsView.focus()
    }
}

private final class CapturingKeyView: NSView {
    var onCapture: (UInt16, UInt) -> Void

    init(onCapture: @escaping (UInt16, UInt) -> Void) {
        self.onCapture = onCapture
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override var acceptsFirstResponder: Bool {
        true
    }

    func focus() {
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            window?.makeFirstResponder(self)
        }
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        focus()
    }

    override func keyDown(with event: NSEvent) {
        onCapture(event.keyCode, event.modifierFlags.normalizedHotkeyModifiers)
    }
}
