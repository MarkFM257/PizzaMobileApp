//
//  Pizza.swift
//  PizzaMobileApp
//

import Foundation

enum PizzaSize: String, CaseIterable, Codable, Hashable, Identifiable {
    case S, M, L

    var ordinal: Int {
        switch self {
        case .S: return 0
        case .M: return 1
        case .L: return 2
        }
    }

    var id: String { rawValue }
}

struct Variant: Equatable, Hashable {
    let size: PizzaSize
    let price: Decimal
}

struct Pizza: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let description: String
    let imageURL: URL
    let variants: [Variant]
    let defaultSize: PizzaSize

    var availableSizes: [PizzaSize] {
        variants
            .map(\.size)
            .sorted { $0.ordinal < $1.ordinal }
    }

    func price(for size: PizzaSize) -> Decimal? {
        variants.first { $0.size == size }?.price
    }
}
