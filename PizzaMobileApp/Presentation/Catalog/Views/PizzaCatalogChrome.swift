//
//  PizzaCatalogChrome.swift
//  PizzaMobileApp
//

import SwiftUI

struct PizzaCatalogHeader: View {
    let pizzaName: String
    let hasAppeared: Bool

    var body: some View {
        HStack(alignment: .center) {
            CircleIconButton(systemName: AppIcon.back, action: {})
                .allowsHitTesting(false)
                .accessibilityHidden(true)
                .slideInHorizontally(
                    from: -AppLayout.Reveal.headerHorizontalShift,
                    hasAppeared: hasAppeared
                )

            Spacer()
            title
                .slideInVertically(
                    from: -AppLayout.Reveal.headerTitleVerticalShift,
                    hasAppeared: hasAppeared,
                    delay: AppLayout.Reveal.entranceTitleDelay,
                    animation: AppAnimation.titleEntrance
                )
            Spacer()

            CircleIconButton(systemName: AppIcon.favorite, action: {})
                .allowsHitTesting(false)
                .accessibilityHidden(true)
                .slideInHorizontally(
                    from: AppLayout.Reveal.headerHorizontalShift,
                    hasAppeared: hasAppeared
                )
        }
    }

    private var title: some View {
        VStack(spacing: AppLayout.Header.titleSpacing) {
            Text("Pizzas")
                .font(AppFont.regular(10))
                .foregroundColor(AppColor.text)
            Text(pizzaName)
                .font(AppFont.semibold(24))
                .tracking(-0.48)
                .foregroundColor(AppColor.active)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .contentTransition(.opacity)
                .animation(AppAnimation.nameSwap, value: pizzaName)
        }
    }
}

struct AccessiblePizzaCatalogHeader: View {
    let pizzaName: String

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                CircleIconButton(systemName: AppIcon.back, action: {})
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
                Spacer()
                CircleIconButton(systemName: AppIcon.favorite, action: {})
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }

            VStack(spacing: AppLayout.Header.titleSpacing) {
                Text("Pizzas")
                    .font(AppFont.regular(10))
                    .foregroundColor(AppColor.text)
                Text(pizzaName)
                    .font(AppFont.semibold(24))
                    .tracking(-0.48)
                    .foregroundColor(AppColor.active)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct PizzaCatalogDescription: View {
    let text: String

    var body: some View {
        Text(text)
            .font(AppFont.regular(AppLayout.Description.fontSize))
            .foregroundColor(AppColor.active)
            .lineSpacing(AppLayout.Description.lineSpacing)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AppLayout.Description.horizontalPadding)
            .padding(.top, AppLayout.Description.topPadding)
    }
}

struct PizzaCatalogBottomBar: View {
    @Binding var quantity: Int
    let totalPrice: Decimal?
    let isVertical: Bool

    var body: some View {
        Group {
            if isVertical {
                VStack(spacing: 16) { content }
            } else {
                HStack(spacing: AppLayout.BottomBar.spacing) { content }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        QuantityStepper(quantity: $quantity)
            .dynamicTypeSize(.xSmall ... .xxxLarge)

        Text(PriceFormatter.string(from: totalPrice))
            .font(AppFont.extrabold(24))
            .foregroundColor(AppColor.active)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .contentTransition(.numericText())

        if !isVertical {
            Spacer()
        }
        addLabel
    }

    private var addLabel: some View {
        Text("Add")
            .font(AppFont.extrabold(24))
            .foregroundColor(AppColor.bg)
            .frame(width: 83, height: 48)
            .background(AppColor.accent)
            .clipShape(Capsule())
            .accessibilityHidden(true)
    }
}
