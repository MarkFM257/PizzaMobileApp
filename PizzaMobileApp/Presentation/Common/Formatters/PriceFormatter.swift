//
//  PriceFormatter.swift
//  PizzaMobileApp
//

import Foundation

enum PriceFormatter {
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()

    static func string(from value: Decimal?) -> String {
        guard let value else { return "—" }
        return formatter.string(from: value as NSDecimalNumber) ?? "—"
    }
}
