//
//  FiatExchangeGateway.swift
//  ExchangeAppForYou
//
//  Created by andy on 3/26/25.
//

import Foundation
import Combine

struct FiatExchangeGateway: CurrencyExchangeGateway {
    let networkingService: NetworkingService
    
    func getCurrencies() -> AnyPublisher<[CurrencyExchangeItem], GatewayError> {
        networkingService
            .performRequest(AllFiatCurrenciesRequest())
            .mapError { _ in GatewayError.failedToLoad }
            .map { $0.map { CurrencyExchangeItem(base: "USD", quote: $0.key, rate: 0, id: $0.key, type: .fiat, isFavorite: nil) }}
            .eraseToAnyPublisher()
    }
    
    func getCurrencies(forIDs currencyIDs: [String]) -> AnyPublisher<[CurrencyExchangeItem], GatewayError> {
        guard !currencyIDs.isEmpty else {
            return Just([]).setFailureType(to: GatewayError.self).eraseToAnyPublisher()
        }
        return networkingService
            .performRequest(RatesByIdsRequest(ids: currencyIDs))
            .mapError { _ in GatewayError.failedToLoad }
            .map { result in
                result.rates.map {
                    CurrencyExchangeItem(base: "USD", quote: $0.key, rate: Double($0.value), id: $0.key, type: .fiat, isFavorite: nil)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func search(with term: String) -> AnyPublisher<[CurrencyExchangeItem], GatewayError> {
        getCurrencies().map { items in
            items.filter { $0.id.lowercased().contains(term.lowercased()) }
        }.eraseToAnyPublisher()
    }
}

struct FiatCurrencyGenericError: Error, Codable {
    let errorMessage: String
}

struct AllFiatCurrenciesRequest: NetworkRequest {
    typealias ErrorType = FiatCurrencyGenericError
    typealias Response = [String: String]
    
    var url: URL = URL(string: "https://openexchangerates.org/api/currencies.json?app_id=2d4c58f4ea9d4b36b6db89188a6c6de6")!
    
    var httpMethod: HTTPMethod = .get
    var body: (any Encodable)?
    var headers: [String : String]?
}

struct RatesListResponse: Codable {
    let rates: [String: Double]
}

struct RatesByIdsRequest: NetworkRequest {
    typealias ErrorType = FiatCurrencyGenericError
    typealias Response = RatesListResponse
    
    let ids: [String]
    
    var url: URL {
        URL(string: "https://openexchangerates.org/api/latest.json?app_id=2d4c58f4ea9d4b36b6db89188a6c6de6&base=USD&symbols=\(ids.joined(separator: ","))")!
    }
    
    var httpMethod: HTTPMethod = .get
    var body: (any Encodable)?
    var headers: [String : String]?
}
