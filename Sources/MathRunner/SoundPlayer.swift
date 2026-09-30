import AppKit

/// 系统音效；找不到对应音效时静默，不影响主流程
enum GameSound: String {
    case correct = "Glass"
    case wrong = "Basso"
    case clear = "Hero"
    case lose = "Sosumi"

    static func play(_ sound: GameSound) {
        NSSound(named: NSSound.Name(sound.rawValue))?.play()
    }
}
