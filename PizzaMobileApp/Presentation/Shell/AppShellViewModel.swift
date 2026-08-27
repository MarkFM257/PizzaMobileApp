//
//  AppShellViewModel.swift
//  PizzaMobileApp
//

import Foundation

@MainActor
@Observable
final class AppShellViewModel {
    enum StartupState: Equatable {
        case preparing
        case ready
        case degraded
    }

    enum Screen: Equatable {
        case loading
        case empty
        case content([Pizza])
        case failed(String)
    }

    let connectivity: ConnectivityViewModel

    var showOfflineAlert: Bool = false
    private(set) var isSplashAnimationDone: Bool = false
    private(set) var startupState: StartupState = .preparing

    private let catalog: PizzaCatalogViewModel
    private let splashMaximumDuration: Duration
    private var refreshTask: Task<Void, Never>?
    private var splashDeadlineTask: Task<Void, Never>?

    init(
        catalog: PizzaCatalogViewModel,
        connectivity: ConnectivityViewModel,
        splashMaximumDuration: Duration = .seconds(4)
    ) {
        self.catalog = catalog
        self.connectivity = connectivity
        self.splashMaximumDuration = splashMaximumDuration
    }

    var catalogScreen: Screen {
        switch catalog.state {
        case .idle:
            return .loading
        case .loading:
            if catalog.pizzas.isEmpty, startupState == .degraded {
                return .failed("The connection is too slow. Please try again.")
            }
            return catalog.pizzas.isEmpty ? .loading : .content(catalog.pizzas)
        case .loaded:
            return catalog.pizzas.isEmpty ? .empty : .content(catalog.pizzas)
        case .failed(let message):
            return catalog.pizzas.isEmpty ? .failed(message) : .content(catalog.pizzas)
        }
    }

    var isStartupReady: Bool {
        startupState != .preparing
    }

    func start() async {
        connectivity.start()

        splashDeadlineTask?.cancel()
        splashDeadlineTask = Task { [weak self] in
            guard let self else { return }
            do {
                try await Task.sleep(for: splashMaximumDuration)
                try Task.checkCancellation()
            } catch {
                return
            }
            guard startupState == .preparing else { return }
            startupState = .degraded
        }

        await catalog.loadInitial()
        guard !Task.isCancelled else { return }
        splashDeadlineTask?.cancel()
        startupState = catalog.pizzas.isEmpty ? .degraded : .ready

        guard !Task.isCancelled, catalog.initialSource != .remote else { return }

        refreshTask?.cancel()
        refreshTask = Task { [weak self] in
            await self?.catalog.refresh()
        }
    }

    func retry() async {
        await catalog.refresh()
    }

    func splashDidFinish() {
        isSplashAnimationDone = true
    }

}
