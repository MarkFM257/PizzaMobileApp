//
//  SizeButton.swift
//  PizzaMobileApp
//

import SwiftUI

struct SizeButton: View {
    let size: PizzaSize
    let isSelected: Bool
    let isAvailable: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(size.rawValue)
                .font(AppFont.semibold(18))
                .foregroundColor(isSelected ? AppColor.bg : AppColor.active)
                .frame(
                    width: AppLayout.SizeSelector.buttonDiameter,
                    height: AppLayout.SizeSelector.buttonDiameter
                )
                .background(isSelected ? AppColor.active : AppColor.bg)
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(AppColor.bg, lineWidth: AppLayout.SizeSelector.buttonBorderWidth))
                .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
        }
        .scaleEffect(isSelected ? 1.14 : 1)
        .animation(AppAnimation.sizeButtonToggle, value: isSelected)
        .opacity(isAvailable ? 1 : 0.35)
        .disabled(!isAvailable)
        .accessibilityLabel("Size \(size.rawValue)")
        .accessibilityValue(isSelected ? "Selected" : "")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
