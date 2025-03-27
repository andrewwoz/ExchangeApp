//
//  CryptoExchangeGateway.swift
//  ExchangeAppForYou
//
//  Created by andy on 3/26/25.
//

import Foundation
import Combine

struct CryptoExchangeGateway: CurrencyExchangeGateway {
    let networkingService: NetworkingService
    
    func getCurrencies() -> AnyPublisher<[CurrencyExchangeItem], GatewayError> {
        networkingService
            .performRequest(AllCryptoCurrenciesRequest())
            .mapError { _ in GatewayError.failedToLoad }
            .map {
                $0.map { CurrencyExchangeItem(base: "USD", quote: $0.id, rate: 0, id: $0.id, type: .crypto, isFavorite: nil)}
            }
            .eraseToAnyPublisher()
    }
    
    func getCurrencies(forIDs currencyIDs: [String]) -> AnyPublisher<[CurrencyExchangeItem], GatewayError> {
        networkingService
            .performRequest(CryptoRatesByIdsRequest(ids: currencyIDs))
            .mapError { _ in GatewayError.failedToLoad }
            .map {
                $0.map { CurrencyExchangeItem(base: "USD", quote: $0.key, rate: Double($0.value["usd"] ?? 0), id: $0.key, type: .crypto, isFavorite: nil) }
            }
            .eraseToAnyPublisher()
    }
    
    func search(with term: String) -> AnyPublisher<[CurrencyExchangeItem], GatewayError> {
        networkingService
            .performRequest(CryptoSearchRequest(term: term))
            .mapError { _ in GatewayError.failedToLoad }
            .map {
                $0.coins.map { CurrencyExchangeItem(base: "USD", quote: $0.id, rate: 0, id: $0.id, type: .crypto, isFavorite: nil) }
            }
            .eraseToAnyPublisher()
    }
}

struct CryptoCurrencyGenericError: Error, Codable {
    let errorMessage: String
}

struct CryptoListItem: Codable {
    let id: String
}

struct AllCryptoCurrenciesRequest: NetworkRequest {
    typealias ErrorType = CryptoCurrencyGenericError
    typealias Response = [CryptoListItem]
    
    var url: URL = URL(string: "https://api.coingecko.com/api/v3/coins/list")!
    
    var httpMethod: HTTPMethod = .get
    var body: (any Encodable)?
    var headers: [String : String]?
}

struct CryptoRatesByIdsRequest: NetworkRequest {
    typealias ErrorType = FiatCurrencyGenericError
    typealias Response = [String: [String: Double]]
    
    let ids: [String]
    
    var url: URL {
        URL(string: "https://api.coingecko.com/api/v3/simple/price?ids=\(ids.joined(separator: ","))&vs_currencies=usd")!
    }
    
    var httpMethod: HTTPMethod = .get
    var body: (any Encodable)?
    var headers: [String : String]?
}

struct CryptoSearchResponse: Codable {
    struct Coin: Codable {
        let id: String
    }
    let coins: [Coin]
}

struct CryptoSearchRequest: NetworkRequest {
    typealias ErrorType = FiatCurrencyGenericError
    typealias Response = CryptoSearchResponse
    
    let term: String
    
    var url: URL {
        URL(string: "https://api.coingecko.com/api/v3/search?query=\(term)")!
    }
    
    var httpMethod: HTTPMethod = .get
    var body: (any Encodable)?
    var headers: [String : String]?
}
