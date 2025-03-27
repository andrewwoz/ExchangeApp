//
//  CurrencyExchangeItem.swift
//  ExchangeAppForYou
//
//  Created by andy on 3/26/25.
//

import Foundation

enum CurrencyType: String {
    case crypto
    case fiat
}

struct CurrencyExchangeItem: Equatable {
    let base: String
    let quote: String
    let rate: Double
    let id: String
    let type: CurrencyType
    var isFavorite: Bool?
    
    var universalId: String {
        "\(type)_\(id)"
    }
}

extension CurrencyExchangeItem {
    static var previewFiat: [CurrencyExchangeItem] {
        [.init(base: "EUR", quote: "USD", rate: 1.08, id: "1", type: .fiat, isFavorite: nil), .init(base: "UAH", quote: "USD", rate: 0.1, id: "2", type: .fiat, isFavorite: nil), .init(base: "AED", quote: "USD", rate: 0.27, id: "3", type: .fiat, isFavorite: nil)]
    }
    
    static var previewCrypto: [CurrencyExchangeItem] {
        []
        // [.init(base: "BTC", quote: "USD", rate: 80000, id: "1", type: .crypto, isFavorite: nil), .init(base: "ETH", quote: "USD", rate: 2000, id: "2", type: .crypto, isFavorite: nil), .init(base: "BNB", quote: "USD", rate: 150, id: "3", type: .crypto, isFavorite: nil)]
    }
}
