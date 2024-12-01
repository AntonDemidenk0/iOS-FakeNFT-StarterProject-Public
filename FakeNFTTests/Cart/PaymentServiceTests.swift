//
//  PaymentServiceTests.swift
//  FakeNFT
//
//  Created by Sergey Ivanov on 25.11.2024.
//

import XCTest
@testable import FakeNFT

final class PaymentServiceTests: XCTestCase {
    private var paymentService: PaymentServiceImpl!
    private var networkClientMock: NetworkClientMock!

    override func setUp() {
        super.setUp()
        networkClientMock = NetworkClientMock()
        paymentService = PaymentServiceImpl(networkClient: networkClientMock)
    }

    override func tearDown() {
        paymentService = nil
        networkClientMock = nil
        super.tearDown()
    }

    /// Успешная загрузка валют
    func testFetchCurrencies_Success() {
        // Arrange
        let mockData = """
        [
            { "id": "1", "title": "USD", "name": "Dollar", "image": "url1" },
            { "id": "2", "title": "EUR", "name": "Euro", "image": "url2" }
        ]
        """.data(using: .utf8)!
        networkClientMock.mockData = mockData

        let expectation = expectation(description: "Currencies fetched successfully")

        // Act
        paymentService.fetchCurrencies { result in
            // Assert
            switch result {
            case .success(let currencies):
                XCTAssertEqual(currencies.count, 2)
                XCTAssertEqual(currencies[0].title, "USD")
                XCTAssertEqual(currencies[1].title, "EUR")
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success, got failure")
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    /// Ошибка загрузки валют
    func testFetchCurrencies_Failure() {
        // Arrange
        let mockError = NetworkClientError.httpStatusCode(500)
        networkClientMock.mockError = mockError

        let expectation = expectation(description: "Currencies fetch failed")

        // Act
        paymentService.fetchCurrencies { result in
            // Assert
            switch result {
            case .success:
                XCTFail("Expected failure, got success")
            case .failure(let error):
                XCTAssertTrue(error is NetworkClientError)
                if case NetworkClientError.httpStatusCode(let statusCode) = error {
                    XCTAssertEqual(statusCode, 500)
                } else {
                    XCTFail("Expected httpStatusCode error, got \(error)")
                }
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1.0)
    }
    
    /// Тесты для метода `fetchCurrencyDetail`
    func testFetchCurrencyDetail_Success() {
        // Arrange
        let mockData = """
        { "id": "1", "title": "USD", "name": "Dollar", "image": "url1" }
        """.data(using: .utf8)!
        networkClientMock.mockData = mockData

        let expectation = expectation(description: "Currency details fetched successfully")

        // Act
        paymentService.fetchCurrencyDetail(currencyId: "1") { result in
            // Assert
            switch result {
            case .success(let currency):
                XCTAssertEqual(currency.id, "1")
                XCTAssertEqual(currency.title, "USD")
                XCTAssertEqual(currency.name, "Dollar")
                XCTAssertEqual(currency.image, "url1")
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success, got failure")
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    func testFetchCurrencyDetail_Failure() {
        // Arrange
        let mockError = NetworkClientError.httpStatusCode(404)
        networkClientMock.mockError = mockError

        let expectation = expectation(description: "Currency details fetch failed")

        // Act
        paymentService.fetchCurrencyDetail(currencyId: "1") { result in
            // Assert
            switch result {
            case .success:
                XCTFail("Expected failure, got success")
            case .failure(let error):
                XCTAssertTrue(error is NetworkClientError)
                if case NetworkClientError.httpStatusCode(let statusCode) = error {
                    XCTAssertEqual(statusCode, 404)
                } else {
                    XCTFail("Expected httpStatusCode error, got \(error)")
                }
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    /// Тесты для метода `makePayment`
    func testMakePayment_Success() {
        // Arrange
        let mockData = """
        { "success": true, "orderId": "123", "id": "456" }
        """.data(using: .utf8)!
        networkClientMock.mockData = mockData

        let expectation = expectation(description: "Payment completed successfully")

        // Act
        paymentService.makePayment(orderId: "123", currencyId: "USD") { result in
            // Assert
            switch result {
            case .success(let response):
                XCTAssertTrue(response.success)
                XCTAssertEqual(response.orderId, "123")
                XCTAssertEqual(response.id, "456")
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success, got failure")
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    func testMakePayment_Failure() {
        // Arrange
        let mockError = NetworkClientError.httpStatusCode(500)
        networkClientMock.mockError = mockError

        let expectation = expectation(description: "Payment failed")

        // Act
        paymentService.makePayment(orderId: "123", currencyId: "USD") { result in
            // Assert
            switch result {
            case .success:
                XCTFail("Expected failure, got success")
            case .failure(let error):
                XCTAssertTrue(error is NetworkClientError)
                if case NetworkClientError.httpStatusCode(let statusCode) = error {
                    XCTAssertEqual(statusCode, 500)
                } else {
                    XCTFail("Expected httpStatusCode error, got \(error)")
                }
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1.0)
    }
    
    func testFetchCurrencies_EmptyData() {
        // Arrange
        let mockData = "[]".data(using: .utf8)!
        networkClientMock.mockData = mockData

        let expectation = expectation(description: "Currencies fetched successfully but empty")

        // Act
        paymentService.fetchCurrencies { result in
            // Assert
            switch result {
            case .success(let currencies):
                XCTAssertEqual(currencies.count, 0)
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success, got failure")
            }
        }

        waitForExpectations(timeout: 1.0)
    }
    
    func testFetchCurrencies_NetworkError() {
        // Arrange
        let mockError = URLError(.notConnectedToInternet)
        networkClientMock.mockError = mockError

        let expectation = expectation(description: "Network error handled")

        // Act
        paymentService.fetchCurrencies { result in
            // Assert
            switch result {
            case .success:
                XCTFail("Expected failure, got success")
            case .failure(let error):
                XCTAssertTrue((error as? URLError)?.code == .notConnectedToInternet)
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1.0)
    }
}
