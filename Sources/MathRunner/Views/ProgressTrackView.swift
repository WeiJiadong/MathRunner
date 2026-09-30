import SwiftUI
import MathCore

/// 上方跑酷进度条：英雄在前、怪在每站、城堡在终点
struct ProgressTrackView: View {
    let engine: GameEngine
    let accessoryEmoji: String?

    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<GameEngine.totalQuestionCount, id: \.self) { index in
                stop(at: index)
            }
            Text("🏰")
                .font(.system(size: 44))
                .scaleEffect(engine.answeredCount >= GameEngine.totalQuestionCount ? 1.15 : 1.0)
                .animation(.spring(duration: 0.4), value: engine.answeredCount)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 22)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.quaternary)
        )
        .animation(.spring(duration: 0.3), value: engine.answeredCount)
    }

    @ViewBuilder
    private func stop(at index: Int) -> some View {
        let isBoss = index == GameEngine.bossRoundIndex
        let isDefeated = engine.answeredCount > index
        let isCurrent = engine.answeredCount == index

        ZStack {
            if isDefeated {
                Text("✅")
            } else if isCurrent {
                heroView
            } else {
                Text(isBoss ? "🐲" : "👹")
            }
        }
        .font(.system(size: isBoss ? 44 : 36))
        .scaleEffect(isCurrent ? 1.15 : 1.0)
    }

    @ViewBuilder
    private var heroView: some View {
        if let emoji = accessoryEmoji {
            ZStack(alignment: .topTrailing) {
                Text("🧒")
                    .font(.system(size: 40))
                Text(emoji)
                    .font(.system(size: 22))
                    .offset(x: 6, y: -6)
            }
        } else {
            Text("🧒")
                .font(.system(size: 40))
        }
    }
}
