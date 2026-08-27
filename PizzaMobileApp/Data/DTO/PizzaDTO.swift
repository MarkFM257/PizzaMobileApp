//
//  PizzaDTO.swift
//  PizzaMobileApp
//

import Foundation

struct PizzasResponseDTO: Codable, Sendable {
    let pizzas: [PizzaDTO]
}

struct PizzaDTO: Codable, Sendable {
    let id: String
    let name: String
    let description: String
    let imageURL: URL
    let variants: [VariantDTO]
    let defaultSize: PizzaSize

    enum CodingKeys: String, CodingKey {
        case id, name, description, variants
        case imageURL = "image_url"
        case defaultSize = "default_size"
    }
}

struct VariantDTO: Codable, Sendable {
    let size: PizzaSize
    let price: Decimal
}

enum PizzaMappingError: LocalizedError, Sendable {
    case emptyIdentifier
    case emptyName(id: String)
    case invalidImageURL(id: String)
    case missingVariants(id: String)
    case duplicateVariant(id: String, size: PizzaSize)
    case invalidPrice(id: String, size: PizzaSize)
    case unavailableDefaultSize(id: String, size: PizzaSize)
    case duplicatePizzaIdentifier(String)

    var errorDescription: String? {
        "The pizza catalog contains invalid data."
    }
}

extension PizzaDTO {
    func toDomain() throws -> Pizza {
        let trimmedID = id.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedID.isEmpty else {
            throw PizzaMappingError.emptyIdentifier
        }
        guard !trimmedName.isEmpty else {
            throw PizzaMappingError.emptyName(id: trimmedID)
        }
        guard imageURL.scheme == "https" else {
            throw PizzaMappingError.invalidImageURL(id: trimmedID)
        }
        guard !variants.isEmpty else {
            throw PizzaMappingError.missingVariants(id: trimmedID)
        }

        var seenSizes = Set<PizzaSize>()
        let domainVariants = try variants.map { variant in
            guard seenSizes.insert(variant.size).inserted else {
                throw PizzaMappingError.duplicateVariant(id: trimmedID, size: variant.size)
            }
            guard variant.price > 0 else {
                throw PizzaMappingError.invalidPrice(id: trimmedID, size: variant.size)
            }
            return Variant(size: variant.size, price: variant.price)
        }

        guard seenSizes.contains(defaultSize) else {
            throw PizzaMappingError.unavailableDefaultSize(id: trimmedID, size: defaultSize)
        }

        return Pizza(
            id: trimmedID,
            name: trimmedName,
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            imageURL: imageURL,
            variants: domainVariants,
            defaultSize: defaultSize
        )
    }
}

extension PizzasResponseDTO {
    func toDomain() throws -> [Pizza] {
        let pizzas = try pizzas.map { try $0.toDomain() }
        var identifiers = Set<String>()
        for pizza in pizzas where !identifiers.insert(pizza.id).inserted {
            throw PizzaMappingError.duplicatePizzaIdentifier(pizza.id)
        }
        return pizzas
    }
}
