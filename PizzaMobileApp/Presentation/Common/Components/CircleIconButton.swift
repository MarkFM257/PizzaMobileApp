//
//  CircleIconButton.swift
//  PizzaMobileApp
//

import SwiftUI

struct CircleIconButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppColor.active)
                .frame(width: AppLayout.Header.iconButtonSize, height: AppLayout.Header.iconButtonSize)
                .background(AppColor.bg)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
        }
    }
}
