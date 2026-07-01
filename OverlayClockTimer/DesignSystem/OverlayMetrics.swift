import CoreGraphics
import Foundation

enum OverlayMetrics {
    static let defaultSize = OverlayPreferences.defaultWindowSize
    static let minimumSize = OverlayPreferences.minimumWindowSize
    static let maximumSize = OverlayPreferences.maximumWindowSize
    static let cornerRadius: CGFloat = 24
    static let controlButtonSize: CGFloat = 32
    static let controlCornerRadius: CGFloat = 8
    static let compactToolbarSpacing: CGFloat = 4
    static let toolbarGroupSpacing: CGFloat = 8
    static let toolbarIconSize: CGFloat = 15
    static let epochToggleIconSize: CGFloat = 18
    static let horizontalPadding: CGFloat = 12
    static let verticalPadding: CGFloat = 10
    static let defaultTimerFontSize: CGFloat = CGFloat(OverlayPreferences.defaultTimerFontSize)
    static let inputLoggingTableHeaderHeight: CGFloat = 28
    static let inputLoggingTableRowHeight: CGFloat = 25
    static let inputLoggingTableHeight: CGFloat =
        inputLoggingTableHeaderHeight
        + CGFloat(OverlayPreferences.defaultEventTableRowLimit) * inputLoggingTableRowHeight
    static let inputLoggingExpandedHeightDelta: CGFloat = inputLoggingTableHeight + 46
    static let maximumExpandedSize = CGSize(
        width: maximumSize.width,
        height: maximumSize.height + inputLoggingExpandedHeightDelta
    )
    static let minimumBackgroundOpacity = OverlayPreferences.minimumBackgroundOpacity
    static let defaultBackgroundOpacity = OverlayPreferences.defaultBackgroundOpacity
    static let maximumBackgroundOpacity = OverlayPreferences.maximumBackgroundOpacity
}
