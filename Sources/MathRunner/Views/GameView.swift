import SwiftUI
import MathCore

struct GameView: View {
    let appModel: AppViewModel
    let level: DifficultyLevel

    @State private var viewModel: GameViewModel

    init(appModel: AppViewModel, level: DifficultyLevel) {
        self.appModel = appModel
        self.level = level
        _viewModel = State(initialValue: GameViewModel(level: level, appModel: appModel))
    }

    var body: some View {
        ZStack {
            VStack(spacing: 22) {
                header
                ProgressTrackView(
                    engine: viewModel.engine,
                    accessoryEmoji: appModel.equippedItem?.emoji
                )
                questionCard
                answerButtons
                bottomBar
                Spacer()
            }
            .padding(36)

            if viewModel.showReward {
                RewardView(
                    level: level,
                    stars: viewModel.earnedStars,
                    newlyUnlocked: viewModel.newlyUnlocked,
                    onReplay: { viewModel.restart() },
                    onNext: {
                        if let next = level.next {
                            appModel.start(level: next)
                        }
                    },
                    onMenu: { appModel.goMenu() }
                )
                .transition(.scale.combined(with: .opacity))
            }

            if viewModel.showGameOver {
                GameOverView(
                    onReplay: { viewModel.restart() },
                    onMenu: { appModel.goMenu() }
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.3), value: viewModel.showReward)
        .animation(.spring(duration: 0.3), value: viewModel.showGameOver)
    }

    private var header: some View {
        HStack {
            Button("🗺 返回") { appModel.goMenu() }
                .buttonStyle(.bordered)
            Spacer()
            Text(level.title)
                .font(.system(size: 20, weight: .bold))
            Spacer()
            HStack(spacing: 4) {
                ForEach(0..<GameEngine.maxHearts, id: \.self) { i in
                    Text(i < viewModel.engine.hearts ? "❤️" : "🤍")
                        .font(.system(size: 22))
                }
            }
        }
    }

    private var questionCard: some View {
        VStack(spacing: 8) {
            if viewModel.engine.isBossRound {
                Text("🐲 Boss 来了！")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.orange)
            }
            Text("\(viewModel.problem.text) = ?")
                .font(.system(size: 72, weight: .bold, design: .rounded).monospacedDigit())
        }
        .padding(.vertical, 16)
    }

    private var answerButtons: some View {
        HStack(spacing: 20) {
            ForEach(Array(viewModel.options.enumerated()), id: \.offset) { index, value in
                answerButton(value, index: index)
            }
        }
    }

    @ViewBuilder
    private func answerButton(_ value: Int, index: Int) -> some View {
        let isPickedCorrect = viewModel.feedback == .correct(selected: value)
        let isPickedWrong = viewModel.feedback == .wrong(selected: value)
        let isCorrectReveal = viewModel.pickedWrong && value == viewModel.problem.answer

        Button {
            viewModel.answer(value)
        } label: {
            Text("\(value)")
                .font(.system(size: 50, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 130, height: 100)
                .background(buttonColor(
                    index: index,
                    correct: isPickedCorrect || isCorrectReveal,
                    wrong: isPickedWrong
                ))
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .shadow(radius: 4, y: 3)
        }
        .buttonStyle(.plain)
        .disabled(viewModel.feedback != .none)
    }

    private func buttonColor(index: Int, correct: Bool, wrong: Bool) -> Color {
        if correct { return .green }
        if wrong { return .red }
        return [.blue, .orange, .purple][index]
    }

    private var bottomBar: some View {
        HStack {
            Text("第 \(min(viewModel.engine.answeredCount + 1, GameEngine.totalQuestionCount))/\(GameEngine.totalQuestionCount) 题")
                .font(.system(size: 18))
                .foregroundStyle(.secondary)
            Spacer()
            Text("⭐ \(appModel.totalStars)")
                .font(.system(size: 22, weight: .bold))
        }
    }
}
