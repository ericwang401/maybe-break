import SwiftUI

struct MenuBarMenuView: View {
    private let breakManager = BreakManager.shared

    var body: some View {
        // Status section
        Section {
            Text(statusTitle)
                .font(.headline)
            Text(statusSubtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }

        Divider()

        // Controls
        Section {
            if breakManager.isPaused {
                Button("Resume") {
                    breakManager.resume()
                }
            } else {
                Button("Pause") {
                    breakManager.pause()
                }
            }

            if breakManager.isOnBreak {
                Button("Skip Break") {
                    breakManager.skipBreak()
                }
            } else if !breakManager.isPaused {
                Button("Skip Next Break") {
                    breakManager.skipBreak()
                }
                Button("Take Break Now") {
                    breakManager.startBreakNow()
                }
            }
        }

        Divider()

        Section {
            Button("Settings...") {
                SettingsWindowController.shared.open()
            }
            .keyboardShortcut(",", modifiers: .command)

            Button("Quit maybe-break") {
                NSApp.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
        }
    }

    private var statusTitle: String {
        switch breakManager.state {
        case .working: return "Next break in \(breakManager.formattedTimeRemaining)"
        case .headsUp: return "Break starting in \(breakManager.formattedTimeRemaining)"
        case .onBreak(let isLong):
            return "\(isLong ? "Long" : "Short") break – \(breakManager.formattedBreakTimeRemaining)"
        case .paused: return "Paused"
        }
    }

    private var statusSubtitle: String {
        switch breakManager.state {
        case .working: return "Stay focused, we'll remind you"
        case .headsUp: return "Get ready to rest your eyes"
        case .onBreak: return "Look at something distant"
        case .paused: return "Timers are paused"
        }
    }
}
