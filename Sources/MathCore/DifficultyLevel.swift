/// 难度档位：入门 10 以内 → 进阶 20 以内不进退位 → 挑战进位加/退位减
public enum DifficultyLevel: Int, CaseIterable, Identifiable, Sendable {
    case within10 = 1
    case within20NoCarry = 2
    case within20Carry = 3

    public var id: Int { rawValue }

    public var title: String {
        switch self {
        case .within10: "第 1 关 · 10 以内加减"
        case .within20NoCarry: "第 2 关 · 20 以内加减"
        case .within20Carry: "第 3 关 · 进位与退位"
        }
    }

    public var subtitle: String {
        switch self {
        case .within10: "10 以内的加减法"
        case .within20NoCarry: "20 以内，不用进位退位"
        case .within20Carry: "进位加法 + 退位减法"
        }
    }

    public var badgeEmoji: String {
        switch self {
        case .within10: "🐣"
        case .within20NoCarry: "🐴"
        case .within20Carry: "🐉"
        }
    }

    public var next: DifficultyLevel? {
        DifficultyLevel(rawValue: rawValue + 1)
    }
}
