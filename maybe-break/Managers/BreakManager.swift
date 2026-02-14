import SwiftUI
import UserNotifications

enum BreakState: Equatable {
    case working
    case headsUp
    case onBreak(isLong: Bool)
    case paused
}

@Observable
final class BreakManager {
    static let shared = BreakManager()

    private(set) var state: BreakState = .working
    private(set) var timeRemaining: TimeInterval = 0
    private(set) var breakTimeRemaining: TimeInterval = 0
    private(set) var shortBreaksTaken: Int = 0

    var isPaused: Bool { state == .paused }
    var isOnBreak: Bool {
        if case .onBreak = state { return true }
        return false
    }

    private var workTimer: Timer?
    private var breakTimer: Timer?
    private var headsUpTimer: Timer?
    private var stateBeforePause: BreakState = .working
    private var timeRemainingBeforePause: TimeInterval = 0
    private var settings: AppSettings { AppSettings.shared }

    var onBreakStart: (() -> Void)?
    var onBreakEnd: (() -> Void)?
    var onHeadsUpStart: (() -> Void)?
    var onHeadsUpEnd: (() -> Void)?

    private init() {
        requestNotificationPermission()
    }

    func start() {
        startWorkTimer()
    }

    func pause() {
        guard state != .paused else { return }
        stateBeforePause = state
        timeRemainingBeforePause = timeRemaining
        state = .paused
        stopAllTimers()
    }

    func resume() {
        guard state == .paused else { return }
        state = stateBeforePause
        if state == .working {
            timeRemaining = timeRemainingBeforePause
            startWorkCountdown()
        } else if case .onBreak = state {
            breakTimeRemaining = timeRemainingBeforePause
            startBreakCountdown()
        }
    }

    func skipBreak() {
        stopAllTimers()
        onHeadsUpEnd?()
        onBreakEnd?()
        state = .working
        startWorkTimer()
    }

    func postpone(by seconds: TimeInterval) {
        guard state == .headsUp else { return }
        stopAllTimers()
        onHeadsUpEnd?()
        state = .working
        timeRemaining = seconds
        startWorkCountdown()
    }

    func startBreakNow() {
        stopAllTimers()
        onHeadsUpEnd?()
        beginBreak()
    }

    // MARK: - Private

    private func startWorkTimer() {
        shortBreaksTaken = 0
        timeRemaining = settings.shortBreakInterval
        startWorkCountdown()
    }

    private func startWorkCountdown() {
        workTimer?.invalidate()
        workTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.timeRemaining -= 1

            if self.timeRemaining <= self.settings.headsUpDuration && self.state == .working {
                self.state = .headsUp
                self.onHeadsUpStart?()
                self.sendHeadsUpNotification()
            }

            if self.timeRemaining <= 0 {
                self.workTimer?.invalidate()
                self.onHeadsUpEnd?()
                self.beginBreak()
            }
        }
    }

    private func beginBreak() {
        let isLong = settings.longBreaksEnabled &&
            shortBreaksTaken > 0 &&
            (shortBreaksTaken + 1) % max(1, Int(settings.longBreakInterval / settings.shortBreakInterval)) == 0

        state = .onBreak(isLong: isLong)
        breakTimeRemaining = isLong ? settings.longBreakDuration : settings.shortBreakDuration
        onBreakStart?()
        startBreakCountdown()
    }

    private func startBreakCountdown() {
        breakTimer?.invalidate()
        breakTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.breakTimeRemaining -= 1
            if self.breakTimeRemaining <= 0 {
                self.endBreak()
            }
        }
    }

    private func endBreak() {
        stopAllTimers()
        shortBreaksTaken += 1
        onBreakEnd?()
        state = .working
        timeRemaining = settings.shortBreakInterval
        startWorkCountdown()
    }

    private func stopAllTimers() {
        workTimer?.invalidate()
        breakTimer?.invalidate()
        headsUpTimer?.invalidate()
        workTimer = nil
        breakTimer = nil
        headsUpTimer = nil
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    private func sendHeadsUpNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Almost time – \(formatTime(timeRemaining))"
        content.body = "Take a break and rest your eyes"
        content.sound = .default

        let request = UNNotificationRequest(identifier: "headsUp", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        if mins > 0 {
            return String(format: "%02d:%02d", mins, secs)
        }
        return String(format: "00:%02d", secs)
    }

    var formattedTimeRemaining: String {
        formatTime(timeRemaining)
    }

    var formattedBreakTimeRemaining: String {
        formatTime(breakTimeRemaining)
    }

    var menuBarTimeString: String {
        let mins = Int(timeRemaining) / 60
        let secs = Int(timeRemaining) % 60
        if mins > 0 { return "\(mins)m" }
        return "\(secs)s"
    }
}
