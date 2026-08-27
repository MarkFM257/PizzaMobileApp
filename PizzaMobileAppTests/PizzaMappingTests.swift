import Foundation
import XCTest
@testable import PizzaMobileApp

final class PizzaMappingTests: XCTestCase {
    func testValidPayloadMapsEveryAPIVariant() throws {
        let data = Data(
            """
            {
              "pizzas": [{
                "id": "pepperoni-blast",
                "name": "Pepperoni Blast",
                "description": "Classic",
                "image_url": "https://example.com/pizza.png",
                "variants": [
                  {"size": "S", "price": 15.5},
                  {"size": "M", "price": 17.99},
                  {"size": "L", "price": 22.5}
                ],
                "default_size": "M"
              }]
            }
            """.utf8
        )

        let response = try JSONDecoder().decode(PizzasResponseDTO.self, from: data)
        let pizza = try XCTUnwrap(response.pizzas.first?.toDomain())

        XCTAssertEqual(pizza.id, "pepperoni-blast")
        XCTAssertEqual(pizza.availableSizes, [.S, .M, .L])
        XCTAssertEqual(pizza.defaultSize, .M)
        XCTAssertEqual(pizza.price(for: .M), Decimal(string: "17.99"))
    }

    func testMappingRejectsDuplicateSizes() {
        let dto = PizzaDTO(
            id: "duplicate",
            name: "Duplicate",
            description: "Invalid",
            imageURL: URL(string: "https://example.com/pizza.png")!,
            variants: [
                VariantDTO(size: .M, price: 10),
                VariantDTO(size: .M, price: 12)
            ],
            defaultSize: .M
        )

        XCTAssertThrowsError(try dto.toDomain()) { error in
            guard case PizzaMappingError.duplicateVariant(_, .M) = error else {
                return XCTFail("Expected duplicateVariant, got \(error)")
            }
        }
    }

    func testMappingRejectsUnavailableDefaultSize() {
        let dto = PizzaDTO(
            id: "missing-default",
            name: "Missing Default",
            description: "Invalid",
            imageURL: URL(string: "https://example.com/pizza.png")!,
            variants: [VariantDTO(size: .S, price: 10)],
            defaultSize: .M
        )

        XCTAssertThrowsError(try dto.toDomain()) { error in
            guard case PizzaMappingError.unavailableDefaultSize(_, .M) = error else {
                return XCTFail("Expected unavailableDefaultSize, got \(error)")
            }
        }
    }
}
