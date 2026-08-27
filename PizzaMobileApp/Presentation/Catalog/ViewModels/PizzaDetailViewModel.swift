//
//  PizzaDetailViewModel.swift
//  PizzaMobileApp
//

import Foundation

@MainActor
@Observable
final class PizzaDetailViewModel {
    private(set) var pizzas: [Pizza]
    private(set) var catalogRevision = 0

    var centeredPizzaId: String?
    var selectedSize: PizzaSize
    var quantity: Int = CartQuantity.minimum {
        didSet {
            let clampedQuantity = CartQuantity.clamped(quantity)
            guard quantity != clampedQuantity else { return }
            quantity = clampedQuantity
        }
    }

    private let pricing: any CartPricingUseCase
    private let featuredPizzaID: String
    private var lastCenteredPizzaID: String?

    init(
        pizzas: [Pizza],
        pricing: any CartPricingUseCase,
        featuredPizzaID: String
    ) {
        self.pizzas = pizzas
        self.pricing = pricing
        self.featuredPizzaID = featuredPizzaID
        let initialPizza = Self.initialPizza(in: pizzas, featuredPizzaID: featuredPizzaID)
        self.centeredPizzaId = initialPizza?.id
        self.selectedSize = initialPizza?.defaultSize ?? .M
    }

    var currentPizza: Pizza? {
        pizzas.first { $0.id == centeredPizzaId } ?? pizzas.first
    }

    var availableSizes: [PizzaSize] {
        currentPizza?.availableSizes ?? []
    }

    var totalPrice: Decimal? {
        guard let pizza = currentPizza else { return nil }
        return pricing.totalPrice(for: pizza, size: selectedSize, quantity: quantity)
    }

    func centeredPizzaChanged() {
        guard let pizza = currentPizza, pizza.id != lastCenteredPizzaID else { return }
        lastCenteredPizzaID = pizza.id
        selectedSize = pizza.defaultSize
        quantity = CartQuantity.minimum
    }

    func updateCatalog(_ pizzas: [Pizza]) {
        guard self.pizzas != pizzas else { return }

        let previousCenteredID = centeredPizzaId
        self.pizzas = pizzas
        let nextPizza = pizzas.first { $0.id == previousCenteredID }
            ?? Self.initialPizza(in: pizzas, featuredPizzaID: featuredPizzaID)
        centeredPizzaId = nextPizza?.id

        if nextPizza?.id == previousCenteredID,
           let nextPizza,
           !nextPizza.availableSizes.contains(selectedSize) {
            selectedSize = nextPizza.defaultSize
        } else if nextPizza?.id != previousCenteredID {
            lastCenteredPizzaID = nil
            centeredPizzaChanged()
        }

        catalogRevision += 1
    }

    private static func initialPizza(
        in pizzas: [Pizza],
        featuredPizzaID: String
    ) -> Pizza? {
        pizzas.first { $0.id == featuredPizzaID } ?? pizzas.first
    }
}
