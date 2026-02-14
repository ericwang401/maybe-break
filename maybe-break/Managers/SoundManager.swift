import AppKit
import AVFoundation

final class SoundManager {
    static let shared = SoundManager()
    private var player: AVAudioPlayer?
    private var settings: AppSettings { AppSettings.shared }

    private init() {}

    func playBreakStartSound() {
        guard settings.playSoundOnBreakStart else { return }
        playSystemSound(named: "Glass")
    }

    func playBreakEndSound() {
        guard settings.playSoundOnBreakEnd else { return }
        playSystemSound(named: "Breeze")
    }

    private func playSystemSound(named name: String) {
        let paths = [
            "/System/Library/Sounds/\(name).aiff",
            "/System/Library/Sounds/Blow.aiff"
        ]
        for path in paths {
            let url = URL(fileURLWithPath: path)
            if FileManager.default.fileExists(atPath: path) {
                do {
                    player = try AVAudioPlayer(contentsOf: url)
                    player?.volume = settings.soundVolume
                    player?.play()
                    return
                } catch {
                    continue
                }
            }
        }
        NSSound.beep()
    }
}
