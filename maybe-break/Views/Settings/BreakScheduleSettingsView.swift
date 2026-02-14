import SwiftUI

struct BreakScheduleSettingsView: View {
    @State private var settings = AppSettings.shared

    @State private var shortInterval: Double = AppSettings.shared.shortBreakInterval / 60
    @State private var shortDuration: Double = AppSettings.shared.shortBreakDuration
    @State private var longInterval: Double = AppSettings.shared.longBreakInterval / 60
    @State private var longDuration: Double = AppSettings.shared.longBreakDuration / 60
    @State private var longEnabled: Bool = AppSettings.shared.longBreaksEnabled
    @State private var headsUp: Double = AppSettings.shared.headsUpDuration

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Break Schedule")
                .font(.title2.bold())

            GroupBox("Short Breaks (20-20-20 Rule)") {
                VStack(alignment: .leading, spacing: 16) {
                    settingsRow("Break every") {
                        HStack {
                            Slider(value: $shortInterval, in: 1...60, step: 1)
                                .frame(width: 160)
                            Text("\(Int(shortInterval)) min")
                                .frame(width: 50, alignment: .trailing)
                                .monospacedDigit()
                        }
                    }
                    .onChange(of: shortInterval) { _, val in settings.shortBreakInterval = val * 60 }

                    settingsRow("Duration") {
                        HStack {
                            Slider(value: $shortDuration, in: 5...120, step: 5)
                                .frame(width: 160)
                            Text("\(Int(shortDuration)) sec")
                                .frame(width: 50, alignment: .trailing)
                                .monospacedDigit()
                        }
                    }
                    .onChange(of: shortDuration) { _, val in settings.shortBreakDuration = val }
                }
                .padding(4)
            }

            GroupBox("Long Breaks") {
                VStack(alignment: .leading, spacing: 16) {
                    Toggle("Enable long breaks", isOn: $longEnabled)
                        .onChange(of: longEnabled) { _, val in settings.longBreaksEnabled = val }

                    if longEnabled {
                        settingsRow("Break every") {
                            HStack {
                                Slider(value: $longInterval, in: 15...120, step: 5)
                                    .frame(width: 160)
                                Text("\(Int(longInterval)) min")
                                    .frame(width: 50, alignment: .trailing)
                                    .monospacedDigit()
                            }
                        }
                        .onChange(of: longInterval) { _, val in settings.longBreakInterval = val * 60 }

                        settingsRow("Duration") {
                            HStack {
                                Slider(value: $longDuration, in: 1...15, step: 1)
                                    .frame(width: 160)
                                Text("\(Int(longDuration)) min")
                                    .frame(width: 50, alignment: .trailing)
                                    .monospacedDigit()
                            }
                        }
                        .onChange(of: longDuration) { _, val in settings.longBreakDuration = val * 60 }
                    }
                }
                .padding(4)
            }

            GroupBox("Heads-Up Notification") {
                settingsRow("Warn before break") {
                    HStack {
                        Slider(value: $headsUp, in: 5...60, step: 5)
                            .frame(width: 160)
                        Text("\(Int(headsUp)) sec")
                            .frame(width: 50, alignment: .trailing)
                            .monospacedDigit()
                    }
                }
                .onChange(of: headsUp) { _, val in settings.headsUpDuration = val }
                .padding(4)
            }

            Spacer()
        }
    }

    @ViewBuilder
    private func settingsRow<Content: View>(_ label: String, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Text(label)
                .frame(width: 130, alignment: .leading)
            content()
        }
    }
}
