import SwiftUI
import Combine

// MARK: - Settings Enums

enum MenuBarDisplayMode: String, CaseIterable, Identifiable {
    case timeUntilBreak = "Time Until Break"
    case icon = "Icon Only"
    case iconAndTime = "Icon & Time"
    var id: String { rawValue }
}

enum TimerStyle: String, CaseIterable, Identifiable {
    case countDown = "Count Down"
    case countUp = "Count Up"
    case progress = "Progress Bar"
    var id: String { rawValue }
}

enum BreakSkipDifficulty: String, CaseIterable, Identifiable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    var id: String { rawValue }
}

enum ReminderDesign: String, CaseIterable, Identifiable {
    case banner = "Banner"
    case fullScreen = "Full Screen"
    var id: String { rawValue }
}

enum BackgroundStyle: String, CaseIterable, Identifiable {
    case gradient = "Gradient"
    case solid = "Solid"
    var id: String { rawValue }
}

enum AlertPosition: String, CaseIterable, Identifiable {
    case topRight = "Top Right"
    case topLeft = "Top Left"
    case bottomRight = "Bottom Right"
    case bottomLeft = "Bottom Left"
    var id: String { rawValue }
}

// MARK: - App Settings

@Observable
final class AppSettings {
    static let shared = AppSettings()

    // MARK: - Break Schedule
    var shortBreakInterval: TimeInterval {
        get { access(keyPath: \.shortBreakInterval); return ud.double(forKey: "shortBreakInterval").nonZero ?? 1200 }
        set { withMutation(keyPath: \.shortBreakInterval) { ud.set(newValue, forKey: "shortBreakInterval") } }
    }
    var shortBreakDuration: TimeInterval {
        get { access(keyPath: \.shortBreakDuration); return ud.double(forKey: "shortBreakDuration").nonZero ?? 20 }
        set { withMutation(keyPath: \.shortBreakDuration) { ud.set(newValue, forKey: "shortBreakDuration") } }
    }
    var longBreakInterval: TimeInterval {
        get { access(keyPath: \.longBreakInterval); return ud.double(forKey: "longBreakInterval").nonZero ?? 3600 }
        set { withMutation(keyPath: \.longBreakInterval) { ud.set(newValue, forKey: "longBreakInterval") } }
    }
    var longBreakDuration: TimeInterval {
        get { access(keyPath: \.longBreakDuration); return ud.double(forKey: "longBreakDuration").nonZero ?? 300 }
        set { withMutation(keyPath: \.longBreakDuration) { ud.set(newValue, forKey: "longBreakDuration") } }
    }
    var longBreaksEnabled: Bool {
        get { access(keyPath: \.longBreaksEnabled); return ud.object(forKey: "longBreaksEnabled") as? Bool ?? true }
        set { withMutation(keyPath: \.longBreaksEnabled) { ud.set(newValue, forKey: "longBreaksEnabled") } }
    }
    var headsUpDuration: TimeInterval {
        get { access(keyPath: \.headsUpDuration); return ud.double(forKey: "headsUpDuration").nonZero ?? 30 }
        set { withMutation(keyPath: \.headsUpDuration) { ud.set(newValue, forKey: "headsUpDuration") } }
    }
    var skipBreakWhileTyping: Bool {
        get { access(keyPath: \.skipBreakWhileTyping); return ud.object(forKey: "skipBreakWhileTyping") as? Bool ?? false }
        set { withMutation(keyPath: \.skipBreakWhileTyping) { ud.set(newValue, forKey: "skipBreakWhileTyping") } }
    }
    var breakSkipDifficulty: BreakSkipDifficulty {
        get {
            access(keyPath: \.breakSkipDifficulty)
            guard let raw = ud.string(forKey: "breakSkipDifficulty"),
                  let val = BreakSkipDifficulty(rawValue: raw) else { return .medium }
            return val
        }
        set { withMutation(keyPath: \.breakSkipDifficulty) { ud.set(newValue.rawValue, forKey: "breakSkipDifficulty") } }
    }
    var breakReminderEnabled: Bool {
        get { access(keyPath: \.breakReminderEnabled); return ud.object(forKey: "breakReminderEnabled") as? Bool ?? true }
        set { withMutation(keyPath: \.breakReminderEnabled) { ud.set(newValue, forKey: "breakReminderEnabled") } }
    }
    var breakReminderDesign: ReminderDesign {
        get {
            access(keyPath: \.breakReminderDesign)
            guard let raw = ud.string(forKey: "breakReminderDesign"),
                  let val = ReminderDesign(rawValue: raw) else { return .banner }
            return val
        }
        set { withMutation(keyPath: \.breakReminderDesign) { ud.set(newValue.rawValue, forKey: "breakReminderDesign") } }
    }
    var breakReminderLeadTime: TimeInterval {
        get { access(keyPath: \.breakReminderLeadTime); return ud.double(forKey: "breakReminderLeadTime").nonZero ?? 30 }
        set { withMutation(keyPath: \.breakReminderLeadTime) { ud.set(newValue, forKey: "breakReminderLeadTime") } }
    }
    var breakReminderVisibleDuration: TimeInterval {
        get { access(keyPath: \.breakReminderVisibleDuration); return ud.double(forKey: "breakReminderVisibleDuration").nonZero ?? 10 }
        set { withMutation(keyPath: \.breakReminderVisibleDuration) { ud.set(newValue, forKey: "breakReminderVisibleDuration") } }
    }
    var breakReminderPlaySound: Bool {
        get { access(keyPath: \.breakReminderPlaySound); return ud.object(forKey: "breakReminderPlaySound") as? Bool ?? true }
        set { withMutation(keyPath: \.breakReminderPlaySound) { ud.set(newValue, forKey: "breakReminderPlaySound") } }
    }
    var countdownBeforeBreakEnabled: Bool {
        get { access(keyPath: \.countdownBeforeBreakEnabled); return ud.object(forKey: "countdownBeforeBreakEnabled") as? Bool ?? true }
        set { withMutation(keyPath: \.countdownBeforeBreakEnabled) { ud.set(newValue, forKey: "countdownBeforeBreakEnabled") } }
    }
    var countdownDuration: TimeInterval {
        get { access(keyPath: \.countdownDuration); return ud.double(forKey: "countdownDuration").nonZero ?? 5 }
        set { withMutation(keyPath: \.countdownDuration) { ud.set(newValue, forKey: "countdownDuration") } }
    }
    var overtimeNudgeEnabled: Bool {
        get { access(keyPath: \.overtimeNudgeEnabled); return ud.object(forKey: "overtimeNudgeEnabled") as? Bool ?? false }
        set { withMutation(keyPath: \.overtimeNudgeEnabled) { ud.set(newValue, forKey: "overtimeNudgeEnabled") } }
    }
    var overtimeNudgeWhenPaused: Bool {
        get { access(keyPath: \.overtimeNudgeWhenPaused); return ud.object(forKey: "overtimeNudgeWhenPaused") as? Bool ?? false }
        set { withMutation(keyPath: \.overtimeNudgeWhenPaused) { ud.set(newValue, forKey: "overtimeNudgeWhenPaused") } }
    }
    var allowEndBreakEarly: Bool {
        get { access(keyPath: \.allowEndBreakEarly); return ud.object(forKey: "allowEndBreakEarly") as? Bool ?? true }
        set { withMutation(keyPath: \.allowEndBreakEarly) { ud.set(newValue, forKey: "allowEndBreakEarly") } }
    }
    var lockMacOnBreak: Bool {
        get { access(keyPath: \.lockMacOnBreak); return ud.object(forKey: "lockMacOnBreak") as? Bool ?? false }
        set { withMutation(keyPath: \.lockMacOnBreak) { ud.set(newValue, forKey: "lockMacOnBreak") } }
    }
    var officeHoursEnabled: Bool {
        get { access(keyPath: \.officeHoursEnabled); return ud.object(forKey: "officeHoursEnabled") as? Bool ?? false }
        set { withMutation(keyPath: \.officeHoursEnabled) { ud.set(newValue, forKey: "officeHoursEnabled") } }
    }
    var officeHoursStart: Date {
        get {
            access(keyPath: \.officeHoursStart)
            if let date = ud.object(forKey: "officeHoursStart") as? Date { return date }
            return Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
        }
        set { withMutation(keyPath: \.officeHoursStart) { ud.set(newValue, forKey: "officeHoursStart") } }
    }
    var officeHoursEnd: Date {
        get {
            access(keyPath: \.officeHoursEnd)
            if let date = ud.object(forKey: "officeHoursEnd") as? Date { return date }
            return Calendar.current.date(from: DateComponents(hour: 17, minute: 0)) ?? Date()
        }
        set { withMutation(keyPath: \.officeHoursEnd) { ud.set(newValue, forKey: "officeHoursEnd") } }
    }

    // MARK: - Smart Pause
    var smartPauseIdleEnabled: Bool {
        get { access(keyPath: \.smartPauseIdleEnabled); return ud.object(forKey: "smartPauseIdleEnabled") as? Bool ?? true }
        set { withMutation(keyPath: \.smartPauseIdleEnabled) { ud.set(newValue, forKey: "smartPauseIdleEnabled") } }
    }
    var smartPauseIdleThreshold: TimeInterval {
        get { access(keyPath: \.smartPauseIdleThreshold); return ud.double(forKey: "smartPauseIdleThreshold").nonZero ?? 300 }
        set { withMutation(keyPath: \.smartPauseIdleThreshold) { ud.set(newValue, forKey: "smartPauseIdleThreshold") } }
    }
    var smartPauseFullscreenEnabled: Bool {
        get { access(keyPath: \.smartPauseFullscreenEnabled); return ud.object(forKey: "smartPauseFullscreenEnabled") as? Bool ?? true }
        set { withMutation(keyPath: \.smartPauseFullscreenEnabled) { ud.set(newValue, forKey: "smartPauseFullscreenEnabled") } }
    }
    var smartPauseCooldown: TimeInterval {
        get { access(keyPath: \.smartPauseCooldown); return ud.double(forKey: "smartPauseCooldown").nonZero ?? 120 }
        set { withMutation(keyPath: \.smartPauseCooldown) { ud.set(newValue, forKey: "smartPauseCooldown") } }
    }

    // MARK: - Sound
    var playSoundOnBreakStart: Bool {
        get { access(keyPath: \.playSoundOnBreakStart); return ud.object(forKey: "playSoundOnBreakStart") as? Bool ?? true }
        set { withMutation(keyPath: \.playSoundOnBreakStart) { ud.set(newValue, forKey: "playSoundOnBreakStart") } }
    }
    var playSoundOnBreakEnd: Bool {
        get { access(keyPath: \.playSoundOnBreakEnd); return ud.object(forKey: "playSoundOnBreakEnd") as? Bool ?? true }
        set { withMutation(keyPath: \.playSoundOnBreakEnd) { ud.set(newValue, forKey: "playSoundOnBreakEnd") } }
    }
    var soundVolume: Float {
        get { access(keyPath: \.soundVolume); let val = ud.float(forKey: "soundVolume"); return val == 0 ? 0.7 : val }
        set { withMutation(keyPath: \.soundVolume) { ud.set(newValue, forKey: "soundVolume") } }
    }
    var soundPairName: String {
        get { access(keyPath: \.soundPairName); return ud.string(forKey: "soundPairName") ?? "Default" }
        set { withMutation(keyPath: \.soundPairName) { ud.set(newValue, forKey: "soundPairName") } }
    }
    var wellnessSoundVolume: Float {
        get { access(keyPath: \.wellnessSoundVolume); let val = ud.float(forKey: "wellnessSoundVolume"); return val == 0 ? 0.5 : val }
        set { withMutation(keyPath: \.wellnessSoundVolume) { ud.set(newValue, forKey: "wellnessSoundVolume") } }
    }
    var alertSoundVolume: Float {
        get { access(keyPath: \.alertSoundVolume); let val = ud.float(forKey: "alertSoundVolume"); return val == 0 ? 0.5 : val }
        set { withMutation(keyPath: \.alertSoundVolume) { ud.set(newValue, forKey: "alertSoundVolume") } }
    }
    var smartPauseSoundEnabled: Bool {
        get { access(keyPath: \.smartPauseSoundEnabled); return ud.object(forKey: "smartPauseSoundEnabled") as? Bool ?? false }
        set { withMutation(keyPath: \.smartPauseSoundEnabled) { ud.set(newValue, forKey: "smartPauseSoundEnabled") } }
    }
    var overtimeNudgeSoundEnabled: Bool {
        get { access(keyPath: \.overtimeNudgeSoundEnabled); return ud.object(forKey: "overtimeNudgeSoundEnabled") as? Bool ?? false }
        set { withMutation(keyPath: \.overtimeNudgeSoundEnabled) { ud.set(newValue, forKey: "overtimeNudgeSoundEnabled") } }
    }

    // MARK: - Appearance
    var gradientStartColor: Color {
        get {
            access(keyPath: \.gradientStartColor)
            if let data = ud.data(forKey: "gradientStartColor"),
               let nsColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) {
                return Color(nsColor: nsColor)
            }
            return Color(red: 0.4, green: 0.3, blue: 0.7)
        }
        set {
            withMutation(keyPath: \.gradientStartColor) {
                if let data = try? NSKeyedArchiver.archivedData(withRootObject: NSColor(newValue), requiringSecureCoding: true) {
                    ud.set(data, forKey: "gradientStartColor")
                }
            }
        }
    }
    var gradientEndColor: Color {
        get {
            access(keyPath: \.gradientEndColor)
            if let data = ud.data(forKey: "gradientEndColor"),
               let nsColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) {
                return Color(nsColor: nsColor)
            }
            return Color(red: 0.5, green: 0.4, blue: 0.8)
        }
        set {
            withMutation(keyPath: \.gradientEndColor) {
                if let data = try? NSKeyedArchiver.archivedData(withRootObject: NSColor(newValue), requiringSecureCoding: true) {
                    ud.set(data, forKey: "gradientEndColor")
                }
            }
        }
    }
    var backgroundStyle: BackgroundStyle {
        get {
            access(keyPath: \.backgroundStyle)
            guard let raw = ud.string(forKey: "backgroundStyle"),
                  let val = BackgroundStyle(rawValue: raw) else { return .gradient }
            return val
        }
        set { withMutation(keyPath: \.backgroundStyle) { ud.set(newValue.rawValue, forKey: "backgroundStyle") } }
    }
    var blurBackground: Bool {
        get { access(keyPath: \.blurBackground); return ud.object(forKey: "blurBackground") as? Bool ?? true }
        set { withMutation(keyPath: \.blurBackground) { ud.set(newValue, forKey: "blurBackground") } }
    }
    var hideBreakScreenMessages: Bool {
        get { access(keyPath: \.hideBreakScreenMessages); return ud.object(forKey: "hideBreakScreenMessages") as? Bool ?? false }
        set { withMutation(keyPath: \.hideBreakScreenMessages) { ud.set(newValue, forKey: "hideBreakScreenMessages") } }
    }
    var alertPosition: AlertPosition {
        get {
            access(keyPath: \.alertPosition)
            guard let raw = ud.string(forKey: "alertPosition"),
                  let val = AlertPosition(rawValue: raw) else { return .topRight }
            return val
        }
        set { withMutation(keyPath: \.alertPosition) { ud.set(newValue.rawValue, forKey: "alertPosition") } }
    }

    // MARK: - Custom Messages
    var customMessagesEnabled: Bool {
        get { access(keyPath: \.customMessagesEnabled); return ud.object(forKey: "customMessagesEnabled") as? Bool ?? true }
        set { withMutation(keyPath: \.customMessagesEnabled) { ud.set(newValue, forKey: "customMessagesEnabled") } }
    }
    var customMessages: [String] {
        get {
            access(keyPath: \.customMessages)
            return ud.stringArray(forKey: "customMessages") ?? [
                "Relax those eyes",
                "Look at something distant",
                "Breathe, relax, and come back",
                "Take a moment to rest your eyes",
                "Drink some water and look away"
            ]
        }
        set { withMutation(keyPath: \.customMessages) { ud.set(newValue, forKey: "customMessages") } }
    }

    // MARK: - Wellness
    var blinkReminderEnabled: Bool {
        get { access(keyPath: \.blinkReminderEnabled); return ud.object(forKey: "blinkReminderEnabled") as? Bool ?? false }
        set { withMutation(keyPath: \.blinkReminderEnabled) { ud.set(newValue, forKey: "blinkReminderEnabled") } }
    }
    var blinkReminderInterval: TimeInterval {
        get { access(keyPath: \.blinkReminderInterval); return ud.double(forKey: "blinkReminderInterval").nonZero ?? 600 }
        set { withMutation(keyPath: \.blinkReminderInterval) { ud.set(newValue, forKey: "blinkReminderInterval") } }
    }
    var postureReminderEnabled: Bool {
        get { access(keyPath: \.postureReminderEnabled); return ud.object(forKey: "postureReminderEnabled") as? Bool ?? false }
        set { withMutation(keyPath: \.postureReminderEnabled) { ud.set(newValue, forKey: "postureReminderEnabled") } }
    }
    var postureReminderInterval: TimeInterval {
        get { access(keyPath: \.postureReminderInterval); return ud.double(forKey: "postureReminderInterval").nonZero ?? 1800 }
        set { withMutation(keyPath: \.postureReminderInterval) { ud.set(newValue, forKey: "postureReminderInterval") } }
    }
    var wellnessDimScreen: Bool {
        get { access(keyPath: \.wellnessDimScreen); return ud.object(forKey: "wellnessDimScreen") as? Bool ?? false }
        set { withMutation(keyPath: \.wellnessDimScreen) { ud.set(newValue, forKey: "wellnessDimScreen") } }
    }
    var wellnessShowDuringPauses: Bool {
        get { access(keyPath: \.wellnessShowDuringPauses); return ud.object(forKey: "wellnessShowDuringPauses") as? Bool ?? false }
        set { withMutation(keyPath: \.wellnessShowDuringPauses) { ud.set(newValue, forKey: "wellnessShowDuringPauses") } }
    }
    var wellnessResetAfterBreak: Bool {
        get { access(keyPath: \.wellnessResetAfterBreak); return ud.object(forKey: "wellnessResetAfterBreak") as? Bool ?? true }
        set { withMutation(keyPath: \.wellnessResetAfterBreak) { ud.set(newValue, forKey: "wellnessResetAfterBreak") } }
    }
    var blinkReminderSound: Bool {
        get { access(keyPath: \.blinkReminderSound); return ud.object(forKey: "blinkReminderSound") as? Bool ?? true }
        set { withMutation(keyPath: \.blinkReminderSound) { ud.set(newValue, forKey: "blinkReminderSound") } }
    }
    var postureReminderSound: Bool {
        get { access(keyPath: \.postureReminderSound); return ud.object(forKey: "postureReminderSound") as? Bool ?? true }
        set { withMutation(keyPath: \.postureReminderSound) { ud.set(newValue, forKey: "postureReminderSound") } }
    }

    // MARK: - General
    var launchAtLogin: Bool {
        get { access(keyPath: \.launchAtLogin); return ud.bool(forKey: "launchAtLogin") }
        set { withMutation(keyPath: \.launchAtLogin) { ud.set(newValue, forKey: "launchAtLogin") } }
    }
    var menuBarDisplayMode: MenuBarDisplayMode {
        get {
            access(keyPath: \.menuBarDisplayMode)
            guard let raw = ud.string(forKey: "menuBarDisplayMode"),
                  let val = MenuBarDisplayMode(rawValue: raw) else { return .timeUntilBreak }
            return val
        }
        set { withMutation(keyPath: \.menuBarDisplayMode) { ud.set(newValue.rawValue, forKey: "menuBarDisplayMode") } }
    }
    var timerStyle: TimerStyle {
        get {
            access(keyPath: \.timerStyle)
            guard let raw = ud.string(forKey: "timerStyle"),
                  let val = TimerStyle(rawValue: raw) else { return .countDown }
            return val
        }
        set { withMutation(keyPath: \.timerStyle) { ud.set(newValue.rawValue, forKey: "timerStyle") } }
    }

    @ObservationIgnored private let ud = UserDefaults.standard

    private init() {}
}

private extension Double {
    var nonZero: Double? { self == 0 ? nil : self }
}
