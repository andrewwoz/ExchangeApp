//
//  NetworkRequest.swift
//  ExchangeAppForYou
//
//  Created by andy on 3/26/25.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol NetworkRequest {
    associatedtype Response: Decodable
    associatedtype ErrorType: Error, Decodable
    var url: URL { get }
    var httpMethod: HTTPMethod { get }
    var body: Encodable? { get }
    var headers: [String: String]? { get }
    
    func parse(data: Data, response: HTTPURLResponse) throws -> Response
}

extension NetworkRequest {
    func parse(data: Data, response: HTTPURLResponse) throws -> Response {
        if response.statusCode >= 400, let error = try? JSONDecoder().decode(ErrorType.self, from: data) {
            throw error
        }
        
        if response.statusCode >= 400 {
            throw NetworkingError.http(code: "\(response.statusCode)")
        }
        
        return try parse(data: data)
    }
    
    private func parse(data: Data) throws -> Response {
        let decoder = JSONDecoder()
        let response: Response
        do {
            response = try decoder.decode(Response.self, from: data)
        } catch {
            throw NetworkingError.decodingFailed
        }
        return response
    }
}
