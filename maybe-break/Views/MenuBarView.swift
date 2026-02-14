import SwiftUI

struct MenuBarMenuView: View {
    private let breakManager = BreakManager.shared
    var dismissAction: (() -> Void)?
    @State private var pauseExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Status header (disabled, non-interactive)
            VStack(alignment: .leading, spacing: 1) {
                Text(statusTitle)
                    .font(.system(size: 13, weight: .medium))
                Text(statusSubtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 14)
            .padding(.top, 6)
            .padding(.bottom, 4)

            menuDivider()

            if breakManager.isRunning {
                if breakManager.isOnBreak {
                    menuButton("Skip This Break", shortcut: "⌘S") {
                        breakManager.skipBreak()
                    }
                } else if !breakManager.isPaused {
                    menuButton("Take Break Now") {
                        breakManager.startBreakNow()
                    }

                    menuDivider()

                    menuButton("Add 1 Minute") {
                        breakManager.addTime(60)
                    }
                    menuButton("Add 5 Minutes") {
                        breakManager.addTime(300)
                    }

                    menuDivider()

                    // Pause for — inline expand
                    MenuItemRow(isHoverable: true) {
                        pauseExpanded.toggle()
                    } content: {
                        Text("Pause for")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.secondary)
                    }

                    if pauseExpanded {
                        menuButton("  5 minutes") {
                            breakManager.pauseFor(5 * 60)
                        }
                        menuButton("  15 minutes") {
                            breakManager.pauseFor(15 * 60)
                        }
                        menuButton("  30 minutes") {
                            breakManager.pauseFor(30 * 60)
                        }
                        menuButton("  1 hour") {
                            breakManager.pauseFor(60 * 60)
                        }
                        menuButton("  Until I resume") {
                            breakManager.pause()
                        }
                    }

                    menuDivider()

                    menuButton("Skip This Break", shortcut: "⌘S") {
                        breakManager.skipBreak()
                    }
                } else {
                    // Paused
                    menuButton("Resume") {
                        breakManager.resume()
                    }

                    menuDivider()
                }

                menuButton("Stop Maybe Break") {
                    breakManager.stop()
                }
            } else {
                menuButton("Start Maybe Break") {
                    breakManager.start()
                }
            }

            menuDivider()

            menuButton("Settings...", shortcut: "⌘,") {
                SettingsWindowController.shared.open()
            }
            menuButton("Quit", shortcut: "⌘Q") {
                NSApp.terminate(nil)
            }
        }
        .padding(.vertical, 4)
        .frame(width: 260)
    }

    // MARK: - Helpers

    private func menuButton(_ title: String, shortcut: String? = nil, action: @escaping () -> Void) -> some View {
        MenuItemRow(isHoverable: true) {
            action()
            dismissAction?()
        } content: {
            Text(title)
            Spacer()
            if let shortcut {
                Text(shortcut)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func menuDivider() -> some View {
        Divider()
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
    }

    private var statusTitle: String {
        if !breakManager.isRunning { return "Maybe Break" }
        switch breakManager.state {
        case .working: return "Next break in \(breakManager.formattedTimeRemaining)"
        case .headsUp: return "Break starting in \(breakManager.formattedTimeRemaining)"
        case .onBreak(let isLong):
            return "\(isLong ? "Long" : "Short") break – \(breakManager.formattedBreakTimeRemaining)"
        case .paused: return "Paused"
        }
    }

    private var statusSubtitle: String {
        if !breakManager.isRunning { return "Not running" }
        switch breakManager.state {
        case .working: return "Stay focused"
        case .headsUp: return "Get ready to rest your eyes"
        case .onBreak: return "Look at something distant"
        case .paused: return "Timers are paused"
        }
    }
}

// MARK: - Menu item row (emulates native NSMenuItem)

private struct MenuItemRow<Content: View>: View {
    let isHoverable: Bool
    let action: () -> Void
    @ViewBuilder let content: Content
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 0) {
            content
        }
        .font(.system(size: 13))
        .foregroundStyle(isHovered ? .white : .primary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(isHovered ? Color.accentColor : .clear)
        )
        .padding(.horizontal, 5)
        .contentShape(Rectangle())
        .onHover { hover in
            guard isHoverable else { return }
            isHovered = hover
        }
        .onTapGesture {
            action()
        }
    }
}
