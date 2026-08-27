//
//  CartPricingUseCase.swift
//  PizzaMobileApp
//

import Foundation

enum CartQuantity {
    static let minimum = 1
    static let maximum = 99

    static func clamped(_ quantity: Int) -> Int {
        min(maximum, max(minimum, quantity))
    }
}

protocol CartPricingUseCase: Sendable {
    func unitPrice(for pizza: Pizza, size: PizzaSize) -> Decimal?
    func totalPrice(for pizza: Pizza, size: PizzaSize, quantity: Int) -> Decimal?
}

struct CartPricingCalculator: CartPricingUseCase {
    func unitPrice(for pizza: Pizza, size: PizzaSize) -> Decimal? {
        pizza.price(for: size)
    }

    func totalPrice(for pizza: Pizza, size: PizzaSize, quantity: Int) -> Decimal? {
        guard quantity >= CartQuantity.minimum,
              let unitPrice = unitPrice(for: pizza, size: size) else {
            return nil
        }
        return unitPrice * Decimal(quantity)
    }
}
