//
//  PeachGeometry.swift
//  PizzaMobileApp
//

import CoreGraphics

struct PeachGeometry {
    let center: CGPoint
    let radius: CGFloat

    init(in size: CGSize) {
        let diameter = size.width * AppLayout.Background.peachWidthRatio
        self.radius = diameter / 2
        let bottomY = size.height - size.height / AppLayout.Background.whiteSemicircleHeightRatio
        self.center = CGPoint(x: size.width / 2, y: bottomY - radius)
    }
}
