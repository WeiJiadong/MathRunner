import Foundation

/// 运算类型
public enum MathOperator: String, CaseIterable, Sendable {
    case add = "+"
    case subtract = "-"

    public func apply(_ a: Int, _ b: Int) -> Int {
        self == .add ? a + b : a - b
    }
}

/// 一道 20 以内加减法算式
public struct MathProblem: Equatable, Sendable {
    public let a: Int
    public let b: Int
    public let op: MathOperator

    public var answer: Int { op.apply(a, b) }
    public var text: String { "\(a) \(op.rawValue) \(b)" }

    public init(a: Int, b: Int, op: MathOperator) {
        self.a = a
        self.b = b
        self.op = op
    }
}
