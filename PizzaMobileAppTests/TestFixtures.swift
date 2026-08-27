import Foundation
@testable import PizzaMobileApp

enum TestFixtures {
    static func pizza(
        id: String = "pepperoni-blast",
        name: String = "Pepperoni Blast",
        defaultSize: PizzaSize = .M,
        variants: [Variant] = [
            Variant(size: .S, price: 15.50),
            Variant(size: .M, price: 17.99),
            Variant(size: .L, price: 22.50)
        ]
    ) -> Pizza {
        Pizza(
            id: id,
            name: name,
            description: "A test pizza description.",
            imageURL: URL(string: "https://example.com/\(id).png")!,
            variants: variants,
            defaultSize: defaultSize
        )
    }
}
