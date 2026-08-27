//
//  PizzaZoomPolicy.swift
//  PizzaMobileApp
//

import CoreGraphics

enum PizzaZoomPolicy {
    static func committedScale(isZoomed: Bool) -> CGFloat {
        isZoomed ? AppLayout.Zoom.scale : 1
    }

    static func interactiveScale(
        isZoomed: Bool,
        pinchScale: CGFloat
    ) -> CGFloat {
        clamped(committedScale(isZoomed: isZoomed) * pinchScale)
    }

    static func progress(for scale: CGFloat) -> CGFloat {
        max(0, min(1, (scale - 1) / (AppLayout.Zoom.scale - 1)))
    }

    static func targetZoomState(
        isZoomed: Bool,
        magnification: CGFloat
    ) -> Bool {
        let finalScale = clamped(
            committedScale(isZoomed: isZoomed) * magnification
        )
        return isZoomed
            ? finalScale >= AppLayout.Zoom.zoomOutThreshold
            : finalScale >= AppLayout.Zoom.zoomInThreshold
    }

    static func clamped(_ scale: CGFloat) -> CGFloat {
        min(AppLayout.Zoom.maximumInteractiveScale, max(1, scale))
    }
}
