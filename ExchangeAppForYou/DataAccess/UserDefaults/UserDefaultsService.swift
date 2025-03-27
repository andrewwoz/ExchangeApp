//
//  UserDefaultsService.swift
//  ExchangeAppForYou
//
//  Created by andy on 3/26/25.
//

import Foundation

protocol UserDefaultsRequest {
    associatedtype Value: Codable
    var key: String { get }
}

protocol UserDefaultsService {
    func save<R: UserDefaultsRequest>(_ value: R.Value, for request: R) throws
    func read<R: UserDefaultsRequest>(_ request: R) throws -> R.Value?
    func remove<R: UserDefaultsRequest>(_ request: R) throws
}

enum UserDefaultsServiceError: Error {
    case encodingFailed
    case decodingFailed
}

final class DefaultUserDefaultsService: UserDefaultsService {
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    static let shared = DefaultUserDefaultsService()

    private init() { }

    func save<R: UserDefaultsRequest>(_ value: R.Value, for request: R) throws {
        do {
            let data = try encoder.encode(value)
            defaults.set(data, forKey: request.key)
        } catch {
            throw UserDefaultsServiceError.encodingFailed
        }
    }

    func read<R: UserDefaultsRequest>(_ request: R) throws -> R.Value? {
        guard let data = defaults.data(forKey: request.key) else {
            return nil
        }

        do {
            return try decoder.decode(R.Value.self, from: data)
        } catch {
            throw UserDefaultsServiceError.decodingFailed
        }
    }

    func remove<R: UserDefaultsRequest>(_ request: R) throws {
        defaults.removeObject(forKey: request.key)
    }
}
