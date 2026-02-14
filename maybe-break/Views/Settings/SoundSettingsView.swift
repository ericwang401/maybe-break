import SwiftUI

struct SoundSettingsView: View {
    @State private var settings = AppSettings.shared

    @State private var playOnStart = AppSettings.shared.playSoundOnBreakStart
    @State private var playOnEnd = AppSettings.shared.playSoundOnBreakEnd
    @State private var volume = AppSettings.shared.soundVolume

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Sound Effects")
                .font(.title2.bold())

            GroupBox {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Toggle("Play sound when break begins", isOn: $playOnStart)
                            .onChange(of: playOnStart) { _, val in settings.playSoundOnBreakStart = val }
                        Spacer()
                        Button {
                            SoundManager.shared.playBreakStartSound()
                        } label: {
                            Image(systemName: "play.circle")
                        }
                        .buttonStyle(.plain)
                    }

                    HStack {
                        Toggle("Play sound when break ends", isOn: $playOnEnd)
                            .onChange(of: playOnEnd) { _, val in settings.playSoundOnBreakEnd = val }
                        Spacer()
                        Button {
                            SoundManager.shared.playBreakEndSound()
                        } label: {
                            Image(systemName: "play.circle")
                        }
                        .buttonStyle(.plain)
                    }

                    Divider()

                    HStack {
                        Text("Volume")
                        Image(systemName: "speaker.fill")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 11))
                        Slider(value: $volume, in: 0...1, step: 0.1)
                            .frame(width: 200)
                            .onChange(of: volume) { _, val in settings.soundVolume = val }
                        Image(systemName: "speaker.wave.3.fill")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 11))
                    }
                }
                .padding(4)
            }

            Spacer()
        }
    }
}
