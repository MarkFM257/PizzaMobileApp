//
//  SizeSelectorArc.swift
//  PizzaMobileApp
//

import SwiftUI

struct SizeSelectorArc: View {
    @Binding var selectedSize: PizzaSize
    let availableSizes: Set<PizzaSize>

    var body: some View {
        GeometryReader { proxy in
            let peach = PeachGeometry(in: proxy.size)
            let buttonRadius = AppLayout.SizeSelector.buttonDiameter / 2
            let sideX = buttonRadius + AppLayout.SizeSelector.buttonGap + buttonRadius
            let middleY = peach.center.y + peach.radius
            let sideButtonY = peach.center.y + sqrt(max(0, peach.radius * peach.radius - sideX * sideX))

            SizeButton(
                size: .S,
                isSelected: selectedSize == .S,
                isAvailable: availableSizes.contains(.S)
            ) {
                select(.S)
            }
            .position(x: peach.center.x - sideX, y: sideButtonY)

            let mDiameter = AppLayout.SizeSelector.buttonDiameter
            let bananaBottomY = middleY - mDiameter / 2 + mDiameter * 0.27
            Image("banana")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: AppLayout.SizeSelector.bananaWidth, height: AppLayout.SizeSelector.bananaHeight)
                .accessibilityHidden(true)
                .position(
                    x: peach.center.x,
                    y: bananaBottomY - AppLayout.SizeSelector.bananaHeight / 2
                )

            SizeButton(
                size: .M,
                isSelected: selectedSize == .M,
                isAvailable: availableSizes.contains(.M)
            ) {
                select(.M)
            }
            .position(x: peach.center.x, y: middleY)

            SizeButton(
                size: .L,
                isSelected: selectedSize == .L,
                isAvailable: availableSizes.contains(.L)
            ) {
                select(.L)
            }
            .position(x: peach.center.x + sideX, y: sideButtonY)
        }
        .ignoresSafeArea()
    }

    private func select(_ newSize: PizzaSize) {
        guard availableSizes.contains(newSize), newSize != selectedSize else { return }
        withAnimation(AppAnimation.pizzaSizeChange(from: selectedSize, to: newSize)) {
            selectedSize = newSize
        }
    }
}
