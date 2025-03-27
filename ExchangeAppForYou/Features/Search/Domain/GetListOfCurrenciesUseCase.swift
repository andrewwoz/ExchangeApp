//
//  GetListOfCurrenciesUseCase.swift
//  ExchangeAppForYou
//
//  Created by andy on 3/26/25.
//

import Foundation
import Combine

enum SelectionChanges {
    case added(String)
    case removed(String)
}

protocol GetListOfCurrenciesUseCase {
    func execute() -> AnyPublisher<[CurrencyExchangeItem], UserFriendlyError>
}

struct GetListOfCurrenciesUseCaseImpl: GetListOfCurrenciesUseCase {
    let currencyExchangeRepository: CurrencyExchangeRepository
    let userDefaultsService: UserDefaultsService
    
    func execute() -> AnyPublisher<[CurrencyExchangeItem], UserFriendlyError> {
        currencyExchangeRepository.getCurrencies()
            .map {
                self.markFavoriteItems($0)
                    .sorted { $0.universalId < $1.universalId && $0.quote < $1.quote }
            }
            .mapError { _ in UserFriendlyError(title: "Loading Failed", message: "Please try again later.") }
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
