//
//  CatalogContentView.swift
//  PizzaMobileApp
//

import SwiftUI

struct CatalogContentView<Detail: View>: View {
    let screen: AppShellViewModel.Screen
    let onRetry: () async -> Void
    @ViewBuilder let onShowDetail: ([Pizza]) -> Detail

    var body: some View {
        switch screen {
        case .loading:
            ProgressView()
        case .empty:
            PlaceholderView(text: "No pizzas available.")
        case .content(let pizzas):
            onShowDetail(pizzas)
        case .failed(let message):
            ErrorPlaceholderView(message: message) {
                Task { await onRetry() }
            }
        }
    }
}

private struct PlaceholderView: View {
    let text: String

    var body: some View {
        ZStack {
            AppColor.highlight.ignoresSafeArea()
            Text(text)
                .font(AppFont.semibold(17))
                .foregroundColor(AppColor.active)
        }
    }
}

private struct ErrorPlaceholderView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        ZStack {
            AppColor.highlight.ignoresSafeArea()
            VStack(spacing: 16) {
                Text("Couldn't load pizzas")
                    .font(AppFont.bold(17))
                Text(message)
                    .font(AppFont.regular(15))
                    .foregroundColor(.black.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Button("Retry", action: retry)
                    .buttonStyle(.borderedProminent)
                    .tint(AppColor.accent)
            }
        }
    }
}
