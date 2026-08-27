//
//  PizzaCarouselView.swift
//  PizzaMobileApp
//

import SwiftUI

struct PizzaCarouselView: View {
    private struct ZoomGeometry {
        let scale: CGFloat
        let progress: CGFloat
        let shift: CGFloat
        let pizzaID: String?
    }

    let viewModel: PizzaDetailViewModel
    let imageStore: PizzaImageStore
    let pizzaSide: CGFloat
    let containerWidth: CGFloat
    let screenHeight: CGFloat
    let isZoomed: Bool
    let isPinching: Bool
    let pinchPizzaID: String?
    @Binding var pinchScale: CGFloat
    let hasAppeared: Bool
    let onZoomToggle: () -> Void

    var body: some View {
        let currentScale = PizzaZoomPolicy.interactiveScale(
            isZoomed: isZoomed,
            pinchScale: pinchScale
        )

        Color.clear
            .frame(width: pizzaSide, height: pizzaSide)
            .overlay {
                GeometryReader { placeholderGeo in
                    let placeholderCenterY = placeholderGeo.frame(in: .named(PizzaDetailView.rootCoordinateSpace)).midY
                    let zoomProgress = PizzaZoomPolicy.progress(for: currentScale)
                    let zoom = ZoomGeometry(
                        scale: currentScale,
                        progress: zoomProgress,
                        shift: zoomProgress * (screenHeight / 2 - placeholderCenterY),
                        pizzaID: pinchPizzaID ?? viewModel.centeredPizzaId
                    )

                    carousel(
                        side: pizzaSide,
                        containerWidth: containerWidth,
                        zoom: zoom
                    )
                        .frame(width: containerWidth, height: pizzaSide)
                        .frame(width: placeholderGeo.size.width, height: placeholderGeo.size.height)
                        .scaleEffect(hasAppeared ? 1 : 0.88)
                        .offset(y: hasAppeared ? 0 : 40)
                        .opacity(hasAppeared ? 1 : 0)
                        .animation(
                            AppAnimation.carouselReveal.delay(AppLayout.Reveal.carouselRevealDelay),
                            value: hasAppeared
                        )
                }
            }
            .contentShape(Rectangle())
    }

    private func carousel(
        side: CGFloat,
        containerWidth: CGFloat,
        zoom: ZoomGeometry
    ) -> some View {
        @Bindable var viewModel = viewModel
        let pageWidth = containerWidth * AppLayout.Carousel.pageWidthRatio
        let horizontalInset = max(0, (containerWidth - pageWidth) / 2)

        return ScrollViewReader { scrollProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(viewModel.pizzas) { pizza in
                        pizzaPage(
                            pizza: pizza,
                            side: side,
                            pageWidth: pageWidth,
                            zoom: zoom
                        )
                            .id(pizza.id)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $viewModel.centeredPizzaId)
            .contentMargins(.horizontal, horizontalInset, for: .scrollContent)
            .scrollDisabled(isZoomed || isPinching)
            .scrollClipDisabled()
            .overlay {
                let hideHint = isZoomed || isPinching || pinchScale != 1.0
                Image(AppIcon.zoomHint)
                    .resizable()
                    .scaledToFit()
                    .frame(width: AppLayout.Carousel.hintIconSize, height: AppLayout.Carousel.hintIconSize)
                    .opacity(hideHint ? 0 : 1)
                    .animation(AppAnimation.zoomHintFade, value: hideHint)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
            .onAppear {
                guard let id = viewModel.centeredPizzaId else { return }
                scrollProxy.scrollTo(id, anchor: .center)
            }
        }
    }

    @ViewBuilder
    private func pizzaPage(
        pizza: Pizza,
        side: CGFloat,
        pageWidth: CGFloat,
        zoom: ZoomGeometry
    ) -> some View {
        let isCurrent = pizza.id == viewModel.centeredPizzaId
        let isZoomTarget = pizza.id == zoom.pizzaID
        let selectedSizeScale = isCurrent
            ? AppLayout.PizzaSizing.scale(for: viewModel.selectedSize)
            : 1
        let interpolatedSizeScale = selectedSizeScale + (1 - selectedSizeScale) * zoom.progress
        let pizzaScale = isZoomTarget ? interpolatedSizeScale * zoom.scale : 1
        let zoomOpacity = isZoomTarget ? 1 : 1 - zoom.progress

        PizzaCarouselPage(
            pizza: pizza,
            viewModel: viewModel,
            imageStore: imageStore,
            side: side,
            pageWidth: pageWidth,
            scale: pizzaScale,
            verticalShift: isZoomTarget ? zoom.shift : 0,
            opacity: zoomOpacity,
            isCurrent: isCurrent,
            isZoomed: isZoomed,
            preferHighResolution: isZoomTarget && (isZoomed || isPinching),
            onZoomToggle: onZoomToggle
        )
    }
}
