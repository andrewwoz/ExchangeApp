//
//  ServiceError.swift
//  ExchangeAppForYou
//
//  Created by andy on 3/26/25.
//

import Foundation

enum ServiceError<T>: Error where T: Error & Decodable {
    case networkError(NetworkingError)
    case customError(T)
}
