import Foundation
import XCTest
@testable import PizzaMobileApp

final class PizzaViewModelTests: XCTestCase {
    @MainActor
    func testDetailStartsOnFigmaHeroAndResetsSelectionForNewPizza() {
        let first = TestFixtures.pizza(id: "midnight-harvest", name: "Midnight Harvest")
        let hero = TestFixtures.pizza()
        let third = TestFixtures.pizza(
            id: "shrimptastic",
            name: "Shrimptastic",
            defaultSize: .L
        )
        let viewModel = PizzaDetailViewModel(
            pizzas: [first, hero, third],
            pricing: CartPricingCalculator(),
            featuredPizzaID: hero.id
        )

        XCTAssertEqual(viewModel.centeredPizzaId, hero.id)
        viewModel.quantity = 4
        viewModel.selectedSize = .S
        viewModel.centeredPizzaId = third.id
        viewModel.centeredPizzaChanged()

        XCTAssertEqual(viewModel.selectedSize, .L)
        XCTAssertEqual(viewModel.quantity, 1)
    }

    @MainActor
    func testCatalogRefreshPreservesSelectionAndUsesFreshPrice() {
        let original = TestFixtures.pizza()
        let viewModel = PizzaDetailViewModel(
            pizzas: [original],
            pricing: CartPricingCalculator(),
            featuredPizzaID: original.id
        )
        viewModel.selectedSize = .L
        viewModel.quantity = 3
        let refreshed = TestFixtures.pizza(
            variants: [
                Variant(size: .S, price: 10),
                Variant(size: .M, price: 20),
                Variant(size: .L, price: 30)
            ]
        )

        viewModel.updateCatalog([refreshed])

        XCTAssertEqual(viewModel.centeredPizzaId, original.id)
        XCTAssertEqual(viewModel.selectedSize, .L)
        XCTAssertEqual(viewModel.quantity, 3)
        XCTAssertEqual(viewModel.totalPrice, 90)
        XCTAssertEqual(viewModel.catalogRevision, 1)
    }

    @MainActor
    func testCatalogRefreshFallsBackWhenCenteredPizzaDisappears() {
        let first = TestFixtures.pizza(id: "first")
        let removed = TestFixtures.pizza(id: "removed")
        let featured = TestFixtures.pizza(id: "featured", defaultSize: .S)
        let viewModel = PizzaDetailViewModel(
            pizzas: [first, removed],
            pricing: CartPricingCalculator(),
            featuredPizzaID: featured.id
        )
        viewModel.centeredPizzaId = removed.id
        viewModel.centeredPizzaChanged()
        viewModel.quantity = 5

        viewModel.updateCatalog([first, featured])

        XCTAssertEqual(viewModel.centeredPizzaId, featured.id)
        XCTAssertEqual(viewModel.selectedSize, .S)
        XCTAssertEqual(viewModel.quantity, 1)
    }

    @MainActor
    func testQuantityIsClampedToSupportedRange() {
        let pizza = TestFixtures.pizza()
        let viewModel = PizzaDetailViewModel(
            pizzas: [pizza],
            pricing: CartPricingCalculator(),
            featuredPizzaID: pizza.id
        )

        viewModel.quantity = 0
        XCTAssertEqual(viewModel.quantity, CartQuantity.minimum)

        viewModel.quantity = 100
        XCTAssertEqual(viewModel.quantity, CartQuantity.maximum)
    }

    @MainActor
    func testAssigningCurrentQuantityDoesNotReenterSetter() {
        let pizza = TestFixtures.pizza()
        let viewModel = PizzaDetailViewModel(
            pizzas: [pizza],
            pricing: CartPricingCalculator(),
            featuredPizzaID: pizza.id
        )

        viewModel.quantity = CartQuantity.minimum

        XCTAssertEqual(viewModel.quantity, CartQuantity.minimum)
    }

    @MainActor
    func testLatestCatalogRequestWins() async {
        let loader = SequencedCatalogPreparer()
        let viewModel = PizzaCatalogViewModel(prepareCatalog: loader)

        let first = Task { await viewModel.refresh() }
        try? await Task.sleep(for: .milliseconds(10))
        let second = Task { await viewModel.refresh() }
        await first.value
        await second.value

        XCTAssertEqual(viewModel.pizzas.map(\.id), ["new"])
        XCTAssertEqual(viewModel.state, .loaded)
    }
}

private actor SequencedCatalogPreparer: PreparePizzaCatalogUseCase {
    private var callCount = 0

    func loadInitial() async throws -> PreparedPizzaCatalog {
        try await nextCatalog()
    }

    func refresh() async throws -> PreparedPizzaCatalog {
        try await nextCatalog()
    }

    private func nextCatalog() async throws -> PreparedPizzaCatalog {
        callCount += 1
        let currentCall = callCount
        if currentCall == 1 {
            try await Task.sleep(for: .milliseconds(80))
            return prepared(id: "old")
        }

        try await Task.sleep(for: .milliseconds(5))
        return prepared(id: "new")
    }

    private func prepared(id: String) -> PreparedPizzaCatalog {
        PreparedPizzaCatalog(
            pizzas: [TestFixtures.pizza(id: id)],
            source: .remote
        )
    }
}
