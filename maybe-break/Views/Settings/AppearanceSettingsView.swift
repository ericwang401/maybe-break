import SwiftUI

struct AppearanceSettingsView: View {
    @State private var settings = AppSettings.shared
    @State private var newMessage = ""

    var body: some View {
        SettingsDetailPage(title: "Appearance") {
            // MARK: Background
            SettingsSection("Background") {
                SettingsPickerRow(
                    "Style",
                    selection: Binding(
                        get: { settings.backgroundStyle },
                        set: { settings.backgroundStyle = $0 }
                    ),
                    options: [
                        ("Gradient", .gradient),
                        ("Solid", .solid),
                    ]
                )

                SettingsDivider()

                SettingsRow("Colors") {
                    HStack(spacing: 12) {
                        ColorPicker("", selection: Binding(
                            get: { settings.gradientStartColor },
                            set: { settings.gradientStartColor = $0 }
                        ), supportsOpacity: false)
                        .labelsHidden()

                        if settings.backgroundStyle == .gradient {
                            ColorPicker("", selection: Binding(
                                get: { settings.gradientEndColor },
                                set: { settings.gradientEndColor = $0 }
                            ), supportsOpacity: false)
                            .labelsHidden()
                        }

                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                settings.backgroundStyle == .gradient
                                    ? LinearGradient(
                                        colors: [settings.gradientStartColor, settings.gradientEndColor],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    : LinearGradient(
                                        colors: [settings.gradientStartColor, settings.gradientStartColor],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                            )
                            .frame(width: 48, height: 28)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                }

                SettingsDivider()

                SettingsToggleRow(
                    "Blur Background",
                    subtitle: "Apply blur effect behind break screen",
                    isOn: Binding(
                        get: { settings.blurBackground },
                        set: { settings.blurBackground = $0 }
                    )
                )
            }

            // MARK: Custom Messages
            SettingsSection("Custom Messages") {
                SettingsToggleRow(
                    "Show Messages During Breaks",
                    isOn: Binding(
                        get: { settings.customMessagesEnabled },
                        set: { settings.customMessagesEnabled = $0 }
                    )
                )

                if settings.customMessagesEnabled {
                    SettingsDivider()

                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(settings.customMessages.enumerated()), id: \.offset) { index, message in
                            HStack {
                                Text(message)
                                    .font(.system(size: 13))
                                Spacer()
                                Button {
                                    var msgs = settings.customMessages
                                    msgs.remove(at: index)
                                    settings.customMessages = msgs
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundStyle(.red.opacity(0.7))
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.vertical, 2)
                            if index < settings.customMessages.count - 1 {
                                Divider()
                            }
                        }

                        HStack {
                            TextField("Add a message...", text: $newMessage)
                                .textFieldStyle(.roundedBorder)
                                .onSubmit { addMessage() }
                            Button(action: addMessage) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(.green)
                            }
                            .buttonStyle(.plain)
                            .disabled(newMessage.trimmingCharacters(in: .whitespaces).isEmpty)
                        }

                        Text("A random message is shown during each break")
                            .font(.system(size: 11))
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
            }

            // MARK: Alert Position
            SettingsSection("Alert Position") {
                SettingsCardPicker(
                    selection: Binding(
                        get: { settings.alertPosition },
                        set: { settings.alertPosition = $0 }
                    ),
                    options: [
                        ("Top Left", "rectangle.topthird.inset.filled", AlertPosition.topLeft),
                        ("Top Right", "rectangle.topthird.inset.filled", AlertPosition.topRight),
                        ("Bottom Left", "rectangle.bottomthird.inset.filled", AlertPosition.bottomLeft),
                        ("Bottom Right", "rectangle.bottomthird.inset.filled", AlertPosition.bottomRight),
                    ]
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
    }

    private func addMessage() {
        let trimmed = newMessage.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        var msgs = settings.customMessages
        msgs.append(trimmed)
        settings.customMessages = msgs
        newMessage = ""
    }
}
