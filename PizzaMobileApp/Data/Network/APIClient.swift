//
//  APIClient.swift
//  PizzaMobileApp
//

import Foundation

protocol APIClient: Sendable {
    func get<T: Decodable & Sendable>(_ url: URL, as type: T.Type) async throws -> T
}

enum APIError: LocalizedError {
    case invalidResponse
    case statusCode(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "Invalid server response."
        case .statusCode(let code): return "Server returned status \(code)."
        }
    }
}
