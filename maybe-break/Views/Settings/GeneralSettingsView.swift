import SwiftUI
import ServiceManagement

struct GeneralSettingsView: View {
    @State private var settings = AppSettings.shared
    @State private var launchAtLogin = AppSettings.shared.launchAtLogin

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("General")
                .font(.title2.bold())

            GroupBox {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Launch at login", isOn: $launchAtLogin)
                        .onChange(of: launchAtLogin) { _, newValue in
                            settings.launchAtLogin = newValue
                            updateLoginItem(enabled: newValue)
                        }
                }
                .padding(4)
            }

            Spacer()
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
