//
//  QuantityStepper.swift
//  PizzaMobileApp
//

import SwiftUI

struct QuantityStepper: View {
    @Binding var quantity: Int
    var maximumQuantity = CartQuantity.maximum

    private let totalWidth: CGFloat = 143
    private let totalHeight: CGFloat = 48
    private let circleSize: CGFloat = 48
    private let peachHeight: CGFloat = 48
    private let iconLength: CGFloat = 14
    private let iconThickness: CGFloat = 1.5

    var body: some View {
        ZStack {
            Capsule()
                .fill(AppColor.highlight)
                .frame(width: totalWidth, height: peachHeight)

            HStack(spacing: 0) {
                stepperButton(isPlus: false) {
                    guard quantity > CartQuantity.minimum else { return }
                    withAnimation(AppAnimation.sizeShrink) { quantity -= 1 }
                }
                .disabled(quantity <= CartQuantity.minimum)
                .accessibilityLabel("Decrease quantity")
                Spacer(minLength: 0)
                Text("\(quantity)")
                    .font(AppFont.extrabold(24))
                    .foregroundColor(AppColor.active)
                    .contentTransition(.numericText())
                Spacer(minLength: 0)
                stepperButton(isPlus: true) {
                    guard quantity < maximumQuantity else { return }
                    withAnimation(AppAnimation.sizeGrow) { quantity += 1 }
                }
                .disabled(quantity >= maximumQuantity)
                .accessibilityLabel("Increase quantity")
            }
            .frame(width: totalWidth, height: totalHeight)

        }
        .frame(width: totalWidth, height: totalHeight)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Quantity \(quantity)")
    }

    private func stepperButton(isPlus: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(AppColor.bg)
                    .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                Capsule()
                    .fill(AppColor.active)
                    .frame(width: iconLength, height: iconThickness)
                if isPlus {
                    Capsule()
                        .fill(AppColor.active)
                        .frame(width: iconThickness, height: iconLength)
                }
            }
            .frame(width: circleSize, height: circleSize)
        }
        .buttonStyle(.plain)
    }
}
