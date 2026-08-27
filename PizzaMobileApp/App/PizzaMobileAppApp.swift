import SwiftUI

@main
struct PizzaMobileAppApp: App {
    private let dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            RootView(dependencies: dependencies)
        }
    }
}
