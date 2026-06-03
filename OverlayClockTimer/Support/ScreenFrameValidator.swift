import CoreGraphics
import Foundation

struct ScreenFrameValidator {
    func validated(
        frame: CGRect?,
        visibleScreenFrames: [CGRect],
        defaultSize: CGSize = OverlayPreferences.defaultWindowSize
    ) -> CGRect {
        let normalizedSize = OverlayPreferences.clampedWindowSize(frame?.size ?? defaultSize)
        let screens = visibleScreenFrames.filter { !$0.isEmpty }

        guard let primaryScreen = screens.first else {
            return CGRect(origin: .zero, size: normalizedSize)
        }

        guard let frame else {
            return Self.centeredFrame(size: normalizedSize, in: primaryScreen)
        }

        let candidate = CGRect(origin: frame.origin, size: normalizedSize)
        guard intersectsVisibleScreen(candidate, visibleScreenFrames: screens) else {
            return Self.centeredFrame(size: normalizedSize, in: primaryScreen)
        }

        return candidate
    }

    func intersectsVisibleScreen(_ frame: CGRect, visibleScreenFrames: [CGRect]) -> Bool {
        visibleScreenFrames.contains { screen in
            let intersection = frame.intersection(screen)
            return !intersection.isNull && intersection.width >= 1 && intersection.height >= 1
        }
    }

    static func centeredFrame(size: CGSize, in screenFrame: CGRect) -> CGRect {
        let normalizedSize = OverlayPreferences.clampedWindowSize(size)
        return CGRect(
            x: screenFrame.midX - normalizedSize.width / 2,
            y: screenFrame.midY - normalizedSize.height / 2,
            width: normalizedSize.width,
            height: normalizedSize.height
        )
    }
}
