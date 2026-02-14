import SwiftUI

struct SmartPauseSettingsView: View {
    @State private var settings = AppSettings.shared

    @State private var idleEnabled = AppSettings.shared.smartPauseIdleEnabled
    @State private var idleThreshold = AppSettings.shared.smartPauseIdleThreshold / 60
    @State private var fullscreenEnabled = AppSettings.shared.smartPauseFullscreenEnabled
    @State private var cooldown = AppSettings.shared.smartPauseCooldown / 60

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Smart Pause")
                .font(.title2.bold())

            Text("Automatically pause break reminders during certain activities.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            GroupBox("Automatically pause during") {
                VStack(alignment: .leading, spacing: 12) {
                    smartPauseRow(
                        icon: "display",
                        title: "Fullscreen apps",
                        description: "Pauses breaks when any app is fullscreen",
                        isOn: $fullscreenEnabled
                    )
                    .onChange(of: fullscreenEnabled) { _, val in settings.smartPauseFullscreenEnabled = val }

                    Divider()

                    smartPauseRow(
                        icon: "person.fill.questionmark",
                        title: "When you're away",
                        description: "Pauses timers when no input is detected",
                        isOn: $idleEnabled
                    )
                    .onChange(of: idleEnabled) { _, val in settings.smartPauseIdleEnabled = val }

                    if idleEnabled {
                        HStack {
                            Text("Idle threshold")
                                .padding(.leading, 36)
                            Spacer()
                            Picker("", selection: $idleThreshold) {
                                Text("2 minutes").tag(2.0)
                                Text("5 minutes").tag(5.0)
                                Text("10 minutes").tag(10.0)
                                Text("15 minutes").tag(15.0)
                            }
                            .frame(width: 150)
                            .onChange(of: idleThreshold) { _, val in settings.smartPauseIdleThreshold = val * 60 }
                        }
                    }
                }
                .padding(4)
            }

            GroupBox {
                HStack {
                    Text("Cooldown after smart pause ends")
                    Spacer()
                    Picker("", selection: $cooldown) {
                        Text("None").tag(0.0)
                        Text("1 minute").tag(1.0)
                        Text("2 minutes").tag(2.0)
                        Text("5 minutes").tag(5.0)
                    }
                    .frame(width: 150)
                    .onChange(of: cooldown) { _, val in settings.smartPauseCooldown = val * 60 }
                }
                .padding(4)
            }

            Spacer()
        }
    }

    @ViewBuilder
    private func smartPauseRow(icon: String, title: String, description: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                Text(description)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
        }
    }
}
