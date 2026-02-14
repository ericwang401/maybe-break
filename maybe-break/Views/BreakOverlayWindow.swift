import AppKit
import SwiftUI

@Observable
final class OverlayDismissSignal {
    var isDismissing = false
}

final class BreakOverlayWindow {
    private var windows: [NSWindow] = []
    private var dismissSignal = OverlayDismissSignal()

    func show() {
        removeWindows()
        dismissSignal = OverlayDismissSignal()

        for screen in NSScreen.screens {
            let window = NSPanel(
                contentRect: screen.frame,
                styleMask: [.borderless, .nonactivatingPanel],
                backing: .buffered,
                defer: false
            )
            window.level = .screenSaver
            window.isOpaque = false
            window.backgroundColor = .clear
            window.hasShadow = false
            window.ignoresMouseEvents = false
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            window.setFrame(screen.frame, display: true)

            let hostView = NSHostingView(rootView:
                BreakOverlayView(
                    breakManager: BreakManager.shared,
                    dismissSignal: dismissSignal,
                    onSkip: { [weak self] in self?.skipBreak() },
                    onLockScreen: { Self.lockScreen() }
                )
            )
            window.contentView = hostView
            window.makeKeyAndOrderFront(nil)
            windows.append(window)
        }

        windows.first?.makeKey()
    }

    func close() {
        guard !windows.isEmpty else { return }

        // Trigger exit animation
        dismissSignal.isDismissing = true

        // Remove windows after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.removeWindows()
        }
    }

    private func removeWindows() {
        for window in windows {
            window.orderOut(nil)
        }
        windows.removeAll()
    }

    private func skipBreak() {
        // Skip uses instant close, no exit animation
        removeWindows()
        BreakManager.shared.skipBreak()
    }

    static func lockScreen() {
        let task = Process()
        task.launchPath = "/usr/bin/pmset"
        task.arguments = ["displaysleepnow"]
        try? task.run()
    }
}
