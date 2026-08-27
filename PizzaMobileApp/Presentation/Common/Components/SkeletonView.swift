//
//  SkeletonView.swift
//  PizzaMobileApp
//

import SwiftUI

struct SkeletonView: View {
    var cornerRadius: CGFloat = 16

    @State private var isPulsing: Bool = false

    private let baseColor = Color.black.opacity(0.07)
    private let pulseColor = Color.black.opacity(0.14)

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(isPulsing ? baseColor : pulseColor)
            .animation(
                .easeInOut(duration: 1.1).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear { isPulsing = true }
    }
}

extension SkeletonView {
    static var circle: some View {
        SkeletonView()
            .clipShape(Circle())
    }
}

#Preview {
    VStack(spacing: 20) {
        SkeletonView()
            .frame(height: 60)
        SkeletonView.circle
            .frame(width: 200, height: 200)
    }
    .padding()
    .background(AppColor.highlight)
}
