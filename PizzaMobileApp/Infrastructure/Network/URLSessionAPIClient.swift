//
//  URLSessionAPIClient.swift
//  PizzaMobileApp
//

import Foundation

actor URLSessionAPIClient: APIClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func get<T: Decodable & Sendable>(_ url: URL, as type: T.Type) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw APIError.statusCode(http.statusCode)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
