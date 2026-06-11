import CoreGraphics
import Foundation

enum OverlayMetrics {
    static let defaultSize = OverlayPreferences.defaultWindowSize
    static let minimumSize = OverlayPreferences.minimumWindowSize
    static let maximumSize = OverlayPreferences.maximumWindowSize
    static let cornerRadius: CGFloat = 24
    static let controlButtonSize: CGFloat = 36
    static let controlCornerRadius: CGFloat = 8
    static let horizontalPadding: CGFloat = 12
    static let verticalPadding: CGFloat = 10
    static let defaultTimerFontSize: CGFloat = CGFloat(OverlayPreferences.defaultTimerFontSize)
    static let inputLoggingTableHeight: CGFloat = 178
    static let inputLoggingExpandedHeightDelta: CGFloat = inputLoggingTableHeight + 46
    static let maximumExpandedSize = CGSize(
        width: maximumSize.width,
        height: maximumSize.height + inputLoggingExpandedHeightDelta
    )
    static let minimumBackgroundOpacity = OverlayPreferences.minimumBackgroundOpacity
    static let defaultBackgroundOpacity = OverlayPreferences.defaultBackgroundOpacity
    static let maximumBackgroundOpacity = OverlayPreferences.maximumBackgroundOpacity
}
