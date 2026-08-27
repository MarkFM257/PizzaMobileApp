import Foundation
import XCTest
@testable import PizzaMobileApp

final class PizzaRepositoryCacheTests: XCTestCase {
    func testCachedCatalogIsReturnedWithoutWaitingForNetwork() async throws {
        let response = makeResponse(id: "cached")
        let cache = InMemoryPizzaCatalogCache(response: response)
        let repository = PizzaRepositoryImpl(
            client: FailingCatalogAPIClient(),
            endpoint: URL(string: "https://example.com/pizzas")!,
            cache: cache
        )

        let pizzas = await repository.loadCachedPizzas()

        XCTAssertEqual(pizzas?.map(\.id), ["cached"])
    }

    func testRemoteCatalogIsPersistedAfterFirstLoad() async throws {
        let response = makeResponse(id: "remote")
        let cache = InMemoryPizzaCatalogCache()
        let repository = PizzaRepositoryImpl(
            client: StubCatalogAPIClient(response: response),
            endpoint: URL(string: "https://example.com/pizzas")!,
            cache: cache
        )

        let pizzas = try await repository.refreshPizzas()
        let cachedResponse = await cache.load()

        XCTAssertEqual(pizzas.map(\.id), ["remote"])
        XCTAssertEqual(cachedResponse?.pizzas.map(\.id), ["remote"])
    }

    func testInvalidCachedCatalogIsIgnored() async {
        let invalid = PizzasResponseDTO(pizzas: [
            PizzaDTO(
                id: "invalid",
                name: "Invalid",
                description: "Invalid price.",
                imageURL: URL(string: "https://example.com/invalid.png")!,
                variants: [VariantDTO(size: .M, price: 0)],
                defaultSize: .M
            )
        ])
        let cache = InMemoryPizzaCatalogCache(response: invalid)
        let repository = PizzaRepositoryImpl(
            client: FailingCatalogAPIClient(),
            endpoint: URL(string: "https://example.com/pizzas")!,
            cache: cache
        )

        let cached = await repository.loadCachedPizzas()
        let remainingCache = await cache.load()

        XCTAssertNil(cached)
        XCTAssertNil(remainingCache)
    }

    func testCorruptUserDefaultsCacheIsRemoved() async {
        let suiteName = "PizzaRepositoryCacheTests.\(UUID().uuidString)"
        let key = "catalog"
        let cache: UserDefaultsPizzaCatalogCache = {
            let seededDefaults = UserDefaults(suiteName: suiteName)!
            seededDefaults.set(Data("not-json".utf8), forKey: key)
            return UserDefaultsPizzaCatalogCache(defaults: seededDefaults, key: key)
        }()

        let response = await cache.load()
        let verificationDefaults = UserDefaults(suiteName: suiteName)!

        XCTAssertNil(response)
        XCTAssertNil(verificationDefaults.data(forKey: key))
        verificationDefaults.removePersistentDomain(forName: suiteName)
    }

    private func makeResponse(id: String) -> PizzasResponseDTO {
        PizzasResponseDTO(pizzas: [
            PizzaDTO(
                id: id,
                name: "Test Pizza",
                description: "Cached catalog test.",
                imageURL: URL(string: "https://example.com/\(id).png")!,
                variants: [VariantDTO(size: .M, price: 12)],
                defaultSize: .M
            )
        ])
    }
}

private actor InMemoryPizzaCatalogCache: PizzaCatalogCaching {
    private var response: PizzasResponseDTO?

    init(response: PizzasResponseDTO? = nil) {
        self.response = response
    }

    func load() async -> PizzasResponseDTO? {
        response
    }

    func save(_ response: PizzasResponseDTO) async {
        self.response = response
    }

    func remove() async {
        response = nil
    }
}

private struct StubCatalogAPIClient: APIClient {
    let response: PizzasResponseDTO

    func get<T: Decodable & Sendable>(_ url: URL, as type: T.Type) async throws -> T {
        let data = try JSONEncoder().encode(response)
        return try JSONDecoder().decode(T.self, from: data)
    }
}

private struct FailingCatalogAPIClient: APIClient {
    func get<T: Decodable & Sendable>(_ url: URL, as type: T.Type) async throws -> T {
        throw URLError(.cannotConnectToHost)
    }
}
