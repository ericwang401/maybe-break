import AppKit
import SwiftUI

// MARK: - Heads-Up Alert Window

final class PreBreakTooltipWindow {
    private var window: NSPanel?
    private var dismissTimer: Timer?

    func show() {
        close()

        let settings = AppSettings.shared
        let autoDismissDuration = settings.breakReminderVisibleDuration
        let breakManager = BreakManager.shared

        let signal = HeadsUpDismissSignal()

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 240),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.level = .floating
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.ignoresMouseEvents = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        let hostView = NSHostingView(rootView:
            HeadsUpAlertView(
                breakManager: breakManager,
                autoDismissDuration: autoDismissDuration,
                dismissSignal: signal,
                onStartNow: { [weak self] in
                    self?.close()
                    BreakManager.shared.startBreakNow()
                },
                onSnooze: { [weak self] in
                    self?.close()
                    BreakManager.shared.postpone(by: 300)
                },
                onDismiss: { [weak self] in
                    self?.close()
                }
            )
        )
        panel.contentView = hostView

        let fittingSize = hostView.fittingSize
        panel.setContentSize(fittingSize)

        // Position top-right of main screen
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let x = screenFrame.maxX - fittingSize.width - 16
            let y = screenFrame.maxY - fittingSize.height - 16
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }

        self.window = panel
        panel.orderFront(nil)

        // Auto-dismiss timer
        if autoDismissDuration > 0 {
            dismissTimer = Timer.scheduledTimer(withTimeInterval: autoDismissDuration, repeats: false) { [weak self] _ in
                self?.close()
            }
        }
    }

    func close() {
        dismissTimer?.invalidate()
        dismissTimer = nil

        guard let window else { return }

        // Fade out
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            window.animator().alphaValue = 0
        }, completionHandler: { [weak self] in
            self?.window?.orderOut(nil)
            self?.window = nil
        })
    }
}

// MARK: - Dismiss Signal

@Observable
final class HeadsUpDismissSignal {
    var isDismissing = false
}

// MARK: - Heads-Up Alert View

struct HeadsUpAlertView: View {
    let breakManager: BreakManager
    let autoDismissDuration: TimeInterval
    let dismissSignal: HeadsUpDismissSignal
    let onStartNow: () -> Void
    let onSnooze: () -> Void
    let onDismiss: () -> Void

    @State private var appeared = false
    @State private var dismissProgress: CGFloat = 0
    @State private var snoozeHovered = false

    private let messages = [
        "Almost time. Your eyes will appreciate a quick rest.",
        "A short break is coming up. Look away from the screen.",
        "Time for a breather. Your eyes have been working hard.",
        "Break incoming. Give your eyes a moment to relax.",
    ]

    @State private var selectedMessage = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Top row: time badge + dismiss button
            HStack {
                timeBadge
                Spacer()
                dismissButton
            }

            // Countdown timer
            HeadsUpTimerView(timeRemaining: breakManager.timeRemaining)

            // Message
            Text(selectedMessage)
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.6))

            // Action buttons
            HStack(spacing: 10) {
                Button(action: onStartNow) {
                    Text("Start this break now")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.white.opacity(0.2))
                        )
                }
                .buttonStyle(.plain)

                Button(action: onSnooze) {
                    HStack(spacing: 4) {
                        Text("Snooze")
                            .font(.system(size: 13, weight: .medium))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundStyle(.white.opacity(snoozeHovered ? 0.5 : 0.7))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white.opacity(0.1))
                    )
                }
                .buttonStyle(.plain)
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.15)) {
                        snoozeHovered = hovering
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
        .frame(width: 400)
        .offset(x: appeared ? 0 : 50)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            selectedMessage = messages.randomElement() ?? messages[0]
            withAnimation(.spring(duration: 0.5, bounce: 0.15)) {
                appeared = true
            }
            startDismissTimer()
        }
    }

    // MARK: - Time Badge

    private var timeBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 10))
            Text(timeSinceLastBreak)
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundStyle(.white.opacity(0.7))
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(.white.opacity(0.1))
        )
    }

    private var timeSinceLastBreak: String {
        let settings = AppSettings.shared
        let totalInterval = settings.shortBreakInterval
        let elapsed = totalInterval - breakManager.timeRemaining
        let mins = Int(elapsed) / 60
        if mins == 1 { return "1 min without a break" }
        return "\(mins) mins without a break"
    }

    // MARK: - Dismiss Button with Circular Progress

    private var dismissButton: some View {
        Button(action: onDismiss) {
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.15), lineWidth: 2.5)
                    .frame(width: 32, height: 32)

                Circle()
                    .trim(from: 0, to: dismissProgress)
                    .stroke(.white.opacity(0.5), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    .frame(width: 32, height: 32)
                    .rotationEffect(.degrees(-90))

                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .buttonStyle(.plain)
    }

    private func startDismissTimer() {
        guard autoDismissDuration > 0 else { return }
        withAnimation(.linear(duration: autoDismissDuration)) {
            dismissProgress = 1
        }
    }
}

// MARK: - Heads-Up Timer (smaller version of the overlay timer)

struct HeadsUpTimerView: View {
    let timeRemaining: TimeInterval

    private var minutes: Int { max(0, Int(timeRemaining)) / 60 }
    private var seconds: Int { max(0, Int(timeRemaining)) % 60 }

    var body: some View {
        HStack(spacing: 0) {
            HeadsUpRollingDigit(digit: minutes / 10)
            HeadsUpRollingDigit(digit: minutes % 10)

            Text(":")
                .font(.system(size: 36, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))

            HeadsUpRollingDigit(digit: seconds / 10)
            HeadsUpRollingDigit(digit: seconds % 10)
        }
    }
}

struct HeadsUpRollingDigit: View {
    let digit: Int

    @State private var displayedDigit: Int
    @State private var previousDigit: Int? = nil
    @State private var animationPhase: CGFloat = 1

    init(digit: Int) {
        self.digit = digit
        self._displayedDigit = State(initialValue: digit)
    }

    var body: some View {
        ZStack {
            if let prev = previousDigit {
                digitText(prev)
                    .opacity(1 - animationPhase)
                    .offset(y: -6 * animationPhase)
                    .scaleEffect(1 - 0.06 * animationPhase)
            }

            digitText(displayedDigit)
                .opacity(previousDigit == nil ? 1 : animationPhase)
                .offset(y: previousDigit == nil ? 0 : 6 * (1 - animationPhase))
                .scaleEffect(previousDigit == nil ? 1 : 0.94 + 0.06 * animationPhase)
        }
        .frame(width: 26, height: 44)
        .clipped()
        .onChange(of: digit) { oldVal, newVal in
            guard oldVal != newVal else { return }
            previousDigit = oldVal
            displayedDigit = newVal
            animationPhase = 0

            withAnimation(.interpolatingSpring(stiffness: 180, damping: 16)) {
                animationPhase = 1
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                previousDigit = nil
            }
        }
    }

    private func digitText(_ value: Int) -> some View {
        Text(String(value))
            .font(.system(size: 36, weight: .semibold, design: .rounded))
            .foregroundStyle(.white.opacity(0.8))
            .monospacedDigit()
    }
}
