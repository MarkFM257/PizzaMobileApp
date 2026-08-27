//
//  KingfisherImageLoader.swift
//  PizzaMobileApp
//

import UIKit
import Kingfisher

actor KingfisherImageLoader: ImageCacheReading, ImageLoading {
    nonisolated private static let catalogSize = CGSize(width: 1_080, height: 1_080)
    nonisolated private let scale: CGFloat
    nonisolated private let cache: ImageCache
    private let manager: KingfisherManager

    init(scale: CGFloat, downloadTimeout: TimeInterval) {
        self.scale = scale
        let downloader = ImageDownloader(name: "pizza-images")
        downloader.downloadTimeout = downloadTimeout
        let cache = ImageCache(name: "pizza-images")
        self.cache = cache
        self.manager = KingfisherManager(downloader: downloader, cache: cache)
    }

    nonisolated func cached(for url: URL, variant: PizzaImageVariant) -> UIImage? {
        cache.retrieveImageInMemoryCache(
            forKey: url.absoluteString,
            options: cacheOptions(for: variant)
        )
    }

    func load(
        _ url: URL,
        variant: PizzaImageVariant,
        priority: TaskPriority = .userInitiated
    ) async throws -> UIImage {
        let result = try await manager.retrieveImage(
            with: url,
            options: loadOptions(for: variant, priority: priority)
        )
        try Task.checkCancellation()
        return result.image
    }

    nonisolated private func cacheOptions(for variant: PizzaImageVariant) -> KingfisherOptionsInfo {
        switch variant {
        case .catalog:
            return [
                .processor(DownsamplingImageProcessor(size: Self.catalogSize)),
                .scaleFactor(scale)
            ]
        case .detail:
            return [.scaleFactor(scale)]
        }
    }

    nonisolated private func loadOptions(
        for variant: PizzaImageVariant,
        priority: TaskPriority
    ) -> KingfisherOptionsInfo {
        var options = cacheOptions(for: variant)
        options.append(.downloadPriority(downloadPriority(for: priority)))
        if variant == .catalog {
            options.append(.cacheOriginalImage)
        }
        return options
    }

    nonisolated private func downloadPriority(for priority: TaskPriority) -> Float {
        let normalized = Float(priority.rawValue) / Float(TaskPriority.high.rawValue)
        return min(1, max(0.1, normalized))
    }
}
