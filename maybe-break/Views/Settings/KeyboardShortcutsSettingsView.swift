import SwiftUI

struct KeyboardShortcutsSettingsView: View {
    var body: some View {
        SettingsDetailPage(title: "Keyboard Shortcuts") {
            SettingsSection {
                shortcutRow("Take Break Now", shortcut: "Ctrl + Option + B")
                SettingsDivider()
                shortcutRow("Pause/Resume", shortcut: "Ctrl + Option + P")
                SettingsDivider()
                shortcutRow("Skip Break", shortcut: "Ctrl + Option + S")
                SettingsDivider()
                shortcutRow("Open Settings", shortcut: "Ctrl + Option + ,")
            }

            Text("Keyboard shortcuts are currently not customizable.")
                .font(.system(size: 11))
                .foregroundStyle(.tertiary)
                .padding(.leading, 4)
        }
    }

    @ViewBuilder
    private func shortcutRow(_ action: String, shortcut: String) -> some View {
        SettingsRow(action) {
            Text(shortcut)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color(nsColor: .quaternarySystemFill))
                )
        }
    }
}
