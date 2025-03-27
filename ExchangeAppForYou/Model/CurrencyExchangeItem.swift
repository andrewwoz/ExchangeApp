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
    
    var marketType: String {
        switch self {
        case .crypto:
            return "Crypto"
        case .fiat:
            return "Forex"
        }
    }
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
