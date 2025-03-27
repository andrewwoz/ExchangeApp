//
//  MainScreenView.swift
//  ExchangeAppForYou
//
//  Created by andy on 3/26/25.
//

import SwiftUI

struct MainScreenView: View {
    @StateObject var viewModel: MainScreenViewModel
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.path)  {
            ZStack {
                List {
                    ForEach(viewModel.currencies, id: \.universalId) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(item.base) → \(item.quote)")
                                    .font(.headline)
                                Text("Type: \(item.type.rawValue.capitalized)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Text(String(format: "%.4f", item.rate))
                                .font(.subheadline)
                        }
                    }
                    .onDelete(perform: delete)
                }
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
            .navigationTitle("Exchange Rates")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        coordinator.showAddCurrency()
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert(item: Binding(
                get: {
                    viewModel.errorMessage.map { AlertItem(message: $0) }
                },
                set: { _ in }
            )) { alert in
                Alert(title: Text("Error"), message: Text(alert.message), dismissButton: .default(Text("OK")))
            }
            .navigationDestination(for: AppCoordinator.Route.self) { route in
                switch route {
                case .currencySearch:
                    coordinator.buildCurrencySearchView()
                }
            }
        }
        .onAppear {
            viewModel.start()
        }
        .onChange(of: coordinator.path) { _, newPath in
            // Refresh on pop
            viewModel.start()
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            let item = viewModel.currencies[index]
            viewModel.remove(item)
        }
    }
}

struct AlertItem: Identifiable {
    let id = UUID()
    let message: String
}

