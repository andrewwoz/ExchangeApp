//
//  CurrencyExchangeGateway.swift
//  ExchangeAppForYou
//
//  Created by andy on 3/26/25.
//

import Foundation
import Combine

enum GatewayError: Error {
    case failedToLoad
}

protocol CurrencyExchangeGateway {
    func getCurrencies() -> AnyPublisher<[CurrencyExchangeItem], GatewayError>
    func getCurrencies(forIDs currencyIDs: [String]) -> AnyPublisher<[CurrencyExchangeItem], GatewayError>
    func search(with term: String) -> AnyPublisher<[CurrencyExchangeItem], GatewayError>
}
