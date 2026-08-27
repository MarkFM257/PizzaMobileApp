//
//  CatalogSceneView.swift
//  PizzaMobileApp
//

import SwiftUI

struct CatalogSceneView: View {
    @State private var viewModel: PizzaDetailViewModel

    let pizzas: [Pizza]
    let isPresented: Bool
    let model: CatalogSceneModel

    init(
        pizzas: [Pizza],
        isPresented: Bool,
        model: CatalogSceneModel
    ) {
        self.pizzas = pizzas
        self.isPresented = isPresented
        self.model = model
        _viewModel = State(
            initialValue: model.makeDetailViewModel(for: pizzas)
        )
    }

    var body: some View {
        PizzaDetailView(
            viewModel: viewModel,
            imageStore: model.imageStore,
            isPresented: isPresented
        )
        .onChange(of: pizzas, initial: true) { _, pizzas in
            model.imageStore.hydrateCatalogImages(for: pizzas)
            if viewModel.pizzas != pizzas {
                viewModel.updateCatalog(pizzas)
            }
        }
    }
}
