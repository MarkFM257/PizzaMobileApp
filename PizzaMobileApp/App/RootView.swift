//
//  RootView.swift
//  PizzaMobileApp
//

import SwiftUI

struct RootView: View {
    @State private var shell: AppShellViewModel
    @State private var catalogScene: CatalogSceneModel

    init(dependencies: AppDependencies) {
        _shell = State(initialValue: dependencies.makeAppShellViewModel())
        _catalogScene = State(initialValue: dependencies.makeCatalogSceneModel())
    }

    var body: some View {
        @Bindable var shell = shell

        return ZStack {
            CatalogContentView(
                screen: shell.catalogScreen,
                onRetry: shell.retry,
                onShowDetail: { pizzas in
                    CatalogSceneView(
                        pizzas: pizzas,
                        isPresented: shell.isSplashAnimationDone,
                        model: catalogScene
                    )
                }
            )
            .allowsHitTesting(shell.isSplashAnimationDone)
            .accessibilityHidden(!shell.isSplashAnimationDone)

            if !shell.isSplashAnimationDone {
                SplashView(
                    isReadyToDismiss: shell.isStartupReady,
                    onFinished: {
                        shell.splashDidFinish()
                    }
                )
                .zIndex(1)
            }
        }
        .task { await shell.start() }
        .connectivityAlert(
            connectivity: shell.connectivity,
            isPresented: $shell.showOfflineAlert,
            onRetry: shell.retry
        )
    }
}
