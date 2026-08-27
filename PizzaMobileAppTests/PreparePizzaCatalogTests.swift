import XCTest
@testable import PizzaMobileApp

final class PreparePizzaCatalogTests: XCTestCase {
    func testCachedCatalogIsPreparedWithoutRemoteRequest() async throws {
        let cached = [TestFixtures.pizza(id: "cached")]
        let loader = RecordingPizzaLoader(
            cached: cached,
            remote: [TestFixtures.pizza(id: "remote")]
        )
        let useCase = PreparePizzaCatalogInteractor(loadPizzas: loader)

        let result = try await useCase.loadInitial()
        let refreshCount = await loader.refreshCount

        XCTAssertEqual(result.pizzas.map(\.id), ["cached"])
        XCTAssertEqual(result.source, .cache)
        XCTAssertEqual(refreshCount, 0)
    }

    func testMissingCacheLoadsRemoteCatalog() async throws {
        let remote = [TestFixtures.pizza(id: "remote")]
        let loader = RecordingPizzaLoader(cached: nil, remote: remote)
        let useCase = PreparePizzaCatalogInteractor(loadPizzas: loader)

        let result = try await useCase.loadInitial()
        let refreshCount = await loader.refreshCount

        XCTAssertEqual(result.pizzas.map(\.id), ["remote"])
        XCTAssertEqual(result.source, .remote)
        XCTAssertEqual(refreshCount, 1)
    }
}

private actor RecordingPizzaLoader: LoadPizzasUseCase {
    let cached: [Pizza]?
    let remote: [Pizza]
    private(set) var refreshCount = 0

    init(cached: [Pizza]?, remote: [Pizza]) {
        self.cached = cached
        self.remote = remote
    }

    func loadCached() async -> [Pizza]? {
        cached
    }

    func refresh() async throws -> [Pizza] {
        refreshCount += 1
        return remote
    }
}
