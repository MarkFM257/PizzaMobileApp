//
//  PizzaRepository.swift
//  PizzaMobileApp
//

import Foundation

protocol PizzaRepository: Sendable {
    func loadCachedPizzas() async -> [Pizza]?
    func refreshPizzas() async throws -> [Pizza]
}
