//
//  PizzaCatalogStandardContent.swift
//  PizzaMobileApp
//

import SwiftUI

struct PizzaCatalogStandardContent: View {
    let viewModel: PizzaDetailViewModel
    let imageStore: PizzaImageStore
    let pizzaSide: CGFloat
    let containerWidth: CGFloat
    let screenHeight: CGFloat
    let zoomProgress: CGFloat
    let isZoomed: Bool
    let isPinching: Bool
    let pinchPizzaID: String?
    let hasAppeared: Bool
    @Binding var pinchScale: CGFloat
    let onZoomToggle: () -> Void

    var body: some View {
        @Bindable var viewModel = viewModel

        return VStack(spacing: 0) {
            PizzaCatalogHeader(
                pizzaName: viewModel.currentPizza?.name ?? "",
                hasAppeared: hasAppeared
            )
            .frame(maxWidth: .infinity)
            .padding(.horizontal, AppLayout.Header.horizontalPadding)
            .padding(.top, AppLayout.Header.topPadding)
            .offset(y: zoomProgress * AppLayout.Reveal.zoomedHeaderShift)
            .animation(AppAnimation.zoomContentSlide, value: isZoomed)
            .accessibilityHidden(isZoomed)

            Spacer(minLength: 0)
            carousel
                .offset(y: (1 - zoomProgress) * AppLayout.Carousel.verticalShift)
                .zIndex(100)
            Spacer(minLength: 0)
            Color.clear.frame(height: AppLayout.SizeSelector.placeholderHeight)

            PizzaCatalogDescription(text: viewModel.currentPizza?.description ?? "")
                .bottomReveal(
                    isZoomed: isZoomed,
                    zoomProgress: zoomProgress,
                    hasAppeared: hasAppeared,
                    zoomedOffset: AppLayout.Reveal.zoomedDescriptionShift,
                    entranceDelay: AppLayout.Reveal.entranceDescriptionDelay,
                    screenHeight: screenHeight
                )
                .accessibilityHidden(isZoomed)

            Spacer(minLength: 0)
            PizzaCatalogBottomBar(
                quantity: $viewModel.quantity,
                totalPrice: viewModel.totalPrice,
                isVertical: false
            )
            .padding(.horizontal, AppLayout.BottomBar.horizontalPadding)
            .padding(.bottom, AppLayout.BottomBar.bottomPadding)
            .bottomReveal(
                isZoomed: isZoomed,
                zoomProgress: zoomProgress,
                hasAppeared: hasAppeared,
                zoomedOffset: AppLayout.Reveal.zoomedBottomBarShift,
                entranceDelay: AppLayout.Reveal.entranceBottomBarDelay,
                screenHeight: screenHeight
            )
            .accessibilityHidden(isZoomed)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var carousel: some View {
        PizzaCarouselView(
            viewModel: viewModel,
            imageStore: imageStore,
            pizzaSide: pizzaSide,
            containerWidth: containerWidth,
            screenHeight: screenHeight,
            isZoomed: isZoomed,
            isPinching: isPinching,
            pinchPizzaID: pinchPizzaID,
            pinchScale: $pinchScale,
            hasAppeared: hasAppeared,
            onZoomToggle: onZoomToggle
        )
    }
}
