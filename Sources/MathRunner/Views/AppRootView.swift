import SwiftUI
import MathCore

struct AppRootView: View {
    @State private var appModel = AppViewModel()

    var body: some View {
        switch appModel.screen {
        case .menu:
            MenuView(appModel: appModel)
        case .dressUp:
            DressUpView(appModel: appModel)
        case .game(let level):
            GameView(appModel: appModel, level: level)
                .id(level)
        }
    }
}
