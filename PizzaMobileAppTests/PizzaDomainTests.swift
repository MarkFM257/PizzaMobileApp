import XCTest
@testable import PizzaMobileApp

final class PizzaDomainTests: XCTestCase {
    func testAvailableSizesAreSorted() {
        let pizza = TestFixtures.pizza(variants: [
            Variant(size: .L, price: 22.50),
            Variant(size: .S, price: 15.50),
            Variant(size: .M, price: 17.99)
        ])

        XCTAssertEqual(pizza.availableSizes, [.S, .M, .L])
    }

    func testMissingSizeDoesNotBecomeZeroPrice() {
        let pizza = TestFixtures.pizza(
            defaultSize: .S,
            variants: [Variant(size: .S, price: 15.50)]
        )

        XCTAssertNil(pizza.price(for: .L))
    }

    func testTotalPriceUsesSelectedVariantAndQuantity() {
        let calculator = CartPricingCalculator()
        let pizza = TestFixtures.pizza()

        XCTAssertEqual(
            calculator.totalPrice(for: pizza, size: .L, quantity: 3),
            Decimal(string: "67.50")
        )
        XCTAssertNil(calculator.totalPrice(for: pizza, size: .M, quantity: 0))
    }
}
