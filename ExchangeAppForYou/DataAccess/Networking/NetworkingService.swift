//
//  NetworkingService.swift
//  ExchangeAppForYou
//
//  Created by andy on 3/26/25.
//

import Foundation
import Combine

protocol NetworkingService {
    func performRequest<R: NetworkRequest>(_ request: R) -> AnyPublisher<R.Response, ServiceError<R.ErrorType>>
}

final class DefaultNetworkingService: NetworkingService {
    func performRequest<R: NetworkRequest>(_ request: R) -> AnyPublisher<R.Response, ServiceError<R.ErrorType>> {
        var urlRequest = URLRequest(url: request.url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 5)
        urlRequest.httpMethod = request.httpMethod.rawValue
        urlRequest.allHTTPHeaderFields = request.headers
        
        if let body = request.body {
            do {
                urlRequest.httpBody = try JSONEncoder().encode(body)
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                return Fail(error: .networkError(.invalidRequest))
                    .eraseToAnyPublisher()
            }
        }
        
        return URLSession.shared
            .dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkingError.missingResponse
                }
                
                return try request.parse(data: data, response: httpResponse)
            }
            .mapError { error in
                if let typedError = error as? NetworkingError {
                    return ServiceError<R.ErrorType>.networkError(typedError)
                } else if let customError = error as? R.ErrorType {
                    return ServiceError.customError(customError)
                } else {
                    return ServiceError<R.ErrorType>.networkError(.unknown)
                }
            }
            .eraseToAnyPublisher()
    }
}
