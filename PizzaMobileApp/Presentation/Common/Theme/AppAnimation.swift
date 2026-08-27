//
//  AppAnimation.swift
//  PizzaMobileApp
//

import SwiftUI

enum AppAnimation {
    static let zoom: Animation = .spring(response: 0.42, dampingFraction: 0.90)
    static let zoomContentSlide: Animation = .easeInOut(duration: 0.28)
    static let entrance: Animation = .spring(response: 0.44, dampingFraction: 0.58)
    static let sizeChange: Animation = .spring(response: 0.45, dampingFraction: 0.65)
    static let sizeGrow: Animation = .spring(response: 0.34, dampingFraction: 0.30)
    static let sizeShrink: Animation = .spring(response: 0.30, dampingFraction: 0.34)

    static func pizzaSizeChange(from oldSize: PizzaSize, to newSize: PizzaSize) -> Animation {
        newSize.ordinal > oldSize.ordinal ? sizeGrow : sizeShrink
    }
    static let pageSnap: Animation = .spring(response: 0.52, dampingFraction: 0.68)
    static let sizeButtonToggle: Animation = .spring(response: 0.35, dampingFraction: 0.65)
    static let imageReveal: Animation = .easeOut(duration: 0.35)
    static let carouselReveal: Animation = .spring(response: 0.48, dampingFraction: 0.55)
    static let backgroundReveal: Animation = .smooth(duration: 0.7, extraBounce: 0.1)
    static let nameSwap: Animation = .spring(response: 0.45, dampingFraction: 0.72)
    static let titleEntrance: Animation = .spring(response: 0.40, dampingFraction: 0.62)
    static let zoomHintFade: Animation = .easeInOut(duration: 0.3)
}
