//
//  PizzaRepositoryImpl.swift
//  PizzaMobileApp
//

import Foundation

final class PizzaRepositoryImpl: PizzaRepository {
    private let client: any APIClient
    private let endpoint: URL
    private let cache: any PizzaCatalogCaching

    init(
        client: any APIClient,
        endpoint: URL,
        cache: any PizzaCatalogCaching
    ) {
        self.client = client
        self.endpoint = endpoint
        self.cache = cache
    }

    func loadCachedPizzas() async -> [Pizza]? {
        guard let cachedResponse = await cache.load() else { return nil }

        do {
            return try cachedResponse.toDomain()
        } catch {
            await cache.remove()
            return nil
        }
    }

    func refreshPizzas() async throws -> [Pizza] {
        let response = try await client.get(endpoint, as: PizzasResponseDTO.self)
        let pizzas = try response.toDomain()
        await cache.save(response)
        return pizzas
    }
}
