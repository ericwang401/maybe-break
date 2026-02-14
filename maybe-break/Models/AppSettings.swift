import SwiftUI
import Combine

@Observable
final class AppSettings {
    static let shared = AppSettings()

    // MARK: - Break Schedule
    var shortBreakInterval: TimeInterval {
        get { UserDefaults.standard.double(forKey: "shortBreakInterval").nonZero ?? 1200 }
        set { UserDefaults.standard.set(newValue, forKey: "shortBreakInterval") }
    }
    var shortBreakDuration: TimeInterval {
        get { UserDefaults.standard.double(forKey: "shortBreakDuration").nonZero ?? 20 }
        set { UserDefaults.standard.set(newValue, forKey: "shortBreakDuration") }
    }
    var longBreakInterval: TimeInterval {
        get { UserDefaults.standard.double(forKey: "longBreakInterval").nonZero ?? 3600 }
        set { UserDefaults.standard.set(newValue, forKey: "longBreakInterval") }
    }
    var longBreakDuration: TimeInterval {
        get { UserDefaults.standard.double(forKey: "longBreakDuration").nonZero ?? 300 }
        set { UserDefaults.standard.set(newValue, forKey: "longBreakDuration") }
    }
    var longBreaksEnabled: Bool {
        get { UserDefaults.standard.object(forKey: "longBreaksEnabled") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "longBreaksEnabled") }
    }
    var headsUpDuration: TimeInterval {
        get { UserDefaults.standard.double(forKey: "headsUpDuration").nonZero ?? 30 }
        set { UserDefaults.standard.set(newValue, forKey: "headsUpDuration") }
    }

    // MARK: - Smart Pause
    var smartPauseIdleEnabled: Bool {
        get { UserDefaults.standard.object(forKey: "smartPauseIdleEnabled") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "smartPauseIdleEnabled") }
    }
    var smartPauseIdleThreshold: TimeInterval {
        get { UserDefaults.standard.double(forKey: "smartPauseIdleThreshold").nonZero ?? 300 }
        set { UserDefaults.standard.set(newValue, forKey: "smartPauseIdleThreshold") }
    }
    var smartPauseFullscreenEnabled: Bool {
        get { UserDefaults.standard.object(forKey: "smartPauseFullscreenEnabled") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "smartPauseFullscreenEnabled") }
    }
    var smartPauseCooldown: TimeInterval {
        get { UserDefaults.standard.double(forKey: "smartPauseCooldown").nonZero ?? 120 }
        set { UserDefaults.standard.set(newValue, forKey: "smartPauseCooldown") }
    }

    // MARK: - Sound
    var playSoundOnBreakStart: Bool {
        get { UserDefaults.standard.object(forKey: "playSoundOnBreakStart") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "playSoundOnBreakStart") }
    }
    var playSoundOnBreakEnd: Bool {
        get { UserDefaults.standard.object(forKey: "playSoundOnBreakEnd") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "playSoundOnBreakEnd") }
    }
    var soundVolume: Float {
        get {
            let val = UserDefaults.standard.float(forKey: "soundVolume")
            return val == 0 ? 0.7 : val
        }
        set { UserDefaults.standard.set(newValue, forKey: "soundVolume") }
    }

    // MARK: - Appearance
    var gradientStartColor: Color {
        get {
            if let data = UserDefaults.standard.data(forKey: "gradientStartColor"),
               let nsColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) {
                return Color(nsColor: nsColor)
            }
            return Color(red: 0.4, green: 0.3, blue: 0.7)
        }
        set {
            if let data = try? NSKeyedArchiver.archivedData(withRootObject: NSColor(newValue), requiringSecureCoding: true) {
                UserDefaults.standard.set(data, forKey: "gradientStartColor")
            }
        }
    }
    var gradientEndColor: Color {
        get {
            if let data = UserDefaults.standard.data(forKey: "gradientEndColor"),
               let nsColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) {
                return Color(nsColor: nsColor)
            }
            return Color(red: 0.5, green: 0.4, blue: 0.8)
        }
        set {
            if let data = try? NSKeyedArchiver.archivedData(withRootObject: NSColor(newValue), requiringSecureCoding: true) {
                UserDefaults.standard.set(data, forKey: "gradientEndColor")
            }
        }
    }

    // MARK: - Custom Messages
    var customMessagesEnabled: Bool {
        get { UserDefaults.standard.object(forKey: "customMessagesEnabled") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "customMessagesEnabled") }
    }
    var customMessages: [String] {
        get {
            UserDefaults.standard.stringArray(forKey: "customMessages") ?? [
                "Relax those eyes",
                "Look at something distant",
                "Breathe, relax, and come back",
                "Take a moment to rest your eyes",
                "Drink some water and look away"
            ]
        }
        set { UserDefaults.standard.set(newValue, forKey: "customMessages") }
    }

    // MARK: - Wellness
    var blinkReminderEnabled: Bool {
        get { UserDefaults.standard.object(forKey: "blinkReminderEnabled") as? Bool ?? false }
        set { UserDefaults.standard.set(newValue, forKey: "blinkReminderEnabled") }
    }
    var blinkReminderInterval: TimeInterval {
        get { UserDefaults.standard.double(forKey: "blinkReminderInterval").nonZero ?? 600 }
        set { UserDefaults.standard.set(newValue, forKey: "blinkReminderInterval") }
    }
    var postureReminderEnabled: Bool {
        get { UserDefaults.standard.object(forKey: "postureReminderEnabled") as? Bool ?? false }
        set { UserDefaults.standard.set(newValue, forKey: "postureReminderEnabled") }
    }
    var postureReminderInterval: TimeInterval {
        get { UserDefaults.standard.double(forKey: "postureReminderInterval").nonZero ?? 1800 }
        set { UserDefaults.standard.set(newValue, forKey: "postureReminderInterval") }
    }

    // MARK: - General
    var launchAtLogin: Bool {
        get { UserDefaults.standard.bool(forKey: "launchAtLogin") }
        set { UserDefaults.standard.set(newValue, forKey: "launchAtLogin") }
    }

    private init() {}
}

private extension Double {
    var nonZero: Double? { self == 0 ? nil : self }
}
