//
//  PizzaCarouselPage.swift
//  PizzaMobileApp
//

import SwiftUI

struct PizzaCarouselPage: View {
    let pizza: Pizza
    let viewModel: PizzaDetailViewModel
    let imageStore: PizzaImageStore
    let side: CGFloat
    let pageWidth: CGFloat
    let scale: CGFloat
    let verticalShift: CGFloat
    let opacity: Double
    let isCurrent: Bool
    let isZoomed: Bool
    let preferHighResolution: Bool
    let onZoomToggle: () -> Void

    var body: some View {
        pizzaImage
            .scaleEffect(scale)
            .offset(y: verticalShift)
            .opacity(opacity)
            .animation(AppAnimation.zoom, value: isZoomed)
            .frame(width: pageWidth, height: side)
            .scrollTransition(axis: .horizontal) { content, phase in
                let visibilityProgress = 1 - min(1, abs(phase.value))
                let scale = AppLayout.Carousel.neighborScale
                    + (1 - AppLayout.Carousel.neighborScale) * visibilityProgress
                let opacity = AppLayout.Carousel.neighborOpacity
                    + (1 - AppLayout.Carousel.neighborOpacity) * visibilityProgress
                return content
                    .scaleEffect(scale)
                    .opacity(opacity)
            }
            .contentShape(Rectangle())
            .accessibilityElement(children: imagePhase == .failed ? .contain : .ignore)
            .accessibilityLabel(pizza.name)
            .accessibilityValue(isCurrent ? (isZoomed ? "Zoomed" : "Selected pizza") : "")
            .accessibilityHint(accessibilityHint)
            .accessibilityAddTraits(isCurrent ? .isSelected : [])
            .accessibilityHidden(isZoomed && !isCurrent)
            .accessibilityAction {
                performSelection()
            }
            .onTapGesture(perform: performSelection)
    }

    private var imagePhase: PizzaImageStore.Phase {
        imageStore.phase(for: pizza.id)
    }

    private var accessibilityHint: String {
        guard isCurrent else { return "Double-tap to center this pizza." }
        return isZoomed
            ? "Double-tap to return to the catalog."
            : "Double-tap to zoom. Pinch to inspect ingredients."
    }

    private var pizzaImage: some View {
        ZStack {
            SkeletonView.circle
                .padding(side * 0.06)
                .opacity(imagePhase == .loaded ? 0 : 1)
                .allowsHitTesting(false)

            if let uiImage = imageStore.image(
                for: pizza.id,
                preferHighResolution: preferHighResolution
            ) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .transition(.opacity)
            }

            if imagePhase == .failed {
                retryButton
            }
        }
        .frame(width: side, height: side)
    }

    private var retryButton: some View {
        Button {
            Task { await imageStore.retryCatalogImage(for: pizza) }
        } label: {
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppColor.active)
                .frame(width: 48, height: 48)
                .background(AppColor.bg.opacity(0.9))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Retry loading \(pizza.name) image")
    }

    private func performSelection() {
        if isZoomed {
            onZoomToggle()
            return
        }

        if isCurrent {
            guard imagePhase == .loaded else { return }
            onZoomToggle()
        } else {
            withAnimation(AppAnimation.pageSnap) {
                viewModel.centeredPizzaId = pizza.id
            }
        }
    }
}
