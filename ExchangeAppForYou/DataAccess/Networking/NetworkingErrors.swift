//
//  NetworkingErrors.swift
//  ExchangeAppForYou
//
//  Created by andy on 3/26/25.
//

import Foundation

enum NetworkingError: Error {
    case unknown
    case http(code: String)
    case decodingFailed
    case invalidRequest
    case missingResponse
}
