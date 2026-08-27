//
//  PreparePizzaCatalogUseCase.swift
//  PizzaMobileApp
//

import Foundation

enum PizzaCatalogSource: Equatable, Sendable {
    case cache
    case remote
}

struct PreparedPizzaCatalog: Sendable {
    let pizzas: [Pizza]
    let source: PizzaCatalogSource
}

protocol PreparePizzaCatalogUseCase: Sendable {
    func loadInitial() async throws -> PreparedPizzaCatalog
    func refresh() async throws -> PreparedPizzaCatalog
}

struct PreparePizzaCatalogInteractor: PreparePizzaCatalogUseCase {
    private let loadPizzas: any LoadPizzasUseCase

    init(loadPizzas: any LoadPizzasUseCase) {
        self.loadPizzas = loadPizzas
    }

    func loadInitial() async throws -> PreparedPizzaCatalog {
        if let cached = await loadPizzas.loadCached(), !cached.isEmpty {
            return PreparedPizzaCatalog(pizzas: cached, source: .cache)
        }

        let remote = try await loadPizzas.refresh()
        return PreparedPizzaCatalog(pizzas: remote, source: .remote)
    }

    func refresh() async throws -> PreparedPizzaCatalog {
        let remote = try await loadPizzas.refresh()
        return PreparedPizzaCatalog(pizzas: remote, source: .remote)
    }
}
