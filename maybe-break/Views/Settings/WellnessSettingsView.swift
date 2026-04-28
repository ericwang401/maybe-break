import SwiftUI

struct WellnessSettingsView: View {
    @State private var settings = AppSettings.shared

    var body: some View {
        SettingsDetailPage(title: "Wellness Reminders") {
            HStack(alignment: .top, spacing: 16) {
                // Blink Reminder Card
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "eye")
                            .font(.system(size: 20))
                            .foregroundStyle(.blue)
                        Text("Blink")
                            .font(.system(size: 15, weight: .semibold))
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { settings.blinkReminderEnabled },
                            set: {
                                settings.blinkReminderEnabled = $0
                                WellnessManager.shared.restart()
                            }
                        ))
                        .labelsHidden()
                        .toggleStyle(.switch)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                    if settings.blinkReminderEnabled {
                        Divider().padding(.leading, 16)

                        SettingsPickerRow(
                            "Interval",
                            selection: Binding(
                                get: { settings.blinkReminderInterval },
                                set: {
                                    settings.blinkReminderInterval = $0
                                    WellnessManager.shared.restart()
                                }
                            ),
                            options: [
                                ("5 min", 300.0),
                                ("10 min", 600.0),
                                ("15 min", 900.0),
                                ("20 min", 1200.0),
                            ]
                        )

                        Divider().padding(.leading, 16)

                        SettingsToggleRow(
                            "Play Sound",
                            isOn: Binding(
                                get: { settings.blinkReminderSound },
                                set: { settings.blinkReminderSound = $0 }
                            )
                        )
                    }
                }
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
                )

                // Posture Reminder Card
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "figure.stand")
                            .font(.system(size: 20))
                            .foregroundStyle(.green)
                        Text("Posture")
                            .font(.system(size: 15, weight: .semibold))
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { settings.postureReminderEnabled },
                            set: {
                                settings.postureReminderEnabled = $0
                                WellnessManager.shared.restart()
                            }
                        ))
                        .labelsHidden()
                        .toggleStyle(.switch)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                    if settings.postureReminderEnabled {
                        Divider().padding(.leading, 16)

                        SettingsPickerRow(
                            "Interval",
                            selection: Binding(
                                get: { settings.postureReminderInterval },
                                set: {
                                    settings.postureReminderInterval = $0
                                    WellnessManager.shared.restart()
                                }
                            ),
                            options: [
                                ("15 min", 900.0),
                                ("30 min", 1800.0),
                                ("45 min", 2700.0),
                                ("60 min", 3600.0),
                            ]
                        )

                        Divider().padding(.leading, 16)

                        SettingsToggleRow(
                            "Play Sound",
                            isOn: Binding(
                                get: { settings.postureReminderSound },
                                set: { settings.postureReminderSound = $0 }
                            )
                        )
                    }
                }
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
                )
            }

            SettingsSection("Common Settings") {
                SettingsToggleRow(
                    "Dim Screen",
                    subtitle: "Slightly dim screen during reminders",
                    isOn: Binding(
                        get: { settings.wellnessDimScreen },
                        set: { settings.wellnessDimScreen = $0 }
                    )
                )

                SettingsDivider()

                SettingsToggleRow(
                    "Show During Pauses",
                    subtitle: "Continue wellness reminders while paused",
                    isOn: Binding(
                        get: { settings.wellnessShowDuringPauses },
                        set: { settings.wellnessShowDuringPauses = $0 }
                    )
                )

                SettingsDivider()

                SettingsToggleRow(
                    "Reset After Break",
                    subtitle: "Reset wellness timers after a break",
                    isOn: Binding(
                        get: { settings.wellnessResetAfterBreak },
                        set: { settings.wellnessResetAfterBreak = $0 }
                    )
                )
            }
        }
    }
}
