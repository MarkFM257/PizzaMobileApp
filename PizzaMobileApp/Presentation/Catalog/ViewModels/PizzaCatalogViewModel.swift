//
//  PizzaCatalogViewModel.swift
//  PizzaMobileApp
//

import Foundation

@MainActor
@Observable
final class PizzaCatalogViewModel {
    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    private(set) var state: LoadState = .idle
    private(set) var pizzas: [Pizza] = []
    private(set) var initialSource: PizzaCatalogSource?

    private let prepareCatalog: any PreparePizzaCatalogUseCase
    private var loadGeneration = 0

    init(prepareCatalog: any PreparePizzaCatalogUseCase) {
        self.prepareCatalog = prepareCatalog
    }

    func loadInitial() async {
        await load(isInitial: true)
    }

    func refresh() async {
        await load(isInitial: false)
    }

    private func load(isInitial: Bool) async {
        loadGeneration += 1
        let generation = loadGeneration
        state = .loading

        do {
            let prepared: PreparedPizzaCatalog
            if isInitial {
                prepared = try await prepareCatalog.loadInitial()
            } else {
                prepared = try await prepareCatalog.refresh()
            }
            try Task.checkCancellation()
            guard generation == loadGeneration else { return }
            pizzas = prepared.pizzas
            if isInitial {
                initialSource = prepared.source
            }
            state = .loaded
        } catch is CancellationError {
            return
        } catch let urlError as URLError where urlError.code == .cancelled {
            return
        } catch {
            guard generation == loadGeneration else { return }
            state = .failed(Self.presentationMessage(for: error))
        }
    }

    private static func presentationMessage(for error: Error) -> String {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return "Check your internet connection and try again."
            case .timedOut:
                return "The server took too long to respond. Please try again."
            case .cancelled:
                return "The request was cancelled."
            default:
                return "We couldn't reach the pizza service. Please try again."
            }
        }
        if error is DecodingError || error is PizzaMappingError {
            return "The server returned pizza data in an unexpected format."
        }
        if let apiError = error as? APIError {
            return apiError.localizedDescription
        }
        return "Something went wrong while loading pizzas. Please try again."
    }
}
