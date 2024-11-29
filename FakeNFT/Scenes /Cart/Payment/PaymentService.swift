//
//  PaymentService.swift
//  FakeNFT
//
//  Created by Sergey Ivanov on 12.11.2024.
//

import Foundation

typealias CurrenciesCompletion = (Result<[Currency], Error>) -> Void
typealias PaymentCompletion = (Result<PaymentResponse, Error>) -> Void

protocol PaymentService {
    func fetchCurrencies(completion: @escaping CurrenciesCompletion)
    func fetchCurrencyDetail(currencyId: String, completion: @escaping (Result<Currency, Error>) -> Void)
    func makePayment(orderId: String, currencyId: String, completion: @escaping PaymentCompletion)
}

final class PaymentServiceImpl: PaymentService {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    // MARK: - Fetch all currencies
    func fetchCurrencies(completion: @escaping CurrenciesCompletion) {
        print("🟢 [PaymentService] Начинаем загрузку валют")
        
        let request = CurrenciesRequest()
        networkClient.send(request: request) { [weak self] (result: Result<Data, Error>) in
            guard self != nil else {
                print("🛑 [PaymentService] Сильная ссылка утрачена, загрузка валют не удалась")
                return
            }
            
            switch result {
            case .success(let data):
                print("✅ [PaymentService] Получили данные для валют, размер: \(data.count) байт")
                do {
                    let currencies = try JSONDecoder().decode([Currency].self, from: data)
                    print("✅ [PaymentService] Успешно декодировали валюты: \(currencies.count) шт.")
                    completion(.success(currencies))
                } catch {
                    print("🛑 [PaymentService] Ошибка декодирования данных: \(error.localizedDescription)")
                    completion(.failure(error))
                }
                
            case .failure(let error):
                print("🛑 [PaymentService] Ошибка при загрузке данных: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }

    // MARK: - Fetch currency details
    func fetchCurrencyDetail(currencyId: String, completion: @escaping (Result<Currency, Error>) -> Void) {
        print("🟢 [PaymentService] Начинаем загрузку деталей для валюты с ID: \(currencyId)")
        
        let request = CurrencyDetailRequest(currencyId: currencyId)
        networkClient.send(request: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                print("✅ [PaymentService] Получили данные для валюты, размер: \(data.count) байт")
                do {
                    let currencyDetail = try JSONDecoder().decode(Currency.self, from: data)
                    print("✅ [PaymentService] Успешно декодировали детали валюты: \(currencyDetail)")
                    completion(.success(currencyDetail))
                } catch {
                    print("🛑 [PaymentService] Ошибка декодирования данных для валюты с ID: \(currencyId) - \(error.localizedDescription)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("🛑 [PaymentService] Ошибка при загрузке данных для валюты с ID: \(currencyId) - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }

    // MARK: - Make payment
    func makePayment(orderId: String, currencyId: String, completion: @escaping PaymentCompletion) {
        print("🟢 [PaymentService] Начинаем процесс оплаты для заказа с ID: \(orderId) и валюты с ID: \(currencyId)")
        
        let request = PaymentRequest(orderId: orderId, currencyId: currencyId)
        networkClient.send(request: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                print("✅ [PaymentService] Получили ответ на запрос оплаты, размер: \(data.count) байт")
                do {
                    let paymentResponse = try JSONDecoder().decode(PaymentResponse.self, from: data)
                    print("✅ [PaymentService] Успешно декодирован ответ на оплату: \(paymentResponse)")
                    completion(.success(paymentResponse))
                } catch {
                    print("🛑 [PaymentService] Ошибка декодирования ответа на оплату: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("🛑 [PaymentService] Ошибка при выполнении запроса на оплату: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}

struct PaymentResponse: Decodable {
    let success: Bool
    let orderId: String
    let id: String
}

struct CurrenciesRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/currencies")
    }
    var httpMethod: HttpMethod { .get }
    var dto: Dto? { nil }
}

struct CurrencyDetailRequest: NetworkRequest {
    let currencyId: String

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/currencies/\(currencyId)")
    }
    var httpMethod: HttpMethod { .get }
    var dto: Dto? { nil }
}

struct PaymentRequest: NetworkRequest {
    let orderId: String
    let currencyId: String

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/\(orderId)/payment/\(currencyId)")
    }
    var httpMethod: HttpMethod { .get }
    var dto: Dto? { nil }
}
