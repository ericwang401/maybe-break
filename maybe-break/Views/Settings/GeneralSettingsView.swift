import SwiftUI
import ServiceManagement

struct GeneralSettingsView: View {
    @State private var settings = AppSettings.shared

    var body: some View {
        SettingsDetailPage(title: "General") {
            SettingsSection("Startup") {
                SettingsToggleRow(
                    "Launch at Login",
                    subtitle: "Automatically start when you log in",
                    isOn: Binding(
                        get: { settings.launchAtLogin },
                        set: { newValue in
                            settings.launchAtLogin = newValue
                            updateLoginItem(enabled: newValue)
                        }
                    )
                )
            }

            SettingsSection("Menu Bar") {
                SettingsPickerRow(
                    "Display Mode",
                    selection: Binding(
                        get: { settings.menuBarDisplayMode },
                        set: { settings.menuBarDisplayMode = $0 }
                    ),
                    options: [
                        ("Time Until Break", .timeUntilBreak),
                        ("Icon Only", .icon),
                        ("Icon & Time", .iconAndTime),
                    ]
                )

                SettingsDivider()

                SettingsPickerRow(
                    "Timer Style",
                    selection: Binding(
                        get: { settings.timerStyle },
                        set: { settings.timerStyle = $0 }
                    ),
                    options: [
                        ("Count Down", .countDown),
                        ("Count Up", .countUp),
                        ("Progress Bar", .progress),
                    ]
                )
            }
        }
    }

    private func updateLoginItem(enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            // Silently fail — user may need to grant permission
        }
    }
}
