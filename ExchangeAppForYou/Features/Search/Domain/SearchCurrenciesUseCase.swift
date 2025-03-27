//
//  SearchCurrenciesUseCase.swift
//  ExchangeAppForYou
//
//  Created by andy on 3/26/25.
//

import Foundation
import Combine

protocol SearchCurrenciesUseCase {
    func execute(query: String) -> AnyPublisher<[CurrencyExchangeItem], UserFriendlyError>
}

struct SearchCurrenciesUseCaseImpl: SearchCurrenciesUseCase {
    let currencyExchangeRepository: CurrencyExchangeRepository
    let userDefaultsService: UserDefaultsService
    
    func execute(query: String) -> AnyPublisher<[CurrencyExchangeItem], UserFriendlyError> {
        currencyExchangeRepository
            .search(with: query)
            .map {
                self.markFavoriteItems($0)
                    .sorted { $0.universalId < $1.universalId && $0.quote < $1.quote }
            }
            .mapError { _ in UserFriendlyError(title: "Search Failed", message: "Try again later.") }
            .eraseToAnyPublisher()
    }
    
    private func markFavoriteItems(_ items: [CurrencyExchangeItem]) -> [CurrencyExchangeItem] {
        do {
            let favoriteItemsIds = try userDefaultsService.read(FavoriteCurrencies())
            
            return items.map { item in
                var mutableItem = item
                mutableItem.isFavorite = favoriteItemsIds?.contains(item.universalId)
                return mutableItem
            }
        } catch {
            return items
        }
    }
}
