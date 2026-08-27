import XCTest
@testable import PizzaMobileApp

final class PizzaZoomPolicyTests: XCTestCase {
    func testZoomInThreshold() {
        XCTAssertFalse(
            PizzaZoomPolicy.targetZoomState(isZoomed: false, magnification: 1.44)
        )
        XCTAssertTrue(
            PizzaZoomPolicy.targetZoomState(isZoomed: false, magnification: 1.45)
        )
    }

    func testZoomOutThreshold() {
        XCTAssertTrue(
            PizzaZoomPolicy.targetZoomState(isZoomed: true, magnification: 0.80)
        )
        XCTAssertFalse(
            PizzaZoomPolicy.targetZoomState(isZoomed: true, magnification: 0.75)
        )
    }

    func testInteractiveScaleIsClamped() {
        XCTAssertEqual(
            PizzaZoomPolicy.interactiveScale(isZoomed: false, pinchScale: 0.2),
            1
        )
        XCTAssertEqual(
            PizzaZoomPolicy.interactiveScale(isZoomed: true, pinchScale: 2),
            AppLayout.Zoom.maximumInteractiveScale
        )
    }
}
