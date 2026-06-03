@preconcurrency import AppKit
import Foundation

final class HotkeyRegistrar {
    var commandHandler: (@MainActor (HotkeyCommand) -> Void)?

    private let lock = NSLock()
    private var bindings = HotkeyBindingSet()
    private var localMonitor: Any?
    private var globalMonitor: Any?

    deinit {
        unregisterAll()
    }

    func refresh(bindings newBindings: [HotkeyBinding]) {
        lock.locked {
            bindings = HotkeyBindingSet(newBindings)
        }

        if newBindings.contains(where: \.isEnabled) {
            installMonitorsIfNeeded()
        } else {
            unregisterAll()
        }
    }

    func unregisterAll() {
        if let localMonitor {
            NSEvent.removeMonitor(localMonitor)
            self.localMonitor = nil
        }

        if let globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
            self.globalMonitor = nil
        }
    }

    private func installMonitorsIfNeeded() {
        guard localMonitor == nil, globalMonitor == nil else {
            return
        }

        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self, !self.dispatchIfMatched(event) else {
                return nil
            }
            return event
        }

        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            _ = self?.dispatchIfMatched(event)
        }
    }

    private func dispatchIfMatched(_ event: NSEvent) -> Bool {
        guard let command = matchingCommand(for: event) else {
            return false
        }

        Task { @MainActor [commandHandler] in
            commandHandler?(command)
        }
        return true
    }

    private func matchingCommand(for event: NSEvent) -> HotkeyCommand? {
        let identity = HotkeyConflictIdentity(
            keyCode: event.keyCode,
            modifiers: event.modifierFlags.normalizedHotkeyModifiers
        )

        return lock.locked {
            bindings.bindings.first { $0.conflictIdentity == identity }?.command
        }
    }
}

extension NSEvent.ModifierFlags {
    var normalizedHotkeyModifiers: UInt {
        rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue
    }
}

private extension NSLock {
    func locked<T>(_ body: () -> T) -> T {
        lock()
        defer { unlock() }
        return body()
    }
}
