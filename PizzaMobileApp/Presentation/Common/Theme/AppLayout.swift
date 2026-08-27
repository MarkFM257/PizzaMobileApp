//
//  AppLayout.swift
//  PizzaMobileApp
//

import CoreGraphics

enum AppLayout {
    enum Header {
        static let horizontalPadding: CGFloat = 20
        static let topPadding: CGFloat = 8
        static let titleSpacing: CGFloat = 2
        static let iconButtonSize: CGFloat = 48
    }

    enum Background {
        static let peachWidthRatio: CGFloat = 1.55
        static let whiteSemicircleHeightRatio: CGFloat = 2.8
    }

    enum Carousel {
        static let pizzaWidthRatio: CGFloat = 0.82
        static let pizzaHeightRatio: CGFloat = 0.45
        static let pageWidthRatio: CGFloat = 0.5
        static let neighborScale: CGFloat = 0.22
        static let neighborOpacity: CGFloat = 0.85
        static let hintIconSize: CGFloat = 200
        static let verticalShift: CGFloat = -36
    }

    enum Zoom {
        static let scale: CGFloat = 3.2
        static let maximumInteractiveScale: CGFloat = 3.4
        static let zoomInThreshold: CGFloat = 1.45
        static let zoomOutThreshold: CGFloat = 2.45
    }

    enum SizeSelector {
        static let buttonGap: CGFloat = 50
        static let buttonDiameter: CGFloat = 48
        static let buttonBorderWidth: CGFloat = 2
        static let placeholderHeight: CGFloat = 90
        static let bananaWidth: CGFloat = 97
        static let bananaHeight: CGFloat = 63
    }

    enum Description {
        static let horizontalPadding: CGFloat = 40
        static let topPadding: CGFloat = 8
        static let fontSize: CGFloat = 14
        static let lineSpacing: CGFloat = 4
    }

    enum BottomBar {
        static let horizontalPadding: CGFloat = 24
        static let bottomPadding: CGFloat = 8
        static let spacing: CGFloat = 14
    }

    enum Reveal {
        static let headerHorizontalShift: CGFloat = 200
        static let headerTitleVerticalShift: CGFloat = 24
        static let bottomShiftRatio: CGFloat = 0.5
        static let zoomedHeaderShift: CGFloat = -160
        static let zoomedDescriptionShift: CGFloat = 500
        static let zoomedBottomBarShift: CGFloat = 500
        static let zoomedSizeSelectorShift: CGFloat = 550
        static let entranceTitleDelay: Double = 0.02
        static let entranceDescriptionDelay: Double = 0.02
        static let entranceBottomBarDelay: Double = 0.04
        static let carouselRevealDelay: Double = 0.03
    }

    enum PizzaSizing {
        static func scale(for size: PizzaSize) -> CGFloat {
            switch size {
            case .S: return 0.64
            case .M: return 0.795
            case .L: return 0.89
            }
        }
    }
}
