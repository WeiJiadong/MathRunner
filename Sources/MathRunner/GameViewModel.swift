import Foundation
import MathCore
import Observation

/// 单局游戏状态：当前题、选项、答对/答错反馈、通关或失败
@MainActor
@Observable
final class GameViewModel {
    enum Feedback: Equatable {
        case none
        case correct(selected: Int)
        case wrong(selected: Int)
    }

    let level: DifficultyLevel
    let appModel: AppViewModel

    private let generator: ProblemGenerator
    private(set) var engine: GameEngine
    private(set) var problem: MathProblem
    private(set) var options: [Int]
    private(set) var feedback: Feedback = .none

    private(set) var showReward = false
    private(set) var showGameOver = false
    private(set) var earnedStars = 0
    private(set) var newlyUnlocked: [DressUpItem] = []

    init(level: DifficultyLevel, appModel: AppViewModel) {
        self.level = level
        self.appModel = appModel
        self.generator = ProblemGenerator()
        let engine = GameEngine(level: level)
        self.engine = engine
        let problem = generator.nextProblem(level: level, isBoss: engine.isBossRound)
        self.problem = problem
        self.options = generator.options(for: problem, level: level)
    }

    /// 当前是否处于答错反馈中（用于揭示正确答案）
    var pickedWrong: Bool {
        if case .wrong = feedback { return true }
        return false
    }

    func answer(_ value: Int) {
        guard feedback == .none, !showReward, !showGameOver else { return }
        let correct = value == problem.answer
        feedback = correct ? .correct(selected: value) : .wrong(selected: value)
        GameSound.play(correct ? .correct : .wrong)
        let outcome = engine.submit(answer: correct)

        Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(for: .milliseconds(correct ? 700 : 1100))
            self.handle(outcome)
        }
    }

    private func handle(_ outcome: GameEngine.RoundOutcome) {
        switch outcome {
        case .defeatedMonster, .wrongButSurvived:
            feedback = .none
            let next = generator.nextProblem(level: level, isBoss: engine.isBossRound)
            problem = next
            options = generator.options(for: next, level: level)
        case .levelCleared(let stars):
            earnedStars = stars
            newlyUnlocked = appModel.recordLevelClear(level: level, stars: stars)
            GameSound.play(.clear)
            showReward = true
        case .gameOver:
            GameSound.play(.lose)
            showGameOver = true
        }
    }

    func restart() {
        engine = GameEngine(level: level)
        feedback = .none
        showReward = false
        showGameOver = false
        newlyUnlocked = []
        let next = generator.nextProblem(level: level, isBoss: engine.isBossRound)
        problem = next
        options = generator.options(for: next, level: level)
    }
}
