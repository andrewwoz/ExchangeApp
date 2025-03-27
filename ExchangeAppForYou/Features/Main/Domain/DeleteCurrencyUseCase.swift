//
//  DeleteCurrencyUseCase.swift
//  ExchangeAppForYou
//
//  Created by andy on 3/26/25.
//

import Foundation
import Combine

protocol DeleteCurrencyUseCase {
    func execute(id: String) -> AnyPublisher<String, UserFriendlyError>
}

struct DeleteCurrencyUseCaseImpl: DeleteCurrencyUseCase {
    let userDefaults: UserDefaultsService
    
    func execute(id: String) -> AnyPublisher<String, UserFriendlyError> {
        do {
            let returnValue = Just(id).setFailureType(to: UserFriendlyError.self).eraseToAnyPublisher()
            guard let ids = try userDefaults.read(FavoriteCurrencies()) else {
                return returnValue
            }
            try userDefaults.save(ids.filter { $0 != id }, for: FavoriteCurrencies())
            return returnValue
        } catch {
            return Fail(error: UserFriendlyError(title: "Failed to remove", message: "Please try again later.")).eraseToAnyPublisher()
        }
    }
}
