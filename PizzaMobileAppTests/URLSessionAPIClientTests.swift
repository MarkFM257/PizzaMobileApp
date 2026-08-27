import Foundation
import XCTest
@testable import PizzaMobileApp

final class URLSessionAPIClientTests: XCTestCase {
    override func tearDown() {
        StubURLProtocol.handler = nil
        super.tearDown()
    }

    func testGETDecodesSuccessfulResponse() async throws {
        StubURLProtocol.handler = { request in
            let response = HTTPURLResponse(
                url: try XCTUnwrap(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, Data("{\"value\":42}".utf8))
        }
        let client = makeClient()

        let response = try await client.get(
            URL(string: "https://example.com/value")!,
            as: ValueResponse.self
        )

        XCTAssertEqual(response.value, 42)
    }

    func testGETThrowsStatusCodeError() async {
        StubURLProtocol.handler = { request in
            let response = HTTPURLResponse(
                url: try XCTUnwrap(request.url),
                statusCode: 503,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }
        let client = makeClient()

        do {
            _ = try await client.get(
                URL(string: "https://example.com/value")!,
                as: ValueResponse.self
            )
            XCTFail("Expected statusCode error")
        } catch APIError.statusCode(let code) {
            XCTAssertEqual(code, 503)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    private func makeClient() -> URLSessionAPIClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        return URLSessionAPIClient(session: URLSession(configuration: configuration))
    }
}

private struct ValueResponse: Decodable, Sendable {
    let value: Int
}

private final class StubURLProtocol: URLProtocol {
    typealias Handler = @Sendable (URLRequest) throws -> (HTTPURLResponse, Data)

    private static let handlerLock = NSLock()
    nonisolated(unsafe) private static var storedHandler: Handler?

    static var handler: Handler? {
        get { handlerLock.withLock { storedHandler } }
        set { handlerLock.withLock { storedHandler = newValue } }
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
