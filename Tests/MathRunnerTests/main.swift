import Foundation
import MathCore

// CLT 工具链无 XCTest，用独立可执行 main 做断言。
// Swift 6 严格并发下顶层变量无法加 MainActor，装进结构体规避。
struct AssertionRunner {
    var failures: [String] = []
    var checks = 0

    @inline(__always)
    mutating func expect(_ cond: Bool, _ label: String) {
        checks += 1
        if !cond { failures.append(label) }
    }
}

@MainActor
func runTests() {
    var runner = AssertionRunner()
    let gen = ProblemGenerator()

    // MARK: - L1：10 以内
    for _ in 0..<300 {
        let p = gen.nextProblem(level: .within10, isBoss: false)
        runner.expect(p.answer >= 1 && p.answer <= 10, "L1 answer 越界: \(p.text)=\(p.answer)")
        switch p.op {
        case .add: runner.expect(p.a + p.b <= 10, "L1 加法越界: \(p.text)")
        case .subtract: runner.expect(p.a - p.b >= 1, "L1 减法结果<1: \(p.text)")
        }
    }

    // MARK: - L2：20 以内不进位/不退位
    for _ in 0..<300 {
        let p = gen.nextProblem(level: .within20NoCarry, isBoss: false)
        switch p.op {
        case .add:
            runner.expect(p.a % 10 + p.b % 10 <= 9, "L2 加法出现进位: \(p.text)")
            runner.expect(p.answer <= 20, "L2 加法结果>20: \(p.text)")
        case .subtract:
            runner.expect(p.b <= p.a % 10, "L2 减法出现退位: \(p.text)")
            runner.expect(p.answer >= 10, "L2 减法结果<10: \(p.text)")
        }
    }

    // MARK: - L3：进位加法 / 退位减法
    for _ in 0..<300 {
        let p = gen.nextProblem(level: .within20Carry, isBoss: false)
        switch p.op {
        case .add:
            runner.expect(p.a % 10 + p.b % 10 >= 10, "L3 加法无进位: \(p.text)")
            runner.expect(p.answer >= 11 && p.answer <= 20, "L3 加法结果越界: \(p.text)=\(p.answer)")
        case .subtract:
            runner.expect(p.b > p.a % 10, "L3 减法无退位: \(p.text)")
            runner.expect(p.answer >= 2 && p.answer <= 20, "L3 减法结果越界: \(p.text)=\(p.answer)")
        }
    }

    // MARK: - Boss 题答案不太小
    for _ in 0..<200 {
        let p = gen.nextProblem(level: .within10, isBoss: true)
        runner.expect(p.answer >= 3, "Boss 题答案过小: \(p.text)=\(p.answer)")
    }

    // MARK: - 选项：3 个、不重复、含答案、均非负
    for _ in 0..<500 {
        let p = gen.nextProblem(level: .within20Carry, isBoss: true)
        let opts = gen.options(for: p, level: .within20Carry)
        runner.expect(opts.count == 3, "选项数量≠3: \(opts)")
        runner.expect(Set(opts).count == 3, "选项有重复: \(opts)")
        runner.expect(opts.contains(p.answer), "选项缺少正确答案: \(opts) 答案=\(p.answer)")
        runner.expect(opts.allSatisfy { $0 >= 0 }, "选项出现负数: \(opts)")
    }

    // MARK: - GameEngine：全胜路径 3 星
    var winEngine = GameEngine(level: .within20Carry)
    runner.expect(winEngine.hearts == 3 && winEngine.answeredCount == 0, "初始状态错误")
    var last: GameEngine.RoundOutcome
    for _ in 0..<GameEngine.regularQuestionCount {
        last = winEngine.submit(answer: true)
        runner.expect(last == .defeatedMonster, "常规答对未前进: \(last)")
    }
    runner.expect(winEngine.isBossRound, "未进入 Boss 回合")
    last = winEngine.submit(answer: true)
    if case .levelCleared(let stars) = last {
        runner.expect(stars == 3, "满血通关应得 3 星，实际 \(stars)")
    } else {
        runner.expect(false, "Boss 答对未通关: \(last)")
    }

    // MARK: - GameEngine：答错一次后通关得 2 星
    var twoStar = GameEngine(level: .within10)
    last = twoStar.submit(answer: false)
    runner.expect(last == .wrongButSurvived && twoStar.hearts == 2, "答错未扣心: \(last) hearts=\(twoStar.hearts)")
    for _ in 0..<GameEngine.regularQuestionCount {
        twoStar.submit(answer: true)
    }
    last = twoStar.submit(answer: true)
    if case .levelCleared(let stars) = last {
        runner.expect(stars == 2, "2 血通关应得 2 星，实际 \(stars)")
    } else {
        runner.expect(false, "Boss 答对未通关: \(last)")
    }

    // MARK: - GameEngine：三答错失败
    var loseEngine = GameEngine(level: .within20Carry)
    last = loseEngine.submit(answer: false)
    runner.expect(last == .wrongButSurvived, "首次答错不应直接失败")
    last = loseEngine.submit(answer: false)
    runner.expect(last == .wrongButSurvived && loseEngine.hearts == 1, "第二次扣心异常")
    last = loseEngine.submit(answer: false)
    runner.expect(last == .gameOver && loseEngine.hearts == 0, "第三次应 gameOver")

    // MARK: - 装扮图鉴门槛递增
    let items = DressUpCatalog.items
    for i in 0..<(items.count - 1) {
        runner.expect(items[i].starThreshold < items[i + 1].starThreshold, "装扮门槛非递增: \(items[i]) → \(items[i + 1])")
    }
    runner.expect(DressUpCatalog.unlockedItems(totalStars: 10).count == 3, "10 星应解锁 3 件")
    runner.expect(DressUpCatalog.unlockedItems(totalStars: 28).count == items.count, "28 星应解锁全部")
    runner.expect(DressUpCatalog.nextLockedItem(totalStars: 6)?.id == "scarf", "nextLocked 计算错误")

    // MARK: - ProgressStore 存档往返
    let suite = "test.mathrunner.\(Int.random(in: 1...99999))"
    defer { UserDefaults().removePersistentDomain(forName: suite) }
    let defaults = UserDefaults(suiteName: suite)!
    let store = ProgressStore(defaults: defaults)
    store.recordLevelClear(level: .within10, stars: 2)
    store.recordLevelClear(level: .within10, stars: 3)
    runner.expect(store.bestStars(level: .within10) == 3, "最佳记录未刷新")
    runner.expect(store.totalStars == 5, "总星数累加错误: \(store.totalStars)")
    store.equippedItemID = "cap"
    runner.expect(store.equippedItemID == "cap", "佩戴记录往返失败")

    // MARK: - 结果
    if runner.failures.isEmpty {
        print("ALL PASS (\(runner.checks) checks)")
    } else {
        print("FAILURES (\(runner.failures.count)/\(runner.checks)):")
        runner.failures.forEach { print("  ✗ \($0)") }
    }
    exit(runner.failures.isEmpty ? 0 : 1)
}

runTests()
