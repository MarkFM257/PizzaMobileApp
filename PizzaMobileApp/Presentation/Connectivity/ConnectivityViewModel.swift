//
//  ConnectivityViewModel.swift
//  PizzaMobileApp
//

import Foundation

@MainActor
@Observable
final class ConnectivityViewModel {
    private(set) var isOnline: Bool = true

    private let monitor: any ConnectivityMonitoring
    private var started: Bool = false

    init(monitor: any ConnectivityMonitoring) {
        self.monitor = monitor
    }

    func start() {
        guard !started else { return }
        started = true
        monitor.startObserving { [weak self] online in
            self?.isOnline = online
        }
    }
}
