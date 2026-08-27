//
//  RevealModifiers.swift
//  PizzaMobileApp
//

import SwiftUI

struct BottomRevealModifier: ViewModifier {
    let isZoomed: Bool
    let zoomProgress: CGFloat
    let hasAppeared: Bool
    let zoomedOffset: CGFloat
    let entranceDelay: Double
    let screenHeight: CGFloat

    func body(content: Content) -> some View {
        let offsetY: CGFloat = hasAppeared
            ? zoomProgress * zoomedOffset
            : screenHeight * AppLayout.Reveal.bottomShiftRatio
        let isHidden = !hasAppeared

        content
            .offset(y: offsetY)
            .opacity(isHidden ? 0 : 1)
            .animation(AppAnimation.zoomContentSlide, value: isZoomed)
            .animation(AppAnimation.entrance.delay(entranceDelay), value: hasAppeared)
    }
}

struct HorizontalSlideInModifier: ViewModifier {
    let from: CGFloat
    let hasAppeared: Bool

    func body(content: Content) -> some View {
        content
            .offset(x: hasAppeared ? 0 : from)
            .opacity(hasAppeared ? 1 : 0)
            .animation(AppAnimation.entrance, value: hasAppeared)
    }
}

struct VerticalSlideInModifier: ViewModifier {
    let from: CGFloat
    let hasAppeared: Bool
    let delay: Double
    let animation: Animation

    func body(content: Content) -> some View {
        content
            .offset(y: hasAppeared ? 0 : from)
            .opacity(hasAppeared ? 1 : 0)
            .animation(animation.delay(delay), value: hasAppeared)
    }
}

extension View {
    func bottomReveal(
        isZoomed: Bool,
        zoomProgress: CGFloat,
        hasAppeared: Bool,
        zoomedOffset: CGFloat,
        entranceDelay: Double = 0,
        screenHeight: CGFloat
    ) -> some View {
        modifier(BottomRevealModifier(
            isZoomed: isZoomed,
            zoomProgress: zoomProgress,
            hasAppeared: hasAppeared,
            zoomedOffset: zoomedOffset,
            entranceDelay: entranceDelay,
            screenHeight: screenHeight
        ))
    }

    func slideInHorizontally(from: CGFloat, hasAppeared: Bool) -> some View {
        modifier(HorizontalSlideInModifier(from: from, hasAppeared: hasAppeared))
    }

    func slideInVertically(
        from: CGFloat,
        hasAppeared: Bool,
        delay: Double = 0,
        animation: Animation = AppAnimation.entrance
    ) -> some View {
        modifier(VerticalSlideInModifier(
            from: from,
            hasAppeared: hasAppeared,
            delay: delay,
            animation: animation
        ))
    }
}
