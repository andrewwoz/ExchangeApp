//
//  DeleteCurrencyUseCase.swift
//  ExchangeAppForYouTests
//
//  Created by andy on 3/26/25.
//

import XCTest
import Combine
@testable import ExchangeAppForYou

final class DeleteCurrencyUseCaseTest: XCTestCase {

    func testExample() throws {
        let defaultsMock = UserDefaultsMock()
        try defaultsMock.save(["1"], for: FavoriteCurrencies())
        let removeUseCase = DeleteCurrencyUseCaseImpl(userDefaults: defaultsMock)
        
        let expectation = XCTestExpectation(description: "Remove currency")
        
        let cancellable = removeUseCase.execute(id: "1").sink { _ in
            expectation.fulfill()
        } receiveValue: { _ in }

        wait(for: [expectation])
        XCTAssertEqual(defaultsMock.store[FavoriteCurrencies().key] as? Array<String>, [])
    }

}

class UserDefaultsMock: UserDefaultsService {
    var store: [String: Any] = [:]
    
    func save<R>(_ value: R.Value, for request: R) throws where R : UserDefaultsRequest {
        store[request.key] = value
    }

    func read<R>(_ request: R) throws -> R.Value? where R : UserDefaultsRequest {
        store[request.key] as? R.Value
    }

    func remove<R>(_ request: R) throws where R : UserDefaultsRequest {
        store[request.key] = nil
    }
}


