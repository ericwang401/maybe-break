import SwiftUI

enum SettingsTab: String, CaseIterable, Identifiable {
    case general = "General"
    case breakSchedule = "Break Schedule"
    case smartPause = "Smart Pause"
    case wellness = "Wellness Reminders"
    case appearance = "Appearance"
    case sounds = "Sound Effects"
    case about = "About"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .general: return "gearshape"
        case .breakSchedule: return "clock"
        case .smartPause: return "pause.circle"
        case .wellness: return "heart"
        case .appearance: return "paintbrush"
        case .sounds: return "speaker.wave.2"
        case .about: return "info.circle"
        }
    }

    var iconColor: Color {
        switch self {
        case .general: return .gray
        case .breakSchedule: return .blue
        case .smartPause: return .purple
        case .wellness: return .red
        case .appearance: return .pink
        case .sounds: return .orange
        case .about: return .blue
        }
    }

    var section: String {
        switch self {
        case .general: return ""
        case .breakSchedule, .smartPause, .wellness: return "Focus & Wellbeing"
        case .appearance, .sounds: return "Personalize"
        case .about: return "maybe-break"
        }
    }
}

struct SettingsView: View {
    @State private var selectedTab: SettingsTab = .general

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedTab) {
                sidebarItem(.general)

                Section("Focus & Wellbeing") {
                    sidebarItem(.breakSchedule)
                    sidebarItem(.smartPause)
                    sidebarItem(.wellness)
                }

                Section("Personalize") {
                    sidebarItem(.appearance)
                    sidebarItem(.sounds)
                }

                Section("maybe-break") {
                    sidebarItem(.about)
                }
            }
            .listStyle(.sidebar)
            .frame(minWidth: 200)
        } detail: {
            detailView
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(24)
        }
        .frame(width: 700, height: 500)
    }

    @ViewBuilder
    private func sidebarItem(_ tab: SettingsTab) -> some View {
        Label {
            Text(tab.rawValue)
        } icon: {
            Image(systemName: tab.icon)
                .foregroundStyle(tab.iconColor)
        }
        .tag(tab)
    }

    @ViewBuilder
    private var detailView: some View {
        switch selectedTab {
        case .general: GeneralSettingsView()
        case .breakSchedule: BreakScheduleSettingsView()
        case .smartPause: SmartPauseSettingsView()
        case .wellness: WellnessSettingsView()
        case .appearance: AppearanceSettingsView()
        case .sounds: SoundSettingsView()
        case .about: AboutView()
        }
    }
}
