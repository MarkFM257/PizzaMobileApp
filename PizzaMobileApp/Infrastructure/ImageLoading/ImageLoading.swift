//
//  ImageLoading.swift
//  PizzaMobileApp
//

import UIKit

enum PizzaImageVariant: Hashable, Sendable {
    case catalog
    case detail
}

protocol ImageCacheReading: Sendable {
    func cached(for url: URL, variant: PizzaImageVariant) -> UIImage?
}

protocol ImageLoading: Sendable {
    func load(
        _ url: URL,
        variant: PizzaImageVariant,
        priority: TaskPriority
    ) async throws -> UIImage
}
