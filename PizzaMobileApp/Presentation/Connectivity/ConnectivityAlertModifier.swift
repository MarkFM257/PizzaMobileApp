//
//  ConnectivityAlertModifier.swift
//  PizzaMobileApp
//

import SwiftUI

struct ConnectivityAlertModifier: ViewModifier {
    let connectivity: ConnectivityViewModel
    @Binding var isPresented: Bool
    let onRetry: () async -> Void

    func body(content: Content) -> some View {
        content
            .onChange(of: connectivity.isOnline, initial: true) { _, online in
                if !online { isPresented = true }
            }
            .alert("No Internet Connection", isPresented: $isPresented) {
                Button("OK", role: .cancel) {}
                Button("Retry") {
                    Task { await onRetry() }
                }
            } message: {
                Text("Please connect to the internet and try again.")
            }
    }
}

extension View {
    func connectivityAlert(
        connectivity: ConnectivityViewModel,
        isPresented: Binding<Bool>,
        onRetry: @escaping () async -> Void
    ) -> some View {
        modifier(ConnectivityAlertModifier(
            connectivity: connectivity,
            isPresented: isPresented,
            onRetry: onRetry
        ))
    }
}
