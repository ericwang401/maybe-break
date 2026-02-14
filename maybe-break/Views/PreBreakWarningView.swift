import AppKit
import SwiftUI

final class PreBreakTooltipWindow {
    private var window: NSPanel?
    private var mouseMonitor: Any?
    private var updateTimer: Timer?

    func show() {
        close()

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 260, height: 48),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.level = .floating
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.ignoresMouseEvents = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        updateContent(panel: panel)
        self.window = panel

        // Position near cursor
        let mouseLocation = NSEvent.mouseLocation
        positionWindow(at: mouseLocation)
        panel.orderFront(nil)

        // Track mouse movement
        mouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { [weak self] event in
            self?.positionWindow(at: NSEvent.mouseLocation)
        }

        // Update countdown every second
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self, let panel = self.window else { return }
            self.updateContent(panel: panel)
        }
    }

    func close() {
        if let monitor = mouseMonitor {
            NSEvent.removeMonitor(monitor)
            mouseMonitor = nil
        }
        updateTimer?.invalidate()
        updateTimer = nil
        window?.orderOut(nil)
        window = nil
    }

    private func positionWindow(at point: NSPoint) {
        guard let window else { return }
        let offset: CGFloat = 20
        let newOrigin = NSPoint(
            x: point.x + offset,
            y: point.y - window.frame.height - offset
        )
        window.setFrameOrigin(newOrigin)
    }

    private func updateContent(panel: NSPanel) {
        let breakManager = BreakManager.shared
        let seconds = max(0, Int(breakManager.timeRemaining))

        let hostView = NSHostingView(rootView:
            HStack(spacing: 10) {
                Image(systemName: "eyes")
                    .font(.system(size: 20))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.pink, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("Starting break in")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)

                Text("\(seconds)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.black.opacity(0.85))
            )
        )

        panel.contentView = hostView
        let fittingSize = hostView.fittingSize
        panel.setContentSize(fittingSize)
    }
}
