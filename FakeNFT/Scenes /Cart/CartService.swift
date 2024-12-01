//
//  CartService.swift
//  FakeNFT
//
//  Created by Sergey Ivanov on 11.11.2024.
//

import Foundation

typealias CartCompletion = (Result<[CartItem], Error>) -> Void

protocol CartService {
    func loadCartItems(orderId: String, completion: @escaping CartCompletion)
    func deleteCartItem(orderId: String, itemId: String, completion: @escaping (Result<Void, Error>) -> Void)
}

final class CartServiceImpl: CartService {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadCartItems(orderId: String, completion: @escaping CartCompletion) {
        let request = CartRequest(orderId: orderId)
        
        networkClient.send(request: request) { [weak self] (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let cartResponse = try decoder.decode(CartResponse.self, from: data)
                    
                    if cartResponse.nfts.isEmpty {
                        print("🛑 Корзина пуста.")
                        completion(.success([]))
                        return
                    }
                    
                    self?.fetchCartItemsDetails(ids: cartResponse.nfts, completion: completion)
                    
                } catch {
                    print("❌ Ошибка декодирования: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("❌ Ошибка загрузки корзины: \(error)")
                completion(.failure(error))
            }
        }
    }

    private func fetchCartItemsDetails(ids: [String], completion: @escaping CartCompletion) {
        let group = DispatchGroup()
        var items: [CartItem] = []
        var encounteredError: Error?
        
        for id in ids {
            group.enter()
            
            let request = NFTRequest(id: id)
            networkClient.send(request: request, type: CartItem.self) { result in
                switch result {
                case .success(let item):
                    print("✅ Успешно загружен товар с ID \(id): \(item)")
                    items.append(item)
                case .failure(let error):
                    print("❌ Ошибка загрузки товара с ID \(id): \(error)")
                    encounteredError = error
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if let error = encounteredError {
                print("❌ Ошибка при загрузке товаров: \(error)")
                completion(.failure(error))
            } else {
                print("✅ Успешно загружено \(items.count) товаров")
                completion(.success(items))
            }
        }
    }

    func deleteCartItem(orderId: String, itemId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        loadCartItems(orderId: orderId) { [weak self] result in
            switch result {
            case .success(let items):
                let updatedNfts = items.filter { $0.id != itemId }.map { $0.id }
                
                let request = DeleteCartItemsRequest(orderId: orderId, nfts: updatedNfts)
                self?.networkClient.send(request: request) { (result: Result<Data, Error>) in
                    switch result {
                    case .success:
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

struct CartRequest: NetworkRequest {
    let orderId: String

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/\(orderId)")
    }
    var httpMethod: HttpMethod { .get }
    var dto: Dto?
}

struct CartResponse: Decodable {
    let nfts: [String]
    let id: String

    enum CodingKeys: String, CodingKey {
        case nfts
        case id
    }
}

struct DeleteCartItemsRequest: NetworkRequest {
    let orderId: String
    let nfts: [String]

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/\(orderId)")
    }
    var httpMethod: HttpMethod { .put }
    var dto: Dto? {
        DeleteItemDto(nfts: nfts)
    }
}

struct DeleteItemDto: Dto {
    let nfts: [String]

    func asDictionary() -> [String: String] {
        return nfts.isEmpty ? [:] : ["nfts": nfts.joined(separator: ",")]
    }
}
