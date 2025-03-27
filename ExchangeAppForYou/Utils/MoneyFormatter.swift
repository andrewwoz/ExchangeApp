//
//  MoneyFormatter.swift
//  ExchangeAppForYou
//
//  Created by andy on 3/27/25.
//

import Foundation

struct MoneyFormatter {
   static func formatMoney(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.decimalSeparator = "."

        if value >= 1 {
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
        } else {
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 8
        }

        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
