//
//  SplashView.swift
//  PizzaMobileApp
//

import SwiftUI

struct SplashView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var currentSlice = 0
    @State private var pizzaScale: CGFloat = 1
    @State private var pizzaOpacity = 1.0
    @State private var backgroundColor = AppColor.bg
    @State private var isAssemblyComplete = false
    @State private var isFinishing = false
    @State private var didFinish = false

    let isReadyToDismiss: Bool
    let onFinished: () -> Void

    private static let fadeOutDuration = 0.085
    private static let outroDuration = 0.14
    private let totalSlices = 8
    private let frameInterval = 0.035

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            GeometryReader { proxy in
                let side = proxy.size.width * 0.72

                Group {
                    if currentSlice > 0 {
                        Image("slice_\(currentSlice)")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: side, height: side)
                            .scaleEffect(pizzaScale)
                            .opacity(pizzaOpacity)
                    }
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Loading pizzas")
        .task { await assemblePizza() }
        .task(id: isAssemblyComplete && isReadyToDismiss) {
            guard isAssemblyComplete, isReadyToDismiss else { return }
            await runOutro()
        }
    }

    @MainActor
    private func assemblePizza() async {
        if reduceMotion {
            currentSlice = totalSlices
            isAssemblyComplete = true
            return
        }

        do {
            try await Task.sleep(for: .milliseconds(20))
            for slice in 1...totalSlices {
                try Task.checkCancellation()
                currentSlice = slice
                if slice < totalSlices {
                    try await Task.sleep(for: .seconds(frameInterval))
                }
            }
            isAssemblyComplete = true
        } catch {
            return
        }
    }

    @MainActor
    private func runOutro() async {
        guard !isFinishing, !didFinish else { return }
        isFinishing = true

        let duration = reduceMotion ? 0.05 : Self.outroDuration
        let fadeDuration = reduceMotion ? duration : Self.fadeOutDuration

        withAnimation(.linear(duration: fadeDuration)) {
            pizzaOpacity = 0
        }

        withAnimation(.easeIn(duration: duration)) {
            pizzaScale = reduceMotion ? 1 : 0.03
            backgroundColor = AppColor.highlight
        }

        do {
            if duration > 0 {
                try await Task.sleep(for: .seconds(duration))
            }
            try Task.checkCancellation()
        } catch {
            return
        }

        guard !didFinish else { return }
        didFinish = true
        onFinished()
    }
}

#Preview {
    SplashView(isReadyToDismiss: true, onFinished: {})
}
