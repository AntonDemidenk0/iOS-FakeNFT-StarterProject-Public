//
//  NetworkClientMock.swift
//  FakeNFT
//
//  Created by Sergey Ivanov on 25.11.2024.
//

import Foundation
@testable import FakeNFT

final class NetworkClientMock: NetworkClient {
    // Переменные для имитации ответов
    var mockData: Data?
    var mockError: Error?
    var capturedRequest: NetworkRequest?

    @discardableResult
    func send(request: NetworkRequest,
              completionQueue: DispatchQueue = .main,
              onResponse: @escaping (Result<Data, Error>) -> Void) -> NetworkTask? {
        capturedRequest = request
        
        completionQueue.async {
            if let error = self.mockError {
                onResponse(.failure(error))
            } else if let data = self.mockData {
                onResponse(.success(data))
            } else {
                onResponse(.failure(NetworkClientError.urlSessionError))
            }
        }
        
        return nil
    }

    @discardableResult
    func send<T: Decodable>(request: NetworkRequest,
                            type: T.Type,
                            completionQueue: DispatchQueue = .main,
                            onResponse: @escaping (Result<T, Error>) -> Void) -> NetworkTask? {
        capturedRequest = request
        
        completionQueue.async {
            if let error = self.mockError {
                onResponse(.failure(error))
            } else if let data = self.mockData {
                do {
                    let decodedObject = try JSONDecoder().decode(type, from: data)
                    onResponse(.success(decodedObject))
                } catch {
                    onResponse(.failure(NetworkClientError.parsingError))
                }
            } else {
                onResponse(.failure(NetworkClientError.urlSessionError))
            }
        }
        
        return nil
    }
}
