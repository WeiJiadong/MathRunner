import SwiftUI

@main
struct MathRunnerApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .defaultSize(width: 900, height: 660)
        .windowResizability(.contentSize)
    }
}
