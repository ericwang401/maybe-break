import SwiftUI

struct BreakScheduleSettingsView: View {
    @State private var settings = AppSettings.shared

    var body: some View {
        SettingsDetailPage(title: "Break Schedule") {
            // MARK: Short Breaks
            SettingsSection("Short Breaks") {
                SettingsStepperRow(
                    "Break Every",
                    subtitle: "20-20-20 rule recommends 20 min",
                    unit: "sec",
                    range: 5...3600,
                    step: 5,
                    value: Binding(
                        get: { settings.shortBreakInterval },
                        set: { settings.shortBreakInterval = $0 }
                    )
                )

                SettingsDivider()

                SettingsStepperRow(
                    "Duration",
                    unit: "sec",
                    range: 5...300,
                    step: 5,
                    value: Binding(
                        get: { settings.shortBreakDuration },
                        set: { settings.shortBreakDuration = $0 }
                    )
                )

                SettingsDivider()

                SettingsToggleRow(
                    "Skip If Typing",
                    subtitle: "Delay break when keyboard is active",
                    isOn: Binding(
                        get: { settings.skipBreakWhileTyping },
                        set: { settings.skipBreakWhileTyping = $0 }
                    )
                )
            }

            // MARK: Long Breaks
            SettingsSection("Long Breaks") {
                SettingsToggleRow(
                    "Enable Long Breaks",
                    subtitle: "Longer rest periods at regular intervals",
                    isOn: Binding(
                        get: { settings.longBreaksEnabled },
                        set: { settings.longBreaksEnabled = $0 }
                    )
                )

                if settings.longBreaksEnabled {
                    SettingsDivider()

                    SettingsStepperRow(
                        "Break Every",
                        unit: "sec",
                        range: 60...14400,
                        step: 60,
                        value: Binding(
                            get: { settings.longBreakInterval },
                            set: { settings.longBreakInterval = $0 }
                        )
                    )

                    SettingsDivider()

                    SettingsStepperRow(
                        "Duration",
                        unit: "sec",
                        range: 30...1800,
                        step: 30,
                        value: Binding(
                            get: { settings.longBreakDuration },
                            set: { settings.longBreakDuration = $0 }
                        )
                    )
                }
            }

            // MARK: Office Hours
            SettingsSection("Office Hours") {
                SettingsToggleRow(
                    "Enable Office Hours",
                    subtitle: "Only remind during work hours",
                    isOn: Binding(
                        get: { settings.officeHoursEnabled },
                        set: { settings.officeHoursEnabled = $0 }
                    )
                )

                if settings.officeHoursEnabled {
                    SettingsDivider()

                    SettingsRow("Start Time") {
                        DatePicker("", selection: Binding(
                            get: { settings.officeHoursStart },
                            set: { settings.officeHoursStart = $0 }
                        ), displayedComponents: .hourAndMinute)
                        .labelsHidden()
                    }

                    SettingsDivider()

                    SettingsRow("End Time") {
                        DatePicker("", selection: Binding(
                            get: { settings.officeHoursEnd },
                            set: { settings.officeHoursEnd = $0 }
                        ), displayedComponents: .hourAndMinute)
                        .labelsHidden()
                    }
                }
            }

            // MARK: Break Skip Difficulty
            SettingsSection("Break Skip Difficulty") {
                SettingsRow("How easy to skip breaks") {
                    EmptyView()
                }

                SettingsCardPicker(
                    selection: Binding(
                        get: { settings.breakSkipDifficulty },
                        set: { settings.breakSkipDifficulty = $0 }
                    ),
                    options: [
                        ("Easy", "hand.tap", BreakSkipDifficulty.easy),
                        ("Medium", "lock.open", BreakSkipDifficulty.medium),
                        ("Hard", "lock.fill", BreakSkipDifficulty.hard),
                    ]
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }

            // MARK: Break Reminder
            SettingsSection("Break Reminder") {
                SettingsToggleRow(
                    "Show Reminder Before Break",
                    subtitle: "Heads-up notification before break starts",
                    isOn: Binding(
                        get: { settings.breakReminderEnabled },
                        set: { settings.breakReminderEnabled = $0 }
                    )
                )

                if settings.breakReminderEnabled {
                    SettingsDivider()

                    SettingsPickerRow(
                        "Lead Time",
                        selection: Binding(
                            get: { settings.breakReminderLeadTime },
                            set: { settings.breakReminderLeadTime = $0 }
                        ),
                        options: [
                            ("10 sec", 10.0),
                            ("15 sec", 15.0),
                            ("30 sec", 30.0),
                            ("60 sec", 60.0),
                        ]
                    )

                    SettingsDivider()

                    SettingsPickerRow(
                        "Visible Duration",
                        selection: Binding(
                            get: { settings.breakReminderVisibleDuration },
                            set: { settings.breakReminderVisibleDuration = $0 }
                        ),
                        options: [
                            ("5 sec", 5.0),
                            ("10 sec", 10.0),
                            ("15 sec", 15.0),
                            ("Until Break", 0.0),
                        ]
                    )

                    SettingsDivider()

                    SettingsToggleRow(
                        "Play Sound",
                        isOn: Binding(
                            get: { settings.breakReminderPlaySound },
                            set: { settings.breakReminderPlaySound = $0 }
                        )
                    )
                }
            }

            // MARK: Countdown Before Break
            SettingsSection("Countdown Before Break") {
                SettingsToggleRow(
                    "Show Countdown",
                    subtitle: "Visual countdown before break begins",
                    isOn: Binding(
                        get: { settings.countdownBeforeBreakEnabled },
                        set: { settings.countdownBeforeBreakEnabled = $0 }
                    )
                )

                if settings.countdownBeforeBreakEnabled {
                    SettingsDivider()

                    SettingsPickerRow(
                        "Duration",
                        selection: Binding(
                            get: { settings.countdownDuration },
                            set: { settings.countdownDuration = $0 }
                        ),
                        options: [
                            ("3 sec", 3.0),
                            ("5 sec", 5.0),
                            ("10 sec", 10.0),
                        ]
                    )
                }
            }

            // MARK: Overtime Nudge
            SettingsSection("Overtime Nudge") {
                SettingsToggleRow(
                    "Nudge When Overdue",
                    subtitle: "Gentle reminder if you skip a break",
                    isOn: Binding(
                        get: { settings.overtimeNudgeEnabled },
                        set: { settings.overtimeNudgeEnabled = $0 }
                    )
                )

                if settings.overtimeNudgeEnabled {
                    SettingsDivider()

                    SettingsToggleRow(
                        "Nudge When Paused",
                        isOn: Binding(
                            get: { settings.overtimeNudgeWhenPaused },
                            set: { settings.overtimeNudgeWhenPaused = $0 }
                        )
                    )
                }
            }

            // MARK: More Options
            SettingsSection("More Options") {
                SettingsToggleRow(
                    "Allow End Break Early",
                    subtitle: "Show a button to end breaks before time",
                    isOn: Binding(
                        get: { settings.allowEndBreakEarly },
                        set: { settings.allowEndBreakEarly = $0 }
                    )
                )

                SettingsDivider()

                SettingsToggleRow(
                    "Lock Mac on Break",
                    subtitle: "Lock the screen when a break starts",
                    isOn: Binding(
                        get: { settings.lockMacOnBreak },
                        set: { settings.lockMacOnBreak = $0 }
                    )
                )
            }
        }
    }
}
