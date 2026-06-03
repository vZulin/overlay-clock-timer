enum ModeSwitchAction: String, CaseIterable, Equatable {
    case `continue` = "continue"
    case pause
    case stopAndReset

    static let defaultValue: ModeSwitchAction = .stopAndReset

    init(storedValue: String?) {
        self = storedValue.flatMap(ModeSwitchAction.init(rawValue:)) ?? Self.defaultValue
    }
}
