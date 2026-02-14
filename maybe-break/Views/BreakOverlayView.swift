import SwiftUI

struct BreakOverlayView: View {
    let breakManager: BreakManager
    var dismissSignal: OverlayDismissSignal
    let onSkip: () -> Void
    let onLockScreen: () -> Void

    @State private var escPressCount = 0
    @State private var escResetTask: Task<Void, Never>?

    // Stable message — picked once on appear
    @State private var message: String = ""
    @State private var subtitle: String = ""

    // Entrance animation states
    @State private var showBackground = false
    @State private var showQuote = false
    @State private var showDetails = false
    @State private var showEdges = false

    // Exit animation state
    @State private var dismissing = false

    var body: some View {
        ZStack {
            AnimatedGradientBackground()
                .opacity(showBackground && !dismissing ? 1 : 0)

            VStack(spacing: 0) {
                // Current time — slides in from top / slides out to top on dismiss
                Text("Current time is \(currentTimeString)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.top, 60)
                    .offset(y: dismissing ? -200 : (showEdges ? 0 : -200))
                    .opacity(dismissing ? 0 : 1)

                Spacer()

                // Quote — fades + slides up on dismiss
                Text(message)
                    .font(.system(size: 56, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(dismissing ? 0 : (showQuote ? 1 : 0))
                    .offset(y: dismissing ? -30 : (showQuote ? 0 : -20))

                // Subtitle + divider + timer — fade out in place
                Text(subtitle)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.top, 12)
                    .opacity(dismissing ? 0 : (showDetails ? 1 : 0))

                Rectangle()
                    .fill(.white.opacity(0.2))
                    .frame(width: 200, height: 1)
                    .padding(.top, 30)
                    .opacity(dismissing ? 0 : (showDetails ? 1 : 0))

                AnimatedTimerView(timeRemaining: breakManager.breakTimeRemaining)
                    .padding(.top, 30)
                    .opacity(dismissing ? 0 : (showDetails ? 1 : 0))

                Spacer()

                // Bottom controls — slides down on dismiss
                VStack(spacing: 12) {
                    HStack(spacing: 16) {
                        Button(action: onSkip) {
                            HStack(spacing: 6) {
                                Image(systemName: "forward.fill")
                                    .font(.system(size: 12))
                                Text("Skip")
                                    .font(.system(size: 15, weight: .medium))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(.white.opacity(0.2), in: Capsule())
                        }
                        .buttonStyle(.plain)

                        Button(action: onLockScreen) {
                            HStack(spacing: 6) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 12))
                                Text("Lock Screen")
                                    .font(.system(size: 15, weight: .medium))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(.white.opacity(0.2), in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }

                    Text("Press Esc twice to skip")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .padding(.bottom, 40)
                .offset(y: dismissing ? 200 : (showEdges ? 0 : 200))
                .opacity(dismissing ? 0 : 1)
            }
        }
        .onKeyPress(.escape) {
            handleEscPress()
            return .handled
        }
        .onAppear {
            pickMessage()
            runEntranceSequence()
        }
        .onChange(of: dismissSignal.isDismissing) { _, isDismissing in
            if isDismissing {
                runExitAnimation()
            }
        }
    }

    private var currentTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }

    private func pickMessage() {
        let settings = AppSettings.shared
        let isLong: Bool = {
            if case .onBreak(let l) = breakManager.state { return l }
            return false
        }()

        if settings.customMessagesEnabled, !settings.customMessages.isEmpty {
            message = settings.customMessages.randomElement() ?? "Relax those eyes"
        } else {
            message = "Relax those eyes"
        }

        subtitle = isLong
            ? "Take a longer break. Stretch, walk around, and rest."
            : "Set your eyes on something distant until the countdown is over"
    }

    private func runEntranceSequence() {
        withAnimation(.easeOut(duration: 0.5)) {
            showBackground = true
        }
        withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
            showQuote = true
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.7)) {
            showDetails = true
        }
        withAnimation(.spring(duration: 0.7, bounce: 0.15).delay(1.0)) {
            showEdges = true
        }
    }

    private func runExitAnimation() {
        withAnimation(.easeIn(duration: 0.5)) {
            dismissing = true
        }
    }

    private func handleEscPress() {
        escPressCount += 1
        if escPressCount >= 2 {
            onSkip()
            escPressCount = 0
            return
        }
        escResetTask?.cancel()
        escResetTask = Task {
            try? await Task.sleep(for: .seconds(1))
            if !Task.isCancelled {
                escPressCount = 0
            }
        }
    }
}

// MARK: - Animated Timer

struct AnimatedTimerView: View {
    let timeRemaining: TimeInterval

    private var minutes: Int { max(0, Int(timeRemaining)) / 60 }
    private var seconds: Int { max(0, Int(timeRemaining)) % 60 }

    var body: some View {
        HStack(spacing: 0) {
            RollingDigit(digit: minutes / 10)
            RollingDigit(digit: minutes % 10)

            Text(":")
                .font(.system(size: 64, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))

            RollingDigit(digit: seconds / 10)
            RollingDigit(digit: seconds % 10)
        }
    }
}

struct RollingDigit: View {
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
                    .offset(y: -10 * animationPhase)
                    .scaleEffect(1 - 0.06 * animationPhase)
            }

            digitText(displayedDigit)
                .opacity(previousDigit == nil ? 1 : animationPhase)
                .offset(y: previousDigit == nil ? 0 : 10 * (1 - animationPhase))
                .scaleEffect(previousDigit == nil ? 1 : 0.94 + 0.06 * animationPhase)
        }
        .frame(width: 44, height: 76)
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
            .font(.system(size: 64, weight: .semibold, design: .rounded))
            .foregroundStyle(.white.opacity(0.8))
            .monospacedDigit()
    }
}

// MARK: - Background

struct AnimatedGradientBackground: View {
    @State private var animate = false

    var body: some View {
        let settings = AppSettings.shared
        ZStack {
            MeshGradient(
                width: 3, height: 3,
                points: [
                    [0, 0], [0.5, 0], [1, 0],
                    [0, 0.5], [0.5, 0.5], [1, 0.5],
                    [0, 1], [0.5, 1], [1, 1]
                ],
                colors: [
                    settings.gradientStartColor.opacity(0.8),
                    settings.gradientEndColor,
                    settings.gradientStartColor,
                    settings.gradientEndColor.opacity(0.9),
                    settings.gradientStartColor.opacity(0.7),
                    settings.gradientEndColor.opacity(0.8),
                    settings.gradientStartColor.opacity(0.9),
                    settings.gradientEndColor.opacity(0.7),
                    settings.gradientStartColor
                ]
            )
            .ignoresSafeArea()

            Color.black.opacity(animate ? 0.1 : 0.2)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: animate)
        }
        .onAppear { animate = true }
    }
}
