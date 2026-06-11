import AppKit
import ApplicationServices
import Foundation

typealias KeyboardInputEventHandler = @MainActor (KeyboardInputEvent) -> Void
typealias MouseInputEventHandler = @MainActor (MouseInputEvent) -> Void
typealias ScrollInputEventHandler = @MainActor (ScrollInputEvent) -> Void

@MainActor
protocol InputEventSource: AnyObject {
    func startObservation(
        keyboardHandler: @escaping KeyboardInputEventHandler,
        mouseHandler: @escaping MouseInputEventHandler,
        scrollHandler: @escaping ScrollInputEventHandler
    ) -> InputLoggingSessionStatus
    func stopObservation()
}

@MainActor
final class InputEventObserver: ObservableObject {
    @Published private(set) var status: InputLoggingSessionStatus = .inactive

    private let eventSource: InputEventSource

    init(eventSource: InputEventSource = AppKitInputEventSource()) {
        self.eventSource = eventSource
    }

    @discardableResult
    func startObservation(
        keyboardHandler: @escaping KeyboardInputEventHandler,
        mouseHandler: @escaping MouseInputEventHandler,
        scrollHandler: @escaping ScrollInputEventHandler
    ) -> InputLoggingSessionStatus {
        stopObservation()

        let startStatus = eventSource.startObservation(
            keyboardHandler: { [weak self] event in
                guard self?.status == .active else {
                    return
                }

                keyboardHandler(event)
            },
            mouseHandler: { [weak self] event in
                guard self?.status == .active else {
                    return
                }

                mouseHandler(event)
            },
            scrollHandler: { [weak self] event in
                guard self?.status == .active else {
                    return
                }

                scrollHandler(event)
            }
        )

        status = startStatus
        return startStatus
    }

    func stopObservation() {
        guard status != .inactive else {
            return
        }

        eventSource.stopObservation()
        status = .inactive
    }
}

@MainActor
final class MockInputEventSource: InputEventSource {
    private var isObserving = false

    func startObservation(
        keyboardHandler: @escaping KeyboardInputEventHandler,
        mouseHandler: @escaping MouseInputEventHandler,
        scrollHandler: @escaping ScrollInputEventHandler
    ) -> InputLoggingSessionStatus {
        isObserving = true

        Task { @MainActor [weak self] in
            guard self?.isObserving == true else {
                return
            }

            keyboardHandler(
                KeyboardInputEvent(
                    characters: "s",
                    key: "S",
                    modifiers: [],
                    isRepeat: false
                )
            )
            mouseHandler(MouseInputEvent(button: .left, phase: .mouseDown))
            mouseHandler(MouseInputEvent(button: .left, phase: .mouseUp))
            mouseHandler(MouseInputEvent(button: .right, phase: .mouseDown))
            mouseHandler(MouseInputEvent(button: .right, phase: .mouseUp))
            mouseHandler(MouseInputEvent(button: .third, phase: .mouseDown))
            mouseHandler(MouseInputEvent(button: .third, phase: .mouseUp))
            mouseHandler(MouseInputEvent(button: .additional(4), phase: .mouseDown))
            mouseHandler(MouseInputEvent(button: .additional(4), phase: .mouseUp))
            mouseHandler(MouseInputEvent(button: .additional(5), phase: .mouseDown))
            mouseHandler(MouseInputEvent(button: .additional(5), phase: .mouseUp))
            scrollHandler(ScrollInputEvent(direction: .up))
            scrollHandler(ScrollInputEvent(direction: .down))
        }

        return .active
    }

    func stopObservation() {
        isObserving = false
    }
}

@MainActor
private final class AppKitInputEventSource: InputEventSource {
    private var globalKeyDownMonitor: Any?
    private var localKeyDownMonitor: Any?
    private var globalMouseMonitor: Any?
    private var localMouseMonitor: Any?
    private var globalScrollMonitor: Any?
    private var localScrollMonitor: Any?

    func startObservation(
        keyboardHandler: @escaping KeyboardInputEventHandler,
        mouseHandler: @escaping MouseInputEventHandler,
        scrollHandler: @escaping ScrollInputEventHandler
    ) -> InputLoggingSessionStatus {
        stopObservation()

        guard AXIsProcessTrusted() else {
            return .unavailable(reason: "Input monitoring permission is unavailable.")
        }

        globalKeyDownMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.keyDown]) { event in
            guard let keyboardEvent = KeyboardInputEvent(nsEvent: event) else {
                return
            }

            Task { @MainActor in
                keyboardHandler(keyboardEvent)
            }
        }

        localKeyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { event in
            guard let keyboardEvent = KeyboardInputEvent(nsEvent: event) else {
                return event
            }

            Task { @MainActor in
                keyboardHandler(keyboardEvent)
            }
            return event
        }

        let mouseMask: NSEvent.EventTypeMask = [
            .leftMouseDown,
            .leftMouseUp,
            .rightMouseDown,
            .rightMouseUp,
            .otherMouseDown,
            .otherMouseUp
        ]

        globalMouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: mouseMask) { event in
            guard let mouseEvent = MouseInputEvent(nsEvent: event) else {
                return
            }

            Task { @MainActor in
                mouseHandler(mouseEvent)
            }
        }

        localMouseMonitor = NSEvent.addLocalMonitorForEvents(matching: mouseMask) { event in
            guard let mouseEvent = MouseInputEvent(nsEvent: event) else {
                return event
            }

            Task { @MainActor in
                mouseHandler(mouseEvent)
            }
            return event
        }

        globalScrollMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.scrollWheel]) { event in
            guard let scrollEvent = ScrollInputEvent(nsEvent: event) else {
                return
            }

            Task { @MainActor in
                scrollHandler(scrollEvent)
            }
        }

        localScrollMonitor = NSEvent.addLocalMonitorForEvents(matching: [.scrollWheel]) { event in
            guard let scrollEvent = ScrollInputEvent(nsEvent: event) else {
                return event
            }

            Task { @MainActor in
                scrollHandler(scrollEvent)
            }
            return event
        }

        guard
            globalKeyDownMonitor != nil
                || localKeyDownMonitor != nil
                || globalMouseMonitor != nil
                || localMouseMonitor != nil
                || globalScrollMonitor != nil
                || localScrollMonitor != nil
        else {
            return .unavailable(reason: "Unable to install input event monitors.")
        }

        return .active
    }

    func stopObservation() {
        if let globalKeyDownMonitor {
            NSEvent.removeMonitor(globalKeyDownMonitor)
            self.globalKeyDownMonitor = nil
        }

        if let localKeyDownMonitor {
            NSEvent.removeMonitor(localKeyDownMonitor)
            self.localKeyDownMonitor = nil
        }

        if let globalMouseMonitor {
            NSEvent.removeMonitor(globalMouseMonitor)
            self.globalMouseMonitor = nil
        }

        if let localMouseMonitor {
            NSEvent.removeMonitor(localMouseMonitor)
            self.localMouseMonitor = nil
        }

        if let globalScrollMonitor {
            NSEvent.removeMonitor(globalScrollMonitor)
            self.globalScrollMonitor = nil
        }

        if let localScrollMonitor {
            NSEvent.removeMonitor(localScrollMonitor)
            self.localScrollMonitor = nil
        }
    }
}

private extension MouseInputEvent {
    init?(nsEvent event: NSEvent) {
        switch event.type {
        case .leftMouseDown:
            self.init(button: .left, phase: .mouseDown)
        case .leftMouseUp:
            self.init(button: .left, phase: .mouseUp)
        case .rightMouseDown:
            self.init(button: .right, phase: .mouseDown)
        case .rightMouseUp:
            self.init(button: .right, phase: .mouseUp)
        case .otherMouseDown:
            self.init(button: MouseInputEventButton(eventButtonNumber: event.buttonNumber), phase: .mouseDown)
        case .otherMouseUp:
            self.init(button: MouseInputEventButton(eventButtonNumber: event.buttonNumber), phase: .mouseUp)
        default:
            return nil
        }
    }
}

private extension MouseInputEventButton {
    init(eventButtonNumber: Int) {
        if eventButtonNumber == 2 {
            self = .third
        } else {
            self = .additional(eventButtonNumber + 1)
        }
    }
}

private extension ScrollInputEvent {
    init?(nsEvent event: NSEvent) {
        guard event.type == .scrollWheel else {
            return nil
        }

        let physicalDeltaY = event.isDirectionInvertedFromDevice
            ? -event.scrollingDeltaY
            : event.scrollingDeltaY

        if physicalDeltaY > 0 {
            self.init(direction: .up)
        } else if physicalDeltaY < 0 {
            self.init(direction: .down)
        } else {
            return nil
        }
    }
}

private extension KeyboardInputEvent {
    init?(nsEvent event: NSEvent) {
        let modifiers: Set<InputEventModifier> = Set(eventModifierFlags: event.modifierFlags)
        let ignoringModifiers = event.charactersIgnoringModifiers
        let key = KeyboardKeyName.name(
            forKeyCode: event.keyCode,
            charactersIgnoringModifiers: ignoringModifiers
        )

        self.init(
            characters: KeyboardInputEvent.visibleCharacters(
                from: event.characters,
                charactersIgnoringModifiers: ignoringModifiers,
                modifiers: modifiers
            ),
            key: key,
            modifiers: modifiers,
            isRepeat: event.isARepeat
        )
    }

    static func visibleCharacters(
        from characters: String?,
        charactersIgnoringModifiers: String?,
        modifiers: Set<InputEventModifier>
    ) -> String? {
        guard let characters, !characters.isEmpty else {
            return nil
        }

        let shortcutModifiers: Set<InputEventModifier> = [.control, .command]
        if
            !modifiers.isDisjoint(with: shortcutModifiers),
            characters == charactersIgnoringModifiers
        {
            return nil
        }

        return characters
    }
}

private extension InputEventModifier {
    init?(eventModifierFlag: NSEvent.ModifierFlags) {
        switch eventModifierFlag {
        case .control:
            self = .control
        case .option:
            self = .option
        case .shift:
            self = .shift
        case .command:
            self = .command
        default:
            return nil
        }
    }
}

private extension Set where Element == InputEventModifier {
    init(eventModifierFlags: NSEvent.ModifierFlags) {
        self = Set(
            [
                NSEvent.ModifierFlags.control,
                .option,
                .shift,
                .command
            ].compactMap(InputEventModifier.init(eventModifierFlag:))
                .filter { modifier in
                    switch modifier {
                    case .control:
                        return eventModifierFlags.contains(.control)
                    case .option:
                        return eventModifierFlags.contains(.option)
                    case .shift:
                        return eventModifierFlags.contains(.shift)
                    case .command:
                        return eventModifierFlags.contains(.command)
                    }
                }
        )
    }
}

private enum KeyboardKeyName {
    static func name(
        forKeyCode keyCode: UInt16,
        charactersIgnoringModifiers: String?
    ) -> String {
        if let specialName = specialName(for: charactersIgnoringModifiers) {
            return specialName
        }

        if
            let charactersIgnoringModifiers,
            !charactersIgnoringModifiers.isEmpty
        {
            return charactersIgnoringModifiers.uppercased()
        }

        return keyCodeNames[keyCode] ?? "Key \(keyCode)"
    }

    private static func specialName(for characters: String?) -> String? {
        switch characters {
        case "\u{1B}":
            return "Escape"
        case "\r":
            return "Return"
        case "\t":
            return "Tab"
        case " ":
            return "Space"
        case "\u{7F}":
            return "Delete"
        default:
            return nil
        }
    }

    private static let keyCodeNames: [UInt16: String] = [
        36: "Return",
        48: "Tab",
        49: "Space",
        51: "Delete",
        53: "Escape",
        123: "Left Arrow",
        124: "Right Arrow",
        125: "Down Arrow",
        126: "Up Arrow"
    ]
}
