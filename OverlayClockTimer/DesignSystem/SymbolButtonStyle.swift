import SwiftUI

struct SymbolButtonStyle: ButtonStyle {
    var buttonSize: CGFloat = OverlayMetrics.controlButtonSize
    var cornerRadius: CGFloat = OverlayMetrics.controlCornerRadius

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: buttonSize, height: buttonSize)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.primary.opacity(configuration.isPressed ? 0.18 : 0.10))
            )
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
