//
//  AppConfig.swift
//  PizzaMobileApp
//

import Foundation

struct AppConfig: Sendable {
    let pizzasEndpoint: URL
    let featuredPizzaID: String
    let urlCacheMemoryCapacity: Int
    let urlCacheDiskCapacity: Int
    let apiRequestTimeout: TimeInterval
    let apiResourceTimeout: TimeInterval
    let imageDownloadTimeout: TimeInterval
    let splashMaximumDuration: TimeInterval

    static let `default` = AppConfig(
        pizzasEndpoint: URL(string: "https://oursongapp.com/api/pizzas")!,
        featuredPizzaID: "pepperoni-blast",
        urlCacheMemoryCapacity: 50_000_000,
        urlCacheDiskCapacity: 200_000_000,
        apiRequestTimeout: 5,
        apiResourceTimeout: 10,
        imageDownloadTimeout: 8,
        splashMaximumDuration: 4
    )
}
