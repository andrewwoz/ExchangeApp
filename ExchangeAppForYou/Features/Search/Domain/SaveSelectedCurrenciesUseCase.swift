//
//  SaveSelectedCurrenciesUseCase.swift
//  ExchangeAppForYou
//
//  Created by andy on 3/26/25.
//

import Foundation
import Combine

protocol SaveSelectedCurrenciesUseCase {
    func execute(changes: Set<SelectionChange>) -> AnyPublisher<[String], UserFriendlyError>
}

struct FavoriteCurrencies: UserDefaultsRequest {
    typealias Value = [String]
    let key = "favoriteCurrencies"
}

enum SelectionChange: Hashable {
    case add(String)
    case remove(String)
}

struct SaveSelectedCurrenciesUseCaseImpl: SaveSelectedCurrenciesUseCase {
    let userDefaults: UserDefaultsService
    
    func execute(changes: Set<SelectionChange>) -> AnyPublisher<[String], UserFriendlyError> {
        do {
            let ids = try userDefaults.read(FavoriteCurrencies()) ?? []
            
            let filteredIds = ids.filter { id in
                !changes.contains(.remove(id)) || changes.contains(.add(id))
            }
            
            let addedIds = changes.compactMap { change in
                if case .add(let id) = change {
                    return id
                }
                return nil
            }
            
            let favoriteIds = filteredIds + addedIds
            try userDefaults.save(favoriteIds , for: FavoriteCurrencies())
            return Just(favoriteIds).setFailureType(to: UserFriendlyError.self).eraseToAnyPublisher()
        } catch {
            return Fail(error: UserFriendlyError(title: "Error", message: error.localizedDescription)).eraseToAnyPublisher()
        }
    }
}

