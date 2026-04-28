import SwiftUI

// MARK: - Settings Detail Page

struct SettingsDetailPage<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            HStack {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(.bar)

            Divider()

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    content()
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
        }
    }
}

// MARK: - Settings Section

struct SettingsSection<Content: View>: View {
    let header: String?
    @ViewBuilder let content: () -> Content

    init(_ header: String? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.header = header
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let header {
                Text(header)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .padding(.leading, 4)
            }

            VStack(spacing: 0) {
                content()
            }
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
            )
        }
    }
}

// MARK: - Settings Row

struct SettingsRow<Control: View>: View {
    let label: String
    let subtitle: String?
    let icon: String?
    let iconColor: Color?
    @ViewBuilder let control: () -> Control

    init(
        _ label: String,
        subtitle: String? = nil,
        icon: String? = nil,
        iconColor: Color? = nil,
        @ViewBuilder control: @escaping () -> Control
    ) {
        self.label = label
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self.control = control
    }

    var body: some View {
        HStack(spacing: 12) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(iconColor ?? .secondary)
                    .frame(width: 20)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 13))
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            control()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

// MARK: - Settings Toggle Row

struct SettingsToggleRow: View {
    let label: String
    let subtitle: String?
    let icon: String?
    let iconColor: Color?
    @Binding var isOn: Bool

    init(
        _ label: String,
        subtitle: String? = nil,
        icon: String? = nil,
        iconColor: Color? = nil,
        isOn: Binding<Bool>
    ) {
        self.label = label
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self._isOn = isOn
    }

    var body: some View {
        SettingsRow(label, subtitle: subtitle, icon: icon, iconColor: iconColor) {
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(.switch)
        }
    }
}

// MARK: - Settings Picker Row

struct SettingsPickerRow<T: Hashable>: View {
    let label: String
    let subtitle: String?
    @Binding var selection: T
    let options: [(label: String, value: T)]

    init(
        _ label: String,
        subtitle: String? = nil,
        selection: Binding<T>,
        options: [(String, T)]
    ) {
        self.label = label
        self.subtitle = subtitle
        self._selection = selection
        self.options = options.map { (label: $0.0, value: $0.1) }
    }

    var body: some View {
        SettingsRow(label, subtitle: subtitle) {
            Picker("", selection: $selection) {
                ForEach(options, id: \.value) { option in
                    Text(option.label).tag(option.value)
                }
            }
            .labelsHidden()
            .frame(width: 160)
        }
    }
}

// MARK: - Settings Stepper Row

struct SettingsStepperRow: View {
    let label: String
    let subtitle: String?
    let unit: String
    let range: ClosedRange<Double>
    let step: Double
    @Binding var value: Double

    init(
        _ label: String,
        subtitle: String? = nil,
        unit: String,
        range: ClosedRange<Double>,
        step: Double = 1,
        value: Binding<Double>
    ) {
        self.label = label
        self.subtitle = subtitle
        self.unit = unit
        self.range = range
        self.step = step
        self._value = value
    }

    var body: some View {
        SettingsRow(label, subtitle: subtitle) {
            HStack(spacing: 6) {
                TextField(
                    "",
                    value: $value,
                    format: .number
                )
                .textFieldStyle(.roundedBorder)
                .frame(width: 60)
                .multilineTextAlignment(.trailing)
                .onSubmit { value = min(max(value, range.lowerBound), range.upperBound) }

                Text(unit)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)

                Stepper("", value: $value, in: range, step: step)
                    .labelsHidden()
            }
        }
    }
}

// MARK: - Settings Divider

struct SettingsDivider: View {
    var body: some View {
        Divider()
            .padding(.leading, 16)
    }
}

// MARK: - Settings Card Picker

struct SettingsCardPicker<T: Hashable>: View {
    let options: [(label: String, icon: String, value: T)]
    @Binding var selection: T

    init(selection: Binding<T>, options: [(String, String, T)]) {
        self._selection = selection
        self.options = options.map { (label: $0.0, icon: $0.1, value: $0.2) }
    }

    var body: some View {
        HStack(spacing: 12) {
            ForEach(options, id: \.value) { option in
                Button {
                    selection = option.value
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: option.icon)
                            .font(.system(size: 20))
                        Text(option.label)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(selection == option.value ? Color.accentColor.opacity(0.15) : Color(nsColor: .controlBackgroundColor))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(selection == option.value ? Color.accentColor : Color(nsColor: .separatorColor), lineWidth: selection == option.value ? 2 : 0.5)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Sidebar Icon Style

struct SidebarIcon: View {
    let systemName: String
    let color: Color

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.white)
            .frame(width: 26, height: 26)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(color)
            )
    }
}
