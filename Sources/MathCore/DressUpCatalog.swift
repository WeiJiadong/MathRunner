/// 装扮图鉴：累计星星达到门槛自动解锁
public struct DressUpItem: Identifiable, Equatable, Sendable {
    public let id: String
    public let emoji: String
    public let name: String
    public let starThreshold: Int

    public init(id: String, emoji: String, name: String, starThreshold: Int) {
        self.id = id
        self.emoji = emoji
        self.name = name
        self.starThreshold = starThreshold
    }
}

public enum DressUpCatalog {
    public static let items: [DressUpItem] = [
        DressUpItem(id: "cap",     emoji: "🎓", name: "学霸帽",     starThreshold: 3),
        DressUpItem(id: "crown",   emoji: "👑", name: "小皇冠",     starThreshold: 6),
        DressUpItem(id: "scarf",   emoji: "🧣", name: "暖围巾",     starThreshold: 10),
        DressUpItem(id: "chick",  emoji: "🐤", name: "小鸡伙伴",   starThreshold: 15),
        DressUpItem(id: "unicorn", emoji: "🦄", name: "独角兽伙伴", starThreshold: 21),
        DressUpItem(id: "rocket",  emoji: "🚀", name: "星际披风",   starThreshold: 28),
    ]

    public static func unlockedItems(totalStars: Int) -> [DressUpItem] {
        items.filter { totalStars >= $0.starThreshold }
    }

    /// 下一个未解锁的装扮（用于菜单提示）
    public static func nextLockedItem(totalStars: Int) -> DressUpItem? {
        items.first { totalStars < $0.starThreshold }
    }
}
