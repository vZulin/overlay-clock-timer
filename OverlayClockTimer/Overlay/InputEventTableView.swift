import SwiftUI

struct InputEventTableView: View {
    @ObservedObject var store: InputEventStore
    let tokens: OverlayThemeTokens

    var body: some View {
        VStack(spacing: 8) {
            statusBar

            ZStack {
                eventTable

                if store.visibleRows.isEmpty {
                    emptyState
                }
            }
            .frame(height: OverlayMetrics.inputLoggingTableHeight)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("inputLogging.eventTable")
        }
        .padding(.horizontal, OverlayMetrics.horizontalPadding)
        .padding(.bottom, OverlayMetrics.verticalPadding)
        .accessibilityIdentifier("inputLogging.panel")
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private var eventTable: some View {
        Table(store.visibleRows) {
            TableColumn("Time") { record in
                Text(record.timestamp)
                    .monospacedDigit()
                    .lineLimit(1)
            }
            .width(min: 92, ideal: 104, max: 120)

            TableColumn("Type") { record in
                Text(record.category.rawValue.capitalized)
                    .lineLimit(1)
            }
            .width(min: 70, ideal: 76, max: 90)

            TableColumn("Event") { record in
                Text(record.name)
                    .lineLimit(1)
                    .accessibilityIdentifier(
                        "inputLogging.eventName.\(record.name.inputLoggingAccessibilityIdentifierComponent)"
                    )
            }

            TableColumn("Phase") { record in
                Text(record.phase?.rawValue ?? "-")
                    .lineLimit(1)
            }
            .width(min: 82, ideal: 92, max: 116)
        }
        .accessibilityIdentifier("inputLogging.eventTable")
    }

    private var statusBar: some View {
        HStack(spacing: 8) {
            statusLabel(
                "Capture",
                status: store.captureStatus,
                identifier: "inputLogging.captureStatus"
            )
            statusLabel(
                "File",
                status: store.fileRecordingStatus,
                identifier: "inputLogging.fileStatus"
            )
            Spacer(minLength: 8)
            Text("\(store.visibleRows.count)/\(store.preferences.eventTableRowLimit)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(tokens.secondaryTextColor)
                .accessibilityIdentifier("inputLogging.rowCount")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 6) {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(tokens.secondaryTextColor)

            Text("No input events")
                .font(.caption.weight(.medium))
                .foregroundStyle(tokens.secondaryTextColor)
                .accessibilityIdentifier("inputLogging.emptyState")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(tokens.panelColor.opacity(0.82))
    }

    private func statusLabel(
        _ title: String,
        status: InputLoggingSessionStatus,
        identifier: String
    ) -> some View {
        Label {
            Text("\(title): \(status.title)")
                .font(.caption2)
                .accessibilityIdentifier(identifier)
        } icon: {
            Image(systemName: status.systemImage)
                .font(.caption2)
        }
        .foregroundStyle(status.isUnavailable ? Color.red : tokens.secondaryTextColor)
        .accessibilityLabel("\(title) \(status.title)")
    }
}

private extension String {
    var inputLoggingAccessibilityIdentifierComponent: String {
        let sanitized = lowercased().map { character -> Character in
            character.isLetter || character.isNumber ? character : "-"
        }
        return String(sanitized).trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }
}

private extension InputLoggingSessionStatus {
    var title: String {
        switch self {
        case .inactive:
            return "Inactive"
        case .active:
            return "Active"
        case .unavailable:
            return "Unavailable"
        }
    }

    var systemImage: String {
        switch self {
        case .inactive:
            return "circle"
        case .active:
            return "checkmark.circle"
        case .unavailable:
            return "exclamationmark.triangle"
        }
    }

    var isUnavailable: Bool {
        if case .unavailable = self {
            return true
        }
        return false
    }
}
