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
                                Text(item.quote.capitalized)
                                    .font(.headline)
                                Text(item.type.marketType.capitalized)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Text("$" + MoneyFormatter.formatMoney(item.rate))
                                .font(.subheadline)
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
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
            .alert(item: $viewModel.alert) { alert in
                Alert(
                    title: Text(alert.title),
                    message: Text(alert.message),
                    dismissButton: .default(Text("OK"))
                )
            }
            .navigationDestination(for: AppCoordinator.Route.self) { route in
                switch route {
                case .currencySearch:
                    coordinator.buildCurrencySearchView()
                }
            }
        }
        .onAppear {
            viewModel.load()
        }
        .onChange(of: coordinator.path) { previous, newPath in
            // Refresh on pop
            if previous.count > newPath.count {
                viewModel.load()
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let item = viewModel.currencies[index]
                viewModel.remove(item)
            }
        }
    }
}
