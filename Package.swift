// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MathRunner",
    platforms: [.macOS(.v15)],
    targets: [
        .target(name: "MathCore", path: "Sources/MathCore"),
        .executableTarget(
            name: "MathRunner",
            dependencies: ["MathCore"],
            path: "Sources/MathRunner"
        ),
        // CLT 工具链无 XCTest/Swift Testing，测试用独立可执行目标跑。
        .executableTarget(
            name: "MathRunnerTests",
            dependencies: ["MathCore"],
            path: "Tests/MathRunnerTests"
        ),
    ]
)
