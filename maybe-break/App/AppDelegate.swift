import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var breakOverlay: BreakOverlayWindow!
    private var tooltipWindow: PreBreakTooltipWindow!

    private let breakManager = BreakManager.shared
    private let smartPauseManager = SmartPauseManager.shared
    private let wellnessManager = WellnessManager.shared

    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var statusUpdateTimer: Timer?
    private var clickMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        setupStatusItem()

        breakOverlay = BreakOverlayWindow()
        tooltipWindow = PreBreakTooltipWindow()

        setupCallbacks()

        breakManager.start()
        smartPauseManager.start()
        wellnessManager.start()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    // MARK: - Status Item

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateStatusButton()

        if let button = statusItem.button {
            button.action = #selector(togglePopover)
            button.target = self
        }

        popover = NSPopover()
        popover.contentSize = NSSize(width: 260, height: 10)
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSHostingController(
            rootView: MenuBarMenuView(dismissAction: { [weak self] in
                self?.closePopover()
            })
        )

        statusUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateStatusButton()
        }
    }

    private func updateStatusButton() {
        guard let button = statusItem.button else { return }
        let bm = breakManager

        let icon: String
        let text: String

        if !bm.isRunning {
            icon = "eyes.inverse"
            text = ""
        } else {
            switch bm.state {
            case .paused:
                icon = "pause.circle"
                text = " paused"
            case .working, .headsUp:
                icon = "eyes"
                text = " \(bm.menuBarTimeString)"
            case .onBreak:
                icon = "eyes"
                text = " \(bm.formattedBreakTimeRemaining)"
            }
        }

        button.image = NSImage(systemSymbolName: icon, accessibilityDescription: nil)
        button.title = text
    }

    @objc private func togglePopover() {
        if popover.isShown {
            closePopover()
        } else {
            showPopover()
        }
    }

    private func showPopover() {
        guard let button = statusItem.button else { return }
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)

        // Monitor for clicks outside the popover to dismiss it
        clickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.closePopover()
        }
    }

    private func closePopover() {
        popover.performClose(nil)
        if let monitor = clickMonitor {
            NSEvent.removeMonitor(monitor)
            clickMonitor = nil
        }
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
