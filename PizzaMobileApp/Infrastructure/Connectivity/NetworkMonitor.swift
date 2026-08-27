//
//  NetworkMonitor.swift
//  PizzaMobileApp
//

import Foundation
import Network

protocol ConnectivityMonitoring: AnyObject, Sendable {
    @MainActor func startObserving(_ onChange: @escaping @MainActor (Bool) -> Void)
}

final class NetworkMonitor: ConnectivityMonitoring, @unchecked Sendable {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "PizzaMobileApp.NetworkMonitor")

    @MainActor
    func startObserving(_ onChange: @escaping @MainActor (Bool) -> Void) {
        monitor.pathUpdateHandler = { path in
            let online = path.status == .satisfied
            Task { @MainActor in
                onChange(online)
            }
        }
        monitor.start(queue: queue)
    }
}
