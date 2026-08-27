//
//  PizzaImageStore.swift
//  PizzaMobileApp
//

import SwiftUI

@MainActor
@Observable
final class PizzaImageStore {
    enum Phase: Equatable {
        case idle
        case loading
        case loaded
        case failed
    }

    private struct LoadKey: Hashable {
        let pizzaID: String
        let variant: PizzaImageVariant
    }

    private var catalogImages: [String: UIImage] = [:]
    private var detailImages: [String: UIImage] = [:]
    private var phases: [String: Phase] = [:]
    private var inFlight: [LoadKey: Task<UIImage, Error>] = [:]

    private let cache: any ImageCacheReading
    private let loader: any ImageLoading

    init(cache: any ImageCacheReading, loader: any ImageLoading) {
        self.cache = cache
        self.loader = loader
    }

    func image(for pizzaID: String, preferHighResolution: Bool = false) -> UIImage? {
        if preferHighResolution, let detailImage = detailImages[pizzaID] {
            return detailImage
        }
        return catalogImages[pizzaID]
    }

    func phase(for pizzaID: String) -> Phase {
        phases[pizzaID] ?? .idle
    }

    func loadImages(around focusedPizza: Pizza, in pizzas: [Pizza]) async {
        hydrateCatalogImages(for: pizzas)
        detailImages = detailImages.filter { $0.key == focusedPizza.id }

        let focusedIndex = pizzas.firstIndex(where: { $0.id == focusedPizza.id }) ?? 0
        let neighbors = pizzas.enumerated()
            .filter { $0.element.id != focusedPizza.id }
            .sorted { abs($0.offset - focusedIndex) < abs($1.offset - focusedIndex) }
            .map(\.element)

        await withTaskGroup(of: Void.self) { group in
            group.addTask { [weak self] in
                guard !Task.isCancelled else { return }
                await self?.loadCatalogImage(for: focusedPizza, priority: .userInitiated)
            }

            group.addTask { [weak self] in
                guard !Task.isCancelled else { return }
                await self?.loadDetailImage(for: focusedPizza, priority: .userInitiated)
            }

            for pizza in neighbors {
                group.addTask { [weak self] in
                    guard !Task.isCancelled else { return }
                    await self?.loadCatalogImage(for: pizza, priority: .utility)
                }
            }
        }
    }

    func retryCatalogImage(for pizza: Pizza) async {
        phases[pizza.id] = .idle
        await loadCatalogImage(for: pizza, priority: .userInitiated)
    }

    func hydrateCatalogImages(for pizzas: [Pizza]) {
        for pizza in pizzas where catalogImages[pizza.id] == nil {
            guard let cached = cache.cached(for: pizza.imageURL, variant: .catalog) else { continue }
            catalogImages[pizza.id] = cached
            phases[pizza.id] = .loaded
        }
    }

    private func loadCatalogImage(for pizza: Pizza, priority: TaskPriority) async {
        if catalogImages[pizza.id] != nil {
            phases[pizza.id] = .loaded
            return
        }

        phases[pizza.id] = .loading

        do {
            let image = try await sharedImage(
                for: pizza,
                variant: .catalog,
                priority: priority
            )
            withAnimation(AppAnimation.imageReveal) {
                catalogImages[pizza.id] = image
                phases[pizza.id] = .loaded
            }
        } catch is CancellationError {
            phases[pizza.id] = .idle
        } catch {
            phases[pizza.id] = .failed
        }
    }

    private func loadDetailImage(for pizza: Pizza, priority: TaskPriority) async {
        if detailImages[pizza.id] != nil { return }

        if let cached = cache.cached(for: pizza.imageURL, variant: .detail) {
            detailImages[pizza.id] = cached
            return
        }

        do {
            let image = try await sharedImage(
                for: pizza,
                variant: .detail,
                priority: priority
            )
            try Task.checkCancellation()
            detailImages[pizza.id] = image
        } catch {
            return
        }
    }

    private func sharedImage(
        for pizza: Pizza,
        variant: PizzaImageVariant,
        priority: TaskPriority
    ) async throws -> UIImage {
        let key = LoadKey(pizzaID: pizza.id, variant: variant)
        if let existingTask = inFlight[key] {
            return try await existingTask.value
        }

        let url = pizza.imageURL
        let loader = loader
        let task = Task(priority: priority) {
            try await loader.load(url, variant: variant, priority: priority)
        }
        inFlight[key] = task
        defer { inFlight[key] = nil }

        return try await task.value
    }
}
