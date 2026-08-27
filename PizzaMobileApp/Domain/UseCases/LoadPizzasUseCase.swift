//
//  LoadPizzasUseCase.swift
//  PizzaMobileApp
//

import Foundation

protocol LoadPizzasUseCase: Sendable {
    func loadCached() async -> [Pizza]?
    func refresh() async throws -> [Pizza]
}

struct LoadPizzasInteractor: LoadPizzasUseCase {
    private let repository: any PizzaRepository

    init(repository: any PizzaRepository) {
        self.repository = repository
    }

    func loadCached() async -> [Pizza]? {
        await repository.loadCachedPizzas()
    }

    func refresh() async throws -> [Pizza] {
        try await repository.refreshPizzas()
    }
}
