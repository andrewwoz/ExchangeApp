//
//  UserFriendlyError.swift
//  ExchangeAppForYou
//
//  Created by andy on 3/26/25.
//

import Foundation

struct UserFriendlyError: LocalizedError {
    let title: String
    let message: String
    
    var errorDescription: String? {
        return "\(title): \(message)"
    }
}
