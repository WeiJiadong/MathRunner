import SwiftUI
import MathCore

struct MenuView: View {
    let appModel: AppViewModel

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Spacer()
                Button("🎒 装扮图鉴") { appModel.openDressUp() }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
            }

            VStack(spacing: 8) {
                Text("🧒⚔️ 数学小勇士 🐉")
                    .font(.system(size: 46, weight: .heavy))
                Text("答题斩怪，闯关集星星！")
                    .font(.system(size: 20))
                    .foregroundStyle(.secondary)
            }

            Text("⭐ \(appModel.totalStars)")
                .font(.system(size: 30, weight: .bold))

            VStack(spacing: 16) {
                ForEach(DifficultyLevel.allCases) { level in
                    levelCard(level)
                }
            }

            if let next = DressUpCatalog.nextLockedItem(totalStars: appModel.totalStars) {
                Text("再集 \(next.starThreshold - appModel.totalStars) ⭐ 解锁 \(next.emoji) \(next.name)")
                    .font(.system(size: 17))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func levelCard(_ level: DifficultyLevel) -> some View {
        Button {
            appModel.start(level: level)
        } label: {
            HStack(spacing: 20) {
                Text(level.badgeEmoji)
                    .font(.system(size: 44))
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.title)
                        .font(.system(size: 26, weight: .bold))
                    Text(level.subtitle)
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(bestStarsText(level))
                    .font(.system(size: 22))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .frame(width: 560)
            .background(levelColor(level).opacity(0.18))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .hoverEffect()
    }

    private func bestStarsText(_ level: DifficultyLevel) -> String {
        let best = appModel.bestStars(level: level)
        guard best > 0 else { return "☆☆☆" }
        return String(repeating: "⭐", count: best)
    }

    private func levelColor(_ level: DifficultyLevel) -> Color {
        switch level {
        case .within10: .green
        case .within20NoCarry: .blue
        case .within20Carry: .orange
        }
    }
}

private struct HoverScaleModifier: ViewModifier {
    @State private var hovering = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(hovering ? 1.03 : 1.0)
            .onHover { hovering = $0 }
            .animation(.spring(duration: 0.2), value: hovering)
    }
}

private extension View {
    func hoverEffect() -> some View {
        modifier(HoverScaleModifier())
    }
}
