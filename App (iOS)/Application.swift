import SwiftUI

@main
struct App_iOS: App {
    init() {
      UITabBar.appearance().scrollEdgeAppearance = .init()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
