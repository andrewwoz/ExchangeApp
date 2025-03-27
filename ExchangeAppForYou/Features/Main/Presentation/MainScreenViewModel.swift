//
//  MainScreenViewModel.swift
//  ExchangeAppForYou
//
//  Created by andy on 3/26/25.
//

import Combine
import SwiftUI


@MainActor
class MainScreenViewModel: ObservableObject {
    @Published var currencies: [CurrencyExchangeItem] = []
    @Published var alert: AlertItem?
    @Published var isLoading: Bool = false
    
    private let observeUseCase: ObserveSelectedCurrenciesUseCase
    private let deleteUseCase: DeleteCurrencyUseCase

    private var observeToken: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()

    init(
        observeUseCase: ObserveSelectedCurrenciesUseCase,
        deleteUseCase: DeleteCurrencyUseCase
    ) {
        self.observeUseCase = observeUseCase
        self.deleteUseCase = deleteUseCase
    }

    func load() {
        isLoading = true
        observeToken?.cancel()
        observeToken = nil
        observeToken = observeUseCase.observe()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.alert = AlertItem(title: error.title, message: error.message)
                }
            }, receiveValue: { [weak self] items in
                self?.isLoading = false
                self?.currencies = items
            })
    }
    
    func remove(_ item: CurrencyExchangeItem) {
        deleteUseCase.execute(id: item.universalId)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.alert = AlertItem(title: error.title, message: error.message)
                }
            }, receiveValue: { [weak self] _ in
                // Restart observing
                self?.load()
            })
            .store(in: &cancellables)
    }
}
