import Foundation

protocol PreferencesStore: AnyObject {
    var preferences: OverlayPreferences { get }

    @discardableResult
    func load() -> OverlayPreferences
    func save(_ preferences: OverlayPreferences)
}
