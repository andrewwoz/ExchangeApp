//
//  SaveSelectedCurrenciesUseCase.swift
//  ExchangeAppForYou
//
//  Created by andy on 3/26/25.
//

import Foundation
import Combine

protocol SaveSelectedCurrenciesUseCase {
    func execute(ids: [String]) -> AnyPublisher<[String], UserFriendlyError>
}

struct FavoriteCurrencies: UserDefaultsRequest {
    typealias Value = [String]
    let key = "favoriteCurrencies"
}

struct SaveSelectedCurrenciesUseCaseImpl: SaveSelectedCurrenciesUseCase {
    let userDefaults: UserDefaultsService
    
    func execute(ids: [String]) -> AnyPublisher<[String], UserFriendlyError> {
        do {
            try userDefaults.save(ids, for: FavoriteCurrencies())
            return Just(ids).setFailureType(to: UserFriendlyError.self).eraseToAnyPublisher()
        } catch {
            return Fail(error: UserFriendlyError(title: "Error", message: error.localizedDescription)).eraseToAnyPublisher()
        }
    }
}

