import SwiftUI

enum SettingsTab: String, CaseIterable, Identifiable {
    case general = "General"
    case breakSchedule = "Break Schedule"
    case smartPause = "Smart Pause"
    case wellness = "Wellness Reminders"
    case appearance = "Appearance"
    case sounds = "Sound Effects"
    case keyboardShortcuts = "Keyboard Shortcuts"
    case about = "About"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .general: return "gearshape.fill"
        case .breakSchedule: return "clock.fill"
        case .smartPause: return "pause.circle.fill"
        case .wellness: return "heart.fill"
        case .appearance: return "paintbrush.fill"
        case .sounds: return "speaker.wave.2.fill"
        case .keyboardShortcuts: return "command"
        case .about: return "info.circle.fill"
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
        case .keyboardShortcuts: return .teal
        case .about: return .blue
        }
    }
}

struct SettingsView: View {
    @State private var selectedTab: SettingsTab = .general

    private let sidebarInset = EdgeInsets(top: 2, leading: 0, bottom: 2, trailing: 6)

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
                    sidebarItem(.keyboardShortcuts)
                    sidebarItem(.about)
                }
            }
            .listStyle(.sidebar)
            .frame(minWidth: 200)
            .toolbar(removing: .sidebarToggle)
        } detail: {
            detailView
                .ignoresSafeArea(.all, edges: .top)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationSplitViewStyle(.prominentDetail)
        .toolbar(.hidden)
        .frame(width: 720, height: 560)
    }

    @ViewBuilder
    private func sidebarItem(_ tab: SettingsTab) -> some View {
        HStack(spacing: 10) {
            SidebarIcon(systemName: tab.icon, color: tab.iconColor)
            Text(tab.rawValue)
                .font(.system(size: 13))
        }
        .tag(tab)
        .listRowInsets(sidebarInset)
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
        case .keyboardShortcuts: KeyboardShortcutsSettingsView()
        case .about: AboutView()
        }
    }
}
