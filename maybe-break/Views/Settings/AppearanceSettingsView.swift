import SwiftUI

struct AppearanceSettingsView: View {
    @State private var settings = AppSettings.shared

    @State private var startColor = AppSettings.shared.gradientStartColor
    @State private var endColor = AppSettings.shared.gradientEndColor
    @State private var messagesEnabled = AppSettings.shared.customMessagesEnabled
    @State private var messages = AppSettings.shared.customMessages
    @State private var newMessage = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Appearance")
                .font(.title2.bold())

            GroupBox("Break Background") {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Start color")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                            ColorPicker("", selection: $startColor, supportsOpacity: false)
                                .labelsHidden()
                                .onChange(of: startColor) { _, val in settings.gradientStartColor = val }
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            Text("End color")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                            ColorPicker("", selection: $endColor, supportsOpacity: false)
                                .labelsHidden()
                                .onChange(of: endColor) { _, val in settings.gradientEndColor = val }
                        }
                        Spacer()
                        // Preview
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [startColor, endColor],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 60)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
                .padding(4)
            }

            GroupBox("Custom Messages") {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Enable custom messages for breaks", isOn: $messagesEnabled)
                        .onChange(of: messagesEnabled) { _, val in settings.customMessagesEnabled = val }

                    if messagesEnabled {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(Array(messages.enumerated()), id: \.offset) { index, message in
                                HStack {
                                    Text(message)
                                        .font(.system(size: 13))
                                    Spacer()
                                    Button {
                                        messages.remove(at: index)
                                        settings.customMessages = messages
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundStyle(.red.opacity(0.7))
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                if index < messages.count - 1 {
                                    Divider()
                                }
                            }
                        }
                        .padding(6)
                        .background(RoundedRectangle(cornerRadius: 6).fill(.background))

                        HStack {
                            TextField("Add a message...", text: $newMessage)
                                .textFieldStyle(.roundedBorder)
                                .onSubmit { addMessage() }
                            Button(action: addMessage) {
                                Image(systemName: "plus.circle.fill")
                            }
                            .disabled(newMessage.trimmingCharacters(in: .whitespaces).isEmpty)
                        }

                        Text("A random message will be shown during each break")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(4)
            }

            Spacer()
        }
    }

    private func addMessage() {
        let trimmed = newMessage.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        messages.append(trimmed)
        settings.customMessages = messages
        newMessage = ""
    }
}
