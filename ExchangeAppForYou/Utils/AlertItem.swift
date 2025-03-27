//
//  AlertItem.swift
//  ExchangeAppForYou
//
//  Created by andy on 3/27/25.
//

import Foundation

struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}
