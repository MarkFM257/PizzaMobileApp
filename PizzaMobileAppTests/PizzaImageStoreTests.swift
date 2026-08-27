import UIKit
import XCTest
@testable import PizzaMobileApp

final class PizzaImageStoreTests: XCTestCase {
    @MainActor
    func testCatalogAndDetailImagesLoadTogether() async {
        let loader = RecordingImageLoader()
        let store = PizzaImageStore(cache: EmptyImageCache(), loader: loader)
        let pizzas = makePizzas()

        await store.loadImages(around: pizzas[1], in: pizzas)

        let events = await loader.recordedEvents()
        XCTAssertEqual(
            Set(events),
            Set([
                LoadEvent(pizzaID: pizzas[1].id, variant: .catalog),
                LoadEvent(pizzaID: pizzas[0].id, variant: .catalog),
                LoadEvent(pizzaID: pizzas[2].id, variant: .catalog),
                LoadEvent(pizzaID: pizzas[1].id, variant: .detail)
            ])
        )
    }

    @MainActor
    func testNewFocusAwaitsExistingNeighborRequestWhenPreviousLoadIsCancelled() async {
        let pizzas = makePizzas()
        let delayedNeighbor = LoadEvent(pizzaID: pizzas[0].id, variant: .catalog)
        let loader = RecordingImageLoader(delays: [delayedNeighbor: .milliseconds(150)])
        let store = PizzaImageStore(cache: EmptyImageCache(), loader: loader)

        let initialLoad = Task {
            await store.loadImages(around: pizzas[1], in: pizzas)
        }
        await loader.waitUntilStarted(delayedNeighbor)

        initialLoad.cancel()
        let focusedLoad = Task {
            await store.loadImages(around: pizzas[0], in: pizzas)
        }

        await focusedLoad.value
        await initialLoad.value

        let delayedNeighborLoadCount = await loader.loadCount(for: delayedNeighbor)
        XCTAssertEqual(store.phase(for: pizzas[0].id), .loaded)
        XCTAssertNotNil(store.image(for: pizzas[0].id))
        XCTAssertEqual(delayedNeighborLoadCount, 1)
    }

    @MainActor
    func testHydratingCatalogCacheAvoidsCatalogRequest() async {
        let pizza = TestFixtures.pizza()
        let loader = RecordingImageLoader()
        let store = PizzaImageStore(
            cache: SingleCatalogImageCache(url: pizza.imageURL),
            loader: loader
        )

        store.hydrateCatalogImages(for: [pizza])
        let events = await loader.recordedEvents()

        XCTAssertEqual(store.phase(for: pizza.id), .loaded)
        XCTAssertNotNil(store.image(for: pizza.id))
        XCTAssertTrue(events.isEmpty)
    }

    @MainActor
    func testFailedCatalogImageCanBeRetried() async {
        let pizza = TestFixtures.pizza()
        let loader = FlakyImageLoader()
        let store = PizzaImageStore(cache: EmptyImageCache(), loader: loader)

        await store.retryCatalogImage(for: pizza)
        XCTAssertEqual(store.phase(for: pizza.id), .failed)

        await store.retryCatalogImage(for: pizza)
        XCTAssertEqual(store.phase(for: pizza.id), .loaded)
        XCTAssertNotNil(store.image(for: pizza.id))
    }

    private func makePizzas() -> [Pizza] {
        [
            TestFixtures.pizza(id: "midnight-harvest"),
            TestFixtures.pizza(id: "pepperoni-blast"),
            TestFixtures.pizza(id: "shrimptastic")
        ]
    }
}

private struct EmptyImageCache: ImageCacheReading {
    func cached(for url: URL, variant: PizzaImageVariant) -> UIImage? { nil }
}

private struct SingleCatalogImageCache: ImageCacheReading {
    let url: URL

    func cached(for url: URL, variant: PizzaImageVariant) -> UIImage? {
        url == self.url && variant == .catalog ? UIImage() : nil
    }
}

private struct LoadEvent: Hashable, Sendable {
    let pizzaID: String
    let variant: PizzaImageVariant
}

private actor RecordingImageLoader: ImageLoading {
    private let delays: [LoadEvent: Duration]
    private var events: [LoadEvent] = []
    private var startWaiters: [LoadEvent: [CheckedContinuation<Void, Never>]] = [:]

    init(delays: [LoadEvent: Duration] = [:]) {
        self.delays = delays
    }

    func load(
        _ url: URL,
        variant: PizzaImageVariant,
        priority: TaskPriority
    ) async throws -> UIImage {
        let event = LoadEvent(
            pizzaID: url.deletingPathExtension().lastPathComponent,
            variant: variant
        )
        events.append(event)
        startWaiters.removeValue(forKey: event)?.forEach { $0.resume() }

        if let delay = delays[event] {
            try await Task.sleep(for: delay)
        }
        return UIImage()
    }

    func recordedEvents() -> [LoadEvent] {
        events
    }

    func loadCount(for event: LoadEvent) -> Int {
        events.count { $0 == event }
    }

    func waitUntilStarted(_ event: LoadEvent) async {
        guard !events.contains(event) else { return }
        await withCheckedContinuation { continuation in
            startWaiters[event, default: []].append(continuation)
        }
    }
}

private actor FlakyImageLoader: ImageLoading {
    private var attempt = 0

    func load(
        _ url: URL,
        variant: PizzaImageVariant,
        priority: TaskPriority
    ) async throws -> UIImage {
        attempt += 1
        if attempt == 1 {
            throw URLError(.cannotLoadFromNetwork)
        }
        return UIImage()
    }
}
