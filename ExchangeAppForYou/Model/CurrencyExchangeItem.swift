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
