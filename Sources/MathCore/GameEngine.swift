/// 单局状态机：5 道常规题 + 1 道 Boss 题，3 颗心，无倒计时
public struct GameEngine: Sendable {
    public static let regularQuestionCount = 5
    public static let bossRoundIndex = regularQuestionCount
    public static let totalQuestionCount = regularQuestionCount + 1
    public static let maxHearts = 3

    public let level: DifficultyLevel
    public private(set) var hearts: Int
    public private(set) var answeredCount: Int

    public init(level: DifficultyLevel) {
        self.level = level
        self.hearts = Self.maxHearts
        self.answeredCount = 0
    }

    /// 当前是否为 Boss 题（第 6 题）
    public var isBossRound: Bool { answeredCount == Self.bossRoundIndex }

    public var progress: Double {
        Double(answeredCount) / Double(Self.totalQuestionCount)
    }

    public enum RoundOutcome: Equatable, Sendable {
        case defeatedMonster
        case wrongButSurvived
        case levelCleared(stars: Int)
        case gameOver
    }

    @discardableResult
    public mutating func submit(answer correct: Bool) -> RoundOutcome {
        if correct {
            answeredCount += 1
            if answeredCount >= Self.totalQuestionCount {
                return .levelCleared(stars: hearts)
            }
            return .defeatedMonster
        }
        hearts -= 1
        return hearts <= 0 ? .gameOver : .wrongButSurvived
    }
}
