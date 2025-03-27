//
//  EmptyExchangeGateway.swift
//  ExchangeAppForYou
//
//  Created by andy on 3/27/25.
//

import Foundation
import Combine

struct EmptyExchangeGateway: CurrencyExchangeGateway {
    func getCurrencies() -> AnyPublisher<[CurrencyExchangeItem], GatewayError> {
        Just([]).setFailureType(to: GatewayError.self).eraseToAnyPublisher()
    }
    
    func getCurrencies(forIDs currencyIDs: [String]) -> AnyPublisher<[CurrencyExchangeItem], GatewayError> {
        Just([]).setFailureType(to: GatewayError.self).eraseToAnyPublisher()
    }
    
    func search(with term: String) -> AnyPublisher<[CurrencyExchangeItem], GatewayError> {
        Just([]).setFailureType(to: GatewayError.self).eraseToAnyPublisher()
    }
}
