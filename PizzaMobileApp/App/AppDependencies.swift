//
//  AppDependencies.swift
//  PizzaMobileApp
//

import Foundation
import UIKit

@MainActor
final class AppDependencies {
    private let prepareCatalogUseCase: any PreparePizzaCatalogUseCase
    private let cartPricingUseCase: any CartPricingUseCase
    private let imageCache: any ImageCacheReading
    private let imageLoader: any ImageLoading
    private let connectivityMonitor: any ConnectivityMonitoring
    private let featuredPizzaID: String
    private let splashMaximumDuration: Duration

    init(config: AppConfig = .default) {
        let urlCache = URLCache(
            memoryCapacity: config.urlCacheMemoryCapacity,
            diskCapacity: config.urlCacheDiskCapacity
        )
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.urlCache = urlCache
        sessionConfiguration.requestCachePolicy = .useProtocolCachePolicy
        sessionConfiguration.timeoutIntervalForRequest = config.apiRequestTimeout
        sessionConfiguration.timeoutIntervalForResource = config.apiResourceTimeout

        let apiClient = URLSessionAPIClient(
            session: URLSession(configuration: sessionConfiguration)
        )
        let repository = PizzaRepositoryImpl(
            client: apiClient,
            endpoint: config.pizzasEndpoint,
            cache: UserDefaultsPizzaCatalogCache()
        )
        let imageInfrastructure = KingfisherImageLoader(
            scale: UIScreen.main.scale,
            downloadTimeout: config.imageDownloadTimeout
        )
        let loadPizzas = LoadPizzasInteractor(repository: repository)

        self.prepareCatalogUseCase = PreparePizzaCatalogInteractor(
            loadPizzas: loadPizzas
        )
        self.cartPricingUseCase = CartPricingCalculator()
        self.imageCache = imageInfrastructure
        self.imageLoader = imageInfrastructure
        self.connectivityMonitor = NetworkMonitor()
        self.featuredPizzaID = config.featuredPizzaID
        self.splashMaximumDuration = .seconds(config.splashMaximumDuration)
    }

    func makeAppShellViewModel() -> AppShellViewModel {
        AppShellViewModel(
            catalog: makeCatalogViewModel(),
            connectivity: makeConnectivityViewModel(),
            splashMaximumDuration: splashMaximumDuration
        )
    }

    func makeCatalogViewModel() -> PizzaCatalogViewModel {
        PizzaCatalogViewModel(prepareCatalog: prepareCatalogUseCase)
    }

    func makeDetailViewModel(pizzas: [Pizza]) -> PizzaDetailViewModel {
        PizzaDetailViewModel(
            pizzas: pizzas,
            pricing: cartPricingUseCase,
            featuredPizzaID: featuredPizzaID
        )
    }

    func makeImageStore() -> PizzaImageStore {
        PizzaImageStore(cache: imageCache, loader: imageLoader)
    }

    func makeCatalogSceneModel() -> CatalogSceneModel {
        CatalogSceneModel(
            pricing: cartPricingUseCase,
            imageStore: makeImageStore(),
            featuredPizzaID: featuredPizzaID
        )
    }

    func makeConnectivityViewModel() -> ConnectivityViewModel {
        ConnectivityViewModel(monitor: connectivityMonitor)
    }
}
