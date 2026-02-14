import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var breakOverlay: BreakOverlayWindow!
    private var tooltipWindow: PreBreakTooltipWindow!

    private let breakManager = BreakManager.shared
    private let smartPauseManager = SmartPauseManager.shared
    private let wellnessManager = WellnessManager.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon
        NSApp.setActivationPolicy(.accessory)

        // Setup components
        breakOverlay = BreakOverlayWindow()
        tooltipWindow = PreBreakTooltipWindow()

        setupCallbacks()

        // Start everything
        breakManager.start()
        smartPauseManager.start()
        wellnessManager.start()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    // MARK: - Callbacks

    private func setupCallbacks() {
        breakManager.onHeadsUpStart = { [weak self] in
            self?.tooltipWindow.show()
        }

        breakManager.onHeadsUpEnd = { [weak self] in
            self?.tooltipWindow.close()
        }

        breakManager.onBreakStart = { [weak self] in
            SoundManager.shared.playBreakStartSound()
            self?.breakOverlay.show()
        }

        breakManager.onBreakEnd = { [weak self] in
            SoundManager.shared.playBreakEndSound()
            self?.breakOverlay.close()
        }
    }
}
