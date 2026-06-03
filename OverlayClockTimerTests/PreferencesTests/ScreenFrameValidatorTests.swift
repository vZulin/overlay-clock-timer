import CoreGraphics
import XCTest
@testable import OverlayClockTimer

final class ScreenFrameValidatorTests: XCTestCase {
    func testKeepsFrameThatIntersectsVisibleScreen() {
        let validator = ScreenFrameValidator()
        let screen = CGRect(x: 0, y: 0, width: 1_000, height: 800)
        let frame = CGRect(x: 900, y: 700, width: 280, height: 160)

        XCTAssertEqual(validator.validated(frame: frame, visibleScreenFrames: [screen]), frame)
    }

    func testRecoversOffScreenFrameToCenteredDefault() {
        let validator = ScreenFrameValidator()
        let screen = CGRect(x: 0, y: 0, width: 1_000, height: 800)
        let frame = CGRect(x: 2_000, y: 2_000, width: 280, height: 160)

        let recovered = validator.validated(frame: frame, visibleScreenFrames: [screen])

        XCTAssertEqual(recovered, CGRect(x: 360, y: 320, width: 280, height: 160))
    }

    func testClampsRecoveredFrameSize() {
        let validator = ScreenFrameValidator()
        let screen = CGRect(x: 0, y: 0, width: 1_000, height: 800)
        let frame = CGRect(x: 2_000, y: 2_000, width: 20, height: 900)

        let recovered = validator.validated(frame: frame, visibleScreenFrames: [screen])

        XCTAssertEqual(recovered.size.width, OverlayPreferences.minimumWindowSize.width)
        XCTAssertEqual(recovered.size.height, OverlayPreferences.maximumWindowSize.height)
    }
}
