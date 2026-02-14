import UserNotifications

final class WellnessManager {
    static let shared = WellnessManager()

    private var blinkTimer: Timer?
    private var postureTimer: Timer?
    private var settings: AppSettings { AppSettings.shared }

    private init() {}

    func start() {
        startBlinkReminder()
        startPostureReminder()
    }

    func stop() {
        blinkTimer?.invalidate()
        postureTimer?.invalidate()
    }

    func restart() {
        stop()
        start()
    }

    private func startBlinkReminder() {
        blinkTimer?.invalidate()
        guard settings.blinkReminderEnabled else { return }
        blinkTimer = Timer.scheduledTimer(withTimeInterval: settings.blinkReminderInterval, repeats: true) { [weak self] _ in
            self?.sendNotification(title: "Blink Reminder", body: "Remember to blink! Keep your eyes hydrated.")
        }
    }

    private func startPostureReminder() {
        postureTimer?.invalidate()
        guard settings.postureReminderEnabled else { return }
        postureTimer = Timer.scheduledTimer(withTimeInterval: settings.postureReminderInterval, repeats: true) { [weak self] _ in
            self?.sendNotification(title: "Posture Check", body: "Sit up straight and relax your shoulders.")
        }
    }

    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }
}
