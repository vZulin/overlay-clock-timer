import SwiftUI

struct SymbolButtonStyle: ButtonStyle {
    var backgroundColor: Color = Color.primary.opacity(0.10)
    var buttonSize: CGFloat = OverlayMetrics.controlButtonSize
    var cornerRadius: CGFloat = OverlayMetrics.controlCornerRadius

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: buttonSize, height: buttonSize)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor.opacity(configuration.isPressed ? 0.75 : 1.0))
            )
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
