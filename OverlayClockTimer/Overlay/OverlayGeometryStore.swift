import CoreGraphics
import Foundation

final class OverlayGeometryStore {
    enum Keys {
        static let frameX = UserDefaultsPreferencesStore.Keys.frameX
        static let frameY = UserDefaultsPreferencesStore.Keys.frameY
        static let frameWidth = UserDefaultsPreferencesStore.Keys.frameWidth
        static let frameHeight = UserDefaultsPreferencesStore.Keys.frameHeight
    }

    private let userDefaults: UserDefaults
    private let validator: ScreenFrameValidator

    init(userDefaults: UserDefaults = .standard, validator: ScreenFrameValidator = ScreenFrameValidator()) {
        self.userDefaults = userDefaults
        self.validator = validator
    }

    func save(frame: CGRect) {
        userDefaults.set(Double(frame.origin.x), forKey: Keys.frameX)
        userDefaults.set(Double(frame.origin.y), forKey: Keys.frameY)
        userDefaults.set(Double(frame.size.width), forKey: Keys.frameWidth)
        userDefaults.set(Double(frame.size.height), forKey: Keys.frameHeight)
    }

    func restoreFrame(
        visibleScreenFrames: [CGRect],
        defaultSize: CGSize = OverlayPreferences.defaultWindowSize
    ) -> CGRect {
        let stored = readFrame()
        let restored = validator.validated(
            frame: stored,
            visibleScreenFrames: visibleScreenFrames,
            defaultSize: defaultSize
        )

        if stored != restored {
            save(frame: restored)
        }

        return restored
    }

    private func readFrame() -> CGRect? {
        guard
            let x = doubleValue(forKey: Keys.frameX),
            let y = doubleValue(forKey: Keys.frameY),
            let width = doubleValue(forKey: Keys.frameWidth),
            let height = doubleValue(forKey: Keys.frameHeight)
        else {
            return nil
        }

        return CGRect(x: x, y: y, width: width, height: height)
    }

    private func doubleValue(forKey key: String) -> Double? {
        guard let number = userDefaults.object(forKey: key) as? NSNumber else {
            return nil
        }
        let value = number.doubleValue
        return value.isFinite ? value : nil
    }
}
