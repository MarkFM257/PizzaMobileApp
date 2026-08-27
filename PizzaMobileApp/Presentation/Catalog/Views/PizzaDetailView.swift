//
//  PizzaDetailView.swift
//  PizzaMobileApp
//

import SwiftUI

struct PizzaDetailView: View {
    private struct ImageLoadID: Hashable {
        let catalogRevision: Int
        let centeredPizzaID: String?
        let isPresented: Bool
    }

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var isZoomed: Bool = false
    @State private var hasAppeared: Bool = false
    @State private var pinchScale: CGFloat = 1.0
    @GestureState private var isPinching = false
    @State private var pinchPizzaID: String?

    let viewModel: PizzaDetailViewModel
    let imageStore: PizzaImageStore
    let isPresented: Bool

    init(
        viewModel: PizzaDetailViewModel,
        imageStore: PizzaImageStore,
        isPresented: Bool = true
    ) {
        self.viewModel = viewModel
        self.imageStore = imageStore
        self.isPresented = isPresented
        _hasAppeared = State(initialValue: isPresented)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        return GeometryReader { proxy in
            let pizzaSide = min(
                proxy.size.width * AppLayout.Carousel.pizzaWidthRatio,
                proxy.size.height * AppLayout.Carousel.pizzaHeightRatio
            )
            let containerWidth = proxy.size.width
            let screenHeight = proxy.size.height

            let currentScale = PizzaZoomPolicy.interactiveScale(
                isZoomed: isZoomed,
                pinchScale: pinchScale
            )
            let zoomProgress = PizzaZoomPolicy.progress(for: currentScale)

            Group {
                if dynamicTypeSize.isAccessibilitySize {
                    accessibilityLayout(
                        pizzaSide: min(pizzaSide, 280),
                        containerWidth: containerWidth,
                        screenHeight: screenHeight
                    )
                } else {
                    standardLayout(
                        pizzaSide: pizzaSide,
                        containerWidth: containerWidth,
                        screenHeight: screenHeight,
                        zoomProgress: zoomProgress
                    )
                }
            }
            .coordinateSpace(name: Self.rootCoordinateSpace)
            .transaction { transaction in
                if reduceMotion {
                    transaction.animation = nil
                }
            }
        }
        .simultaneousGesture(pinchGesture)
        .task(id: ImageLoadID(
            catalogRevision: viewModel.catalogRevision,
            centeredPizzaID: viewModel.centeredPizzaId,
            isPresented: isPresented
        )) {
            guard isPresented else { return }
            guard let pizza = viewModel.currentPizza else { return }
            viewModel.centeredPizzaChanged()
            await imageStore.loadImages(around: pizza, in: viewModel.pizzas)
        }
        .onChange(of: isPresented, initial: true) { _, isPresented in
            guard isPresented, !hasAppeared else { return }
            hasAppeared = true
        }
    }

    // MARK: - Layouts

    private func standardLayout(
        pizzaSide: CGFloat,
        containerWidth: CGFloat,
        screenHeight: CGFloat,
        zoomProgress: CGFloat
    ) -> some View {
        @Bindable var viewModel = viewModel

        return ZStack {
            BackgroundLayer()

            PizzaCatalogStandardContent(
                viewModel: viewModel,
                imageStore: imageStore,
                pizzaSide: pizzaSide,
                containerWidth: containerWidth,
                screenHeight: screenHeight,
                zoomProgress: zoomProgress,
                isZoomed: isZoomed,
                isPinching: isPinching,
                pinchPizzaID: pinchPizzaID,
                hasAppeared: hasAppeared,
                pinchScale: $pinchScale,
                onZoomToggle: toggleZoom
            )

            SizeSelectorArc(
                selectedSize: $viewModel.selectedSize,
                availableSizes: Set(viewModel.availableSizes)
            )
            .bottomReveal(
                isZoomed: isZoomed,
                zoomProgress: zoomProgress,
                hasAppeared: hasAppeared,
                zoomedOffset: AppLayout.Reveal.zoomedSizeSelectorShift,
                screenHeight: screenHeight
            )
            .allowsHitTesting(!isZoomed && hasAppeared)
            .accessibilityHidden(isZoomed)
            .zIndex(50)
        }
    }

    private func accessibilityLayout(
        pizzaSide: CGFloat,
        containerWidth: CGFloat,
        screenHeight: CGFloat
    ) -> some View {
        ZStack {
            BackgroundLayer()

            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 24) {
                    accessibleHeader
                        .padding(.horizontal, AppLayout.Header.horizontalPadding)
                        .padding(.top, AppLayout.Header.topPadding)
                        .opacity(isZoomed ? 0 : 1)
                        .accessibilityHidden(isZoomed)

                    carousel(
                        pizzaSide: pizzaSide,
                        containerWidth: containerWidth,
                        screenHeight: screenHeight
                    )
                    .zIndex(100)

                    accessibleSizeSelector
                        .opacity(isZoomed ? 0 : 1)
                        .accessibilityHidden(isZoomed)

                    description
                        .padding(.top, 0)
                        .opacity(isZoomed ? 0 : 1)
                        .accessibilityHidden(isZoomed)

                    accessibleBottomBar
                        .padding(.horizontal, AppLayout.BottomBar.horizontalPadding)
                        .padding(.bottom, 24)
                        .opacity(isZoomed ? 0 : 1)
                        .accessibilityHidden(isZoomed)
                }
                .frame(maxWidth: .infinity)
            }
            .scrollDisabled(isZoomed)
        }
    }

    private func carousel(
        pizzaSide: CGFloat,
        containerWidth: CGFloat,
        screenHeight: CGFloat
    ) -> some View {
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
            onZoomToggle: toggleZoom
        )
    }

    private var accessibleSizeSelector: some View {
        @Bindable var viewModel = viewModel

        return HStack(spacing: 24) {
            ForEach(PizzaSize.allCases) { size in
                SizeButton(
                    size: size,
                    isSelected: viewModel.selectedSize == size,
                    isAvailable: viewModel.availableSizes.contains(size)
                ) {
                    guard viewModel.availableSizes.contains(size) else { return }
                    withAnimation(AppAnimation.pizzaSizeChange(from: viewModel.selectedSize, to: size)) {
                        viewModel.selectedSize = size
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .dynamicTypeSize(.xSmall ... .xxxLarge)
    }

    private var accessibleBottomBar: some View {
        @Bindable var viewModel = viewModel

        return PizzaCatalogBottomBar(
            quantity: $viewModel.quantity,
            totalPrice: viewModel.totalPrice,
            isVertical: true
        )
    }

    private var accessibleHeader: some View {
        AccessiblePizzaCatalogHeader(pizzaName: viewModel.currentPizza?.name ?? "")
    }

    private var description: some View {
        PizzaCatalogDescription(text: viewModel.currentPizza?.description ?? "")
    }

    // MARK: - Constants

    static let rootCoordinateSpace = "pizzaRoot"
}

// MARK: - Zoom handling

private extension PizzaDetailView {
    var pinchGesture: some Gesture {
        MagnifyGesture(minimumScaleDelta: 0.01)
            .updating($isPinching) { _, isPinching, _ in
                isPinching = true
            }
            .onChanged { value in
                guard let pizzaID = pinchPizzaID ?? viewModel.centeredPizzaId,
                      imageStore.phase(for: pizzaID) == .loaded else {
                    pinchScale = 1
                    return
                }

                if pinchPizzaID == nil {
                    pinchPizzaID = pizzaID
                }

                let committedScale = PizzaZoomPolicy.committedScale(isZoomed: isZoomed)
                let clampedScale = PizzaZoomPolicy.clamped(
                    committedScale * value.magnification
                )
                pinchScale = clampedScale / committedScale
            }
            .onEnded { value in
                defer { pinchPizzaID = nil }

                guard let pizzaID = pinchPizzaID ?? viewModel.centeredPizzaId,
                      imageStore.phase(for: pizzaID) == .loaded else {
                    pinchScale = 1
                    return
                }
                endPinch(value.magnification)
            }
    }

    func toggleZoom() {
        withAnimation(reduceMotion ? nil : AppAnimation.zoom) {
            isZoomed.toggle()
        }
    }

    func endPinch(_ magnification: CGFloat) {
        let wantsZoom = PizzaZoomPolicy.targetZoomState(
            isZoomed: isZoomed,
            magnification: magnification
        )

        withAnimation(reduceMotion ? nil : AppAnimation.zoom) {
            pinchScale = 1.0
            if wantsZoom != isZoomed {
                isZoomed = wantsZoom
            }
        }
    }
}

#if DEBUG
#Preview {
    let deps = AppDependencies()
    PizzaDetailView(
        viewModel: deps.makeDetailViewModel(pizzas: Pizza.previewSet),
        imageStore: deps.makeImageStore()
    )
}
#endif
