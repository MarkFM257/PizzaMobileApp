//
//  BackgroundLayer.swift
//  PizzaMobileApp
//

import SwiftUI

struct BackgroundLayer: View {
    @State private var revealed = false

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                AppColor.bg
                let peach = PeachGeometry(in: proxy.size)
                Circle()
                    .fill(AppColor.highlight)
                    .frame(width: peach.radius * 2, height: peach.radius * 2)
                    .scaleEffect(revealed ? 1.0 : 2.6, anchor: .center)
                    .position(x: peach.center.x, y: peach.center.y)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            guard !revealed else { return }
            withAnimation(AppAnimation.backgroundReveal) {
                revealed = true
            }
        }
    }
}
