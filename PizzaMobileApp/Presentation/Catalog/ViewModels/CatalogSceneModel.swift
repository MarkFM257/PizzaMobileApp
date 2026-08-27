//
//  CatalogSceneModel.swift
//  PizzaMobileApp
//

import Foundation

@MainActor
final class CatalogSceneModel {
    let imageStore: PizzaImageStore

    private let pricing: any CartPricingUseCase
    private let featuredPizzaID: String

    init(
        pricing: any CartPricingUseCase,
        imageStore: PizzaImageStore,
        featuredPizzaID: String
    ) {
        self.pricing = pricing
        self.imageStore = imageStore
        self.featuredPizzaID = featuredPizzaID
    }

    func makeDetailViewModel(for pizzas: [Pizza]) -> PizzaDetailViewModel {
        PizzaDetailViewModel(
            pizzas: pizzas,
            pricing: pricing,
            featuredPizzaID: featuredPizzaID
        )
    }
}
