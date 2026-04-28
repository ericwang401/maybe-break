import SwiftUI

struct SmartPauseSettingsView: View {
    @State private var settings = AppSettings.shared

    var body: some View {
        SettingsDetailPage(title: "Smart Pause") {
            SettingsSection("Automatically Pause During") {
                SettingsToggleRow(
                    "Fullscreen Apps",
                    subtitle: "Pauses breaks when any app is fullscreen",
                    icon: "display",
                    iconColor: .blue,
                    isOn: Binding(
                        get: { settings.smartPauseFullscreenEnabled },
                        set: { settings.smartPauseFullscreenEnabled = $0 }
                    )
                )

                SettingsDivider()

                SettingsToggleRow(
                    "When You're Away",
                    subtitle: "Pauses timers when no input is detected",
                    icon: "person.fill.questionmark",
                    iconColor: .orange,
                    isOn: Binding(
                        get: { settings.smartPauseIdleEnabled },
                        set: { settings.smartPauseIdleEnabled = $0 }
                    )
                )

                if settings.smartPauseIdleEnabled {
                    SettingsDivider()

                    SettingsPickerRow(
                        "Idle Threshold",
                        selection: Binding(
                            get: { settings.smartPauseIdleThreshold },
                            set: { settings.smartPauseIdleThreshold = $0 }
                        ),
                        options: [
                            ("2 minutes", 120.0),
                            ("5 minutes", 300.0),
                            ("10 minutes", 600.0),
                            ("15 minutes", 900.0),
                        ]
                    )
                }
            }

            SettingsSection("Cooldown") {
                SettingsPickerRow(
                    "After Smart Pause Ends",
                    subtitle: "Grace period before next break",
                    selection: Binding(
                        get: { settings.smartPauseCooldown },
                        set: { settings.smartPauseCooldown = $0 }
                    ),
                    options: [
                        ("None", 0.0),
                        ("1 minute", 60.0),
                        ("2 minutes", 120.0),
                        ("5 minutes", 300.0),
                    ]
                )
            }
        }
    }
}
