//
//  PizzaCatalogCache.swift
//  PizzaMobileApp
//

import Foundation

protocol PizzaCatalogCaching: Sendable {
    func load() async -> PizzasResponseDTO?
    func save(_ response: PizzasResponseDTO) async
    func remove() async
}

actor UserDefaultsPizzaCatalogCache: PizzaCatalogCaching {
    private let defaults: UserDefaults
    private let key: String

    init(
        defaults: UserDefaults = .standard,
        key: String = "pizza.catalog.response.v1"
    ) {
        self.defaults = defaults
        self.key = key
    }

    func load() async -> PizzasResponseDTO? {
        guard let data = defaults.data(forKey: key) else { return nil }

        do {
            return try JSONDecoder().decode(PizzasResponseDTO.self, from: data)
        } catch {
            defaults.removeObject(forKey: key)
            return nil
        }
    }

    func save(_ response: PizzasResponseDTO) async {
        guard let data = try? JSONEncoder().encode(response) else { return }
        defaults.set(data, forKey: key)
    }

    func remove() async {
        defaults.removeObject(forKey: key)
    }
}
