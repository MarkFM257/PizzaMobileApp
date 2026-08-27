//
//  Pizza+Preview.swift
//  PizzaMobileApp
//

#if DEBUG
import Foundation

extension Pizza {
    static let previewSet: [Pizza] = [
        Pizza(
            id: "pepperoni-blast",
            name: "Pepperoni Blast",
            description: "The combination of perfectly melted mozzarella cheese, tangy tomato sauce, "
                + "and a crispy yet chewy crust creates a harmonious balance that leaves you wanting more.",
            imageURL: URL(string: "https://oursongapp.com/images/pizzas/pizza_pepperoni_blast.png")!,
            variants: [
                Variant(size: .S, price: 15.50),
                Variant(size: .M, price: 17.99),
                Variant(size: .L, price: 22.50)
            ],
            defaultSize: .M
        ),
        Pizza(
            id: "midnight-harvest",
            name: "Midnight Harvest",
            description: "Olives and cheese magic.",
            imageURL: URL(string: "https://oursongapp.com/images/pizzas/pizza_midnight_harvest.png")!,
            variants: [
                Variant(size: .S, price: 14.99),
                Variant(size: .M, price: 17.99),
                Variant(size: .L, price: 21.99)
            ],
            defaultSize: .M
        )
    ]
}
#endif
