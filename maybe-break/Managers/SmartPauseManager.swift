import AppKit
import CoreGraphics

final class SmartPauseManager {
    static let shared = SmartPauseManager()

    private var checkTimer: Timer?
    private var breakManager: BreakManager { BreakManager.shared }
    private var settings: AppSettings { AppSettings.shared }
    private var wasPausedBySmartPause = false
    private var cooldownRemaining: TimeInterval = 0

    private init() {}

    func start() {
        checkTimer?.invalidate()
        checkTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.check()
        }
    }

    func stop() {
        checkTimer?.invalidate()
        checkTimer = nil
    }

    private func check() {
        let shouldPause = shouldPauseNow()

        if shouldPause && !breakManager.isPaused && !breakManager.isOnBreak {
            wasPausedBySmartPause = true
            breakManager.pause()
        } else if !shouldPause && wasPausedBySmartPause && breakManager.isPaused {
            wasPausedBySmartPause = false
            if settings.smartPauseCooldown > 0 {
                cooldownRemaining = settings.smartPauseCooldown
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                    guard let self else { timer.invalidate(); return }
                    self.cooldownRemaining -= 1
                    if self.cooldownRemaining <= 0 {
                        timer.invalidate()
                        self.breakManager.resume()
                    }
                }
            } else {
                breakManager.resume()
            }
        }
    }

    private func shouldPauseNow() -> Bool {
        if settings.smartPauseIdleEnabled && isUserIdle() {
            return true
        }
        if settings.smartPauseFullscreenEnabled && isFrontmostAppFullscreen() {
            return true
        }
        return false
    }

    private func isUserIdle() -> Bool {
        let idleTime = CGEventSource.secondsSinceLastEventType(
            .hidSystemState,
            eventType: CGEventType(rawValue: ~0)!
        )
        return idleTime > settings.smartPauseIdleThreshold
    }

    private func isFrontmostAppFullscreen() -> Bool {
        guard let frontApp = NSWorkspace.shared.frontmostApplication else { return false }
        guard let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] else {
            return false
        }
        let pid = frontApp.processIdentifier
        for window in windows {
            guard let windowPID = window[kCGWindowOwnerPID as String] as? Int32,
                  windowPID == pid,
                  let bounds = window[kCGWindowBounds as String] as? [String: CGFloat] else {
                continue
            }
            if let screen = NSScreen.main {
                let screenFrame = screen.frame
                let width = bounds["Width"] ?? 0
                let height = bounds["Height"] ?? 0
                if width >= screenFrame.width && height >= screenFrame.height {
                    return true
                }
            }
        }
        return false
    }
}
