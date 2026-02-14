import SwiftUI

@main
struct maybe_breakApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra {
            MenuBarMenuView()
        } label: {
            Label {
                Text(menuBarText)
            } icon: {
                Image(systemName: menuBarIcon)
            }
        }
        .menuBarExtraStyle(.menu)
    }

    private var menuBarIcon: String {
        switch BreakManager.shared.state {
        case .paused: return "pause.circle"
        default: return "eyes"
        }
    }

    private var menuBarText: String {
        let bm = BreakManager.shared
        switch bm.state {
        case .working, .headsUp: return bm.menuBarTimeString
        case .onBreak: return bm.formattedBreakTimeRemaining
        case .paused: return "paused"
        }
    }
}
