//
//  CurrencySearchViewModel.swift
//  ExchangeAppForYou
//
//  Created by andy on 3/26/25.
//

import Foundation
import Combine

@MainActor
class CurrencySearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var items: [CurrencyExchangeItem] = []
    @Published var error: AlertItem?
    @Published var isLoading: Bool = false
    @Published var shouldDismiss: Bool = false
    
    private var selectionChanges: Set<SelectionChange> = []

    private let searchUseCase: SearchCurrenciesUseCase
    private let saveUseCase: SaveSelectedCurrenciesUseCase
    private let listUseCase: GetListOfCurrenciesUseCase
    private var cancellables = Set<AnyCancellable>()

    init(
        searchUseCase: SearchCurrenciesUseCase,
        saveUseCase: SaveSelectedCurrenciesUseCase,
        listUseCase: GetListOfCurrenciesUseCase
    ) {
        self.searchUseCase = searchUseCase
        self.saveUseCase = saveUseCase
        self.listUseCase = listUseCase

        $searchText
            .removeDuplicates()
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                self?.search(query: query)
            }
            .store(in: &cancellables)
    }

    func search(query: String) {
        guard !query.isEmpty else {
            fetchAllCurrencies()
            return
        }

        isLoading = true

        searchUseCase.execute(query: query)
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveCompletion: { [weak self] _ in self?.isLoading = false })
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.error = AlertItem(title: error.title, message: error.message)
                }
            }, receiveValue: { [weak self] result in
                self?.populateItems(result)
            })
            .store(in: &cancellables)
    }

    func toggleSelection(for item: CurrencyExchangeItem) {
        guard let index = items.firstIndex(where: { $0.universalId == item.universalId }) else { return }
        if let isFavorite = items[index].isFavorite {
            items[index].isFavorite = !isFavorite
        } else {
            items[index].isFavorite = true
        }
        
        if items[index].isFavorite == true {
            selectionChanges.insert(.add(item.universalId))
            selectionChanges.remove(.remove(item.universalId))
        } else {
            selectionChanges.insert(.remove(item.universalId))
            selectionChanges.remove(.add(item.universalId))
        }
    }

    func saveSelection() {
        saveUseCase.execute(changes: selectionChanges)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.error = AlertItem(title: error.title, message: error.message)
                }
            }, receiveValue: { [weak self] _ in
                self?.shouldDismiss = true
            })
            .store(in: &cancellables)
    }
    
    private func fetchAllCurrencies() {
        isLoading = true

        listUseCase.execute()
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveCompletion: { [weak self] _ in
                self?.isLoading = false
            })
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.error = AlertItem(title: error.title, message: error.message)
                }
            }, receiveValue: { [weak self] result in
                self?.populateItems(result)
            })
            .store(in: &cancellables)
    }
    
    private func populateItems(_ items: [CurrencyExchangeItem]) {
        self.items = items.map({ item in
            var mutableItem = item
            if selectionChanges.contains(.add(item.universalId)) {
                mutableItem.isFavorite = true
            } else if selectionChanges.contains(.remove(item.universalId)) {
                mutableItem.isFavorite = false
            }
            return mutableItem
        })
    }
}
