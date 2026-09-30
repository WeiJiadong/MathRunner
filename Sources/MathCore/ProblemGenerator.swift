import Foundation

/// 按难度生成算式与干扰选项
public struct ProblemGenerator: Sendable {
    public init() {}

    /// 生成一道题；Boss 题保证答案不太小，避免一眼看出结果
    public func nextProblem(level: DifficultyLevel, isBoss: Bool) -> MathProblem {
        var problem = makeProblem(level: level)
        if isBoss {
            var attempts = 0
            while problem.answer < 3 && attempts < 10 {
                problem = makeProblem(level: level)
                attempts += 1
            }
        }
        return problem
    }

    /// 生成 3 个答案选项：正确答案 + 2 个近似干扰项
    public func options(for problem: MathProblem, level: DifficultyLevel) -> [Int] {
        var distractors: [Int] = []
        for offset in distractorOffsets(level: level).shuffled() where distractors.count < 2 {
            let candidate = problem.answer + offset
            if candidate >= 0, !distractors.contains(candidate), candidate != problem.answer {
                distractors.append(candidate)
            }
        }
        var fill = 1
        while distractors.count < 2 {
            let candidate = problem.answer + fill
            if candidate >= 0, candidate != problem.answer, !distractors.contains(candidate) {
                distractors.append(candidate)
            }
            fill += 1
        }
        return (distractors + [problem.answer]).shuffled()
    }

    // MARK: - 干扰项偏移：难度越高干扰越狡猾（混入 ±10 的典型错解）

    private func distractorOffsets(level: DifficultyLevel) -> [Int] {
        switch level {
        case .within10: [1, -1, 2, -2]
        case .within20NoCarry: [1, -1, 10, -10, 2, -2]
        case .within20Carry: [1, -1, 10, -10, 2, -2, 3, -3]
        }
    }

    // MARK: - 按难度出题

    private func makeProblem(level: DifficultyLevel) -> MathProblem {
        switch level {
        case .within10:
            Int.random(in: 0...1) == 0 ? within10Add() : within10Subtract()
        case .within20NoCarry:
            Int.random(in: 0...1) == 0 ? within20NoCarryAdd() : within20NoBorrowSubtract()
        case .within20Carry:
            Int.random(in: 0...1) == 0 ? within20CarryAdd() : within20BorrowSubtract()
        }
    }

    /// 10 以内加法：a + b ≤ 10，结果 ≥ 2
    private func within10Add() -> MathProblem {
        let a = Int.random(in: 1...9)
        let b = Int.random(in: 1...(10 - a))
        return MathProblem(a: a, b: b, op: .add)
    }

    /// 10 以内减法：结果 ≥ 1
    private func within10Subtract() -> MathProblem {
        let a = Int.random(in: 2...10)
        let b = Int.random(in: 1..<a)
        return MathProblem(a: a, b: b, op: .subtract)
    }

    /// 20 以内不进位加法：个位之和 ≤ 9，结果 ≤ 20
    private func within20NoCarryAdd() -> MathProblem {
        let a = Int.random(in: 11...18)
        let maxB = min(8, 20 - a, 9 - a % 10)
        let b = Int.random(in: 1...max(1, maxB))
        return MathProblem(a: a, b: b, op: .add)
    }

    /// 20 以内不退位减法：减数 ≤ 被减数个位，结果 ≥ 10
    private func within20NoBorrowSubtract() -> MathProblem {
        let a = Int.random(in: 11...19)
        let b = Int.random(in: 1...a % 10)
        return MathProblem(a: a, b: b, op: .subtract)
    }

    /// 20 以内进位加法：两个一位数相加需要进位，和 ≥ 11
    private func within20CarryAdd() -> MathProblem {
        var a = Int.random(in: 3...9)
        var b = Int.random(in: 3...9)
        while a + b < 11 {
            a = Int.random(in: 3...9)
            b = Int.random(in: 3...9)
        }
        return MathProblem(a: a, b: b, op: .add)
    }

    /// 20 以内退位减法：减数大于被减数个位（需要借位），结果 ≥ 2
    private func within20BorrowSubtract() -> MathProblem {
        var a = Int.random(in: 11...18)
        var b = Int.random(in: 2...9)
        while b <= a % 10 || b > a - 2 {
            a = Int.random(in: 11...18)
            b = Int.random(in: 2...9)
        }
        return MathProblem(a: a, b: b, op: .subtract)
    }
}
