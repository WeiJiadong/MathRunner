import Foundation
import MathCore
import Observation

/// 全局导航与进度：主菜单 / 游戏 / 装扮页
@MainActor
@Observable
final class AppViewModel {
    enum Screen: Equatable {
        case menu
        case game(DifficultyLevel)
        case dressUp
    }

    private let store = ProgressStore()

    private(set) var screen: Screen = .menu

    var totalStars: Int { store.totalStars }

    var equippedItem: DressUpItem? {
        guard let id = store.equippedItemID else { return nil }
        return DressUpCatalog.items.first { $0.id == id }
    }

    func goMenu() { screen = .menu }
    func openDressUp() { screen = .dressUp }
    func start(level: DifficultyLevel) { screen = .game(level) }

    func bestStars(level: DifficultyLevel) -> Int {
        store.bestStars(level: level)
    }

    /// 记录通关并返回本次新解锁的装扮
    func recordLevelClear(level: DifficultyLevel, stars: Int) -> [DressUpItem] {
        let beforeIDs = Set(DressUpCatalog.unlockedItems(totalStars: store.totalStars).map(\.id))
        store.recordLevelClear(level: level, stars: stars)
        let newItems = DressUpCatalog.unlockedItems(totalStars: store.totalStars)
            .filter { !beforeIDs.contains($0.id) }
        if let first = newItems.first {
            equip(first)
        }
        return newItems
    }

    /// 佩戴装扮；传 nil 表示取下
    func equip(_ item: DressUpItem?) {
        store.equippedItemID = item?.id
    }
}
