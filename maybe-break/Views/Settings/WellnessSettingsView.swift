import SwiftUI

struct WellnessSettingsView: View {
    @State private var settings = AppSettings.shared

    @State private var blinkEnabled = AppSettings.shared.blinkReminderEnabled
    @State private var blinkInterval = AppSettings.shared.blinkReminderInterval / 60
    @State private var postureEnabled = AppSettings.shared.postureReminderEnabled
    @State private var postureInterval = AppSettings.shared.postureReminderInterval / 60

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Wellness Reminders")
                .font(.title2.bold())

            Text("Gentle, non-intrusive reminders to keep you healthy.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            GroupBox("Blink Reminder") {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Enable blink reminders", isOn: $blinkEnabled)
                        .onChange(of: blinkEnabled) { _, val in
                            settings.blinkReminderEnabled = val
                            WellnessManager.shared.restart()
                        }

                    if blinkEnabled {
                        HStack {
                            Text("Remind every")
                            Spacer()
                            Picker("", selection: $blinkInterval) {
                                Text("5 minutes").tag(5.0)
                                Text("10 minutes").tag(10.0)
                                Text("15 minutes").tag(15.0)
                                Text("20 minutes").tag(20.0)
                            }
                            .frame(width: 150)
                            .onChange(of: blinkInterval) { _, val in
                                settings.blinkReminderInterval = val * 60
                                WellnessManager.shared.restart()
                            }
                        }
                    }
                }
                .padding(4)
            }

            GroupBox("Posture Reminder") {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Enable posture reminders", isOn: $postureEnabled)
                        .onChange(of: postureEnabled) { _, val in
                            settings.postureReminderEnabled = val
                            WellnessManager.shared.restart()
                        }

                    if postureEnabled {
                        HStack {
                            Text("Remind every")
                            Spacer()
                            Picker("", selection: $postureInterval) {
                                Text("15 minutes").tag(15.0)
                                Text("30 minutes").tag(30.0)
                                Text("45 minutes").tag(45.0)
                                Text("60 minutes").tag(60.0)
                            }
                            .frame(width: 150)
                            .onChange(of: postureInterval) { _, val in
                                settings.postureReminderInterval = val * 60
                                WellnessManager.shared.restart()
                            }
                        }
                    }
                }
                .padding(4)
            }

            Spacer()
        }
    }
}
