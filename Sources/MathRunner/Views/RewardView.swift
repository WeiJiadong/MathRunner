import SwiftUI
import MathCore

/// 通关庆祝弹层：星星、新解锁装扮、操作按钮
struct RewardView: View {
    let level: DifficultyLevel
    let stars: Int
    let newlyUnlocked: [DressUpItem]
    let onReplay: () -> Void
    let onNext: () -> Void
    let onMenu: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Text("🎉 通关啦！")
                .font(.system(size: 44, weight: .heavy))

            HStack(spacing: 8) {
                ForEach(1...3, id: \.self) { i in
                    Text(i <= stars ? "⭐" : "☆")
                        .font(.system(size: 60))
                        .scaleEffect(i <= stars ? 1.0 : 0.8)
                        .animation(
                            .spring(duration: 0.4).delay(Double(i) * 0.15),
                            value: stars
                        )
                }
            }

            if let item = newlyUnlocked.first {
                Text("🎁 解锁新装扮：\(item.emoji) \(item.name)")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.orange)
            }

            HStack(spacing: 16) {
                Button("再来一次") { onReplay() }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                if level.next != nil {
                    Button("下一关") { onNext() }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                }
                Button("返回地图") { onMenu() }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
            }
        }
        .padding(40)
        .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 28))
        .shadow(radius: 20)
    }
}

/// 失败弹层：温和鼓励，无惩罚语
struct GameOverView: View {
    let onReplay: () -> Void
    let onMenu: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("😿")
                .font(.system(size: 64))
            Text("差一点点，再来挑战！")
                .font(.system(size: 28, weight: .bold))
            Text("心用完了，勇士休息一下再出发吧")
                .font(.system(size: 18))
                .foregroundStyle(.secondary)
            HStack(spacing: 16) {
                Button("重新挑战") { onReplay() }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                Button("返回地图") { onMenu() }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
            }
        }
        .padding(40)
        .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 28))
        .shadow(radius: 20)
    }
}
