import Foundation

/// 星星与装扮存档（UserDefaults 持久化）
public final class ProgressStore: @unchecked Sendable {
    private let defaults: UserDefaults
    private let totalStarsKey = "mathrunner.totalStars"
    private let equippedItemKey = "mathrunner.equippedItem"
    private let bestStarsPrefix = "mathrunner.bestStars."

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public var totalStars: Int {
        get { defaults.integer(forKey: totalStarsKey) }
        set { defaults.set(newValue, forKey: totalStarsKey) }
    }

    public var equippedItemID: String? {
        get { defaults.string(forKey: equippedItemKey) }
        set { defaults.set(newValue, forKey: equippedItemKey) }
    }

    public func bestStars(level: DifficultyLevel) -> Int {
        defaults.integer(forKey: bestStarsPrefix + "\(level.rawValue)")
    }

    /// 记录通关：累加星星、刷新本关最佳
    public func recordLevelClear(level: DifficultyLevel, stars: Int) {
        let key = bestStarsPrefix + "\(level.rawValue)"
        let existing = defaults.integer(forKey: key)
        if stars > existing {
            defaults.set(stars, forKey: key)
        }
        totalStars += stars
    }
}
