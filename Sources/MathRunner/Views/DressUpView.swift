import SwiftUI
import MathCore

/// 装扮图鉴：已解锁可佩戴，未解锁显示解锁所需星星
struct DressUpView: View {
    let appModel: AppViewModel

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 16)]

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button("← 返回") { appModel.goMenu() }
                    .buttonStyle(.bordered)
                Spacer()
                Text("🎒 装扮图鉴")
                    .font(.system(size: 30, weight: .bold))
                Spacer()
                Text("⭐ \(appModel.totalStars)")
                    .font(.system(size: 24, weight: .bold))
            }

            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(DressUpCatalog.items) { item in
                        itemCard(item)
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(36)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func itemCard(_ item: DressUpItem) -> some View {
        let unlocked = appModel.totalStars >= item.starThreshold
        let equipped = appModel.equippedItem?.id == item.id

        Button {
            guard unlocked else { return }
            appModel.equip(equipped ? nil : item)
        } label: {
            VStack(spacing: 10) {
                Text(item.emoji)
                    .font(.system(size: 50))
                    .opacity(unlocked ? 1.0 : 0.25)
                    .overlay {
                        if !unlocked {
                            Text("🔒")
                                .font(.system(size: 30))
                        }
                    }
                Text(item.name)
                    .font(.system(size: 18, weight: .semibold))
                if unlocked {
                    Text(equipped ? "佩戴中" : "点击佩戴")
                        .font(.system(size: 14))
                        .foregroundStyle(equipped ? .orange : .secondary)
                } else {
                    Text("⭐\(item.starThreshold) 解锁")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 150, height: 150)
            .background(equipped ? Color.orange.opacity(0.2) : Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(equipped ? Color.orange : .clear, lineWidth: 3)
            )
        }
        .buttonStyle(.plain)
        .disabled(!unlocked)
    }
}
