import SwiftUI

struct SoundSettingsView: View {
    @State private var settings = AppSettings.shared

    var body: some View {
        SettingsDetailPage(title: "Sound Effects") {
            // MARK: Break Sounds
            SettingsSection("Break Sounds") {
                SettingsPickerRow(
                    "Sound Pack",
                    selection: Binding(
                        get: { settings.soundPairName },
                        set: { settings.soundPairName = $0 }
                    ),
                    options: [
                        ("Default", "Default"),
                        ("Gentle", "Gentle"),
                        ("Chime", "Chime"),
                    ]
                )

                SettingsDivider()

                SettingsRow("Break Start") {
                    HStack(spacing: 8) {
                        Toggle("", isOn: Binding(
                            get: { settings.playSoundOnBreakStart },
                            set: { settings.playSoundOnBreakStart = $0 }
                        ))
                        .labelsHidden()
                        .toggleStyle(.switch)

                        Button {
                            SoundManager.shared.playBreakStartSound()
                        } label: {
                            Image(systemName: "play.circle")
                                .font(.system(size: 16))
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }

                SettingsDivider()

                SettingsRow("Break End") {
                    HStack(spacing: 8) {
                        Toggle("", isOn: Binding(
                            get: { settings.playSoundOnBreakEnd },
                            set: { settings.playSoundOnBreakEnd = $0 }
                        ))
                        .labelsHidden()
                        .toggleStyle(.switch)

                        Button {
                            SoundManager.shared.playBreakEndSound()
                        } label: {
                            Image(systemName: "play.circle")
                                .font(.system(size: 16))
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }

                SettingsDivider()

                SettingsRow("Volume") {
                    HStack(spacing: 8) {
                        Image(systemName: "speaker.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(.tertiary)
                        Slider(
                            value: Binding(
                                get: { settings.soundVolume },
                                set: { settings.soundVolume = $0 }
                            ),
                            in: 0...1,
                            step: 0.1
                        )
                        .frame(width: 120)
                        Image(systemName: "speaker.wave.3.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            // MARK: Wellness Sounds
            SettingsSection("Wellness Sounds") {
                SettingsRow("Volume") {
                    HStack(spacing: 8) {
                        Image(systemName: "speaker.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(.tertiary)
                        Slider(
                            value: Binding(
                                get: { settings.wellnessSoundVolume },
                                set: { settings.wellnessSoundVolume = $0 }
                            ),
                            in: 0...1,
                            step: 0.1
                        )
                        .frame(width: 120)
                        Image(systemName: "speaker.wave.3.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            // MARK: Alerts & Nudges
            SettingsSection("Alerts & Nudges") {
                SettingsToggleRow(
                    "Smart Pause Sound",
                    subtitle: "Play sound when smart pause activates",
                    isOn: Binding(
                        get: { settings.smartPauseSoundEnabled },
                        set: { settings.smartPauseSoundEnabled = $0 }
                    )
                )

                SettingsDivider()

                SettingsToggleRow(
                    "Overtime Nudge Sound",
                    subtitle: "Play sound for overtime nudges",
                    isOn: Binding(
                        get: { settings.overtimeNudgeSoundEnabled },
                        set: { settings.overtimeNudgeSoundEnabled = $0 }
                    )
                )

                SettingsDivider()

                SettingsRow("Alert Volume") {
                    HStack(spacing: 8) {
                        Image(systemName: "speaker.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(.tertiary)
                        Slider(
                            value: Binding(
                                get: { settings.alertSoundVolume },
                                set: { settings.alertSoundVolume = $0 }
                            ),
                            in: 0...1,
                            step: 0.1
                        )
                        .frame(width: 120)
                        Image(systemName: "speaker.wave.3.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
    }
}
