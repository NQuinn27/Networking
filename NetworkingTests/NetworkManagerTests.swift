//
//  NetworkManagerTests.swift
//  NetworkingTests
//
//  Created by Niall Quinn on 07/08/2021.
//

import XCTest
@testable import Networking

private struct Dummy: Codable {
    var name: String
}

class NetworkManagerTests: XCTestCase {

    let urlString = "www.google.com"
    lazy var url = URL(string: urlString)!

    func test_badEndpoint() {
        let mockSession = NetworkSessionMock(data: nil, response: nil, error: nil)
        let sut = NetworkManager(session: mockSession)
        let endpoint = Endpoint(urlString: "È", method: .GET, headers: [:])

        let exp = expectation(description: "Loading")
        var err: NetworkingError?
        sut.execute(endpoint, dataType: Dummy.self) { result in
            switch result {
            case .success:
                XCTFail("Should be a failure here")
            case .failure(let error):
                err = error
            }
            exp.fulfill()
        }

        waitForExpectations(timeout: 3)
        XCTAssertEqual(err, .unableToBuildURL("È"))
    }

    func test_noResponse() {
        let mockSession = NetworkSessionMock(data: nil, response: nil, error: nil)
        let sut = NetworkManager(session: mockSession)

        var error: NetworkingError?
        let exp = expectation(description: "Loading")

        sut.execute { _, err in
            error = err
            exp.fulfill()
        }

        waitForExpectations(timeout: 3)
        XCTAssertEqual(error, .unknownResponse)
    }

    func test_unauthorized() {

        let urlResponse = HTTPURLResponse(url: url, statusCode: 401, httpVersion: "", headerFields: [:])
        let mockSession = NetworkSessionMock(data: nil, response: urlResponse, error: nil)
        let sut = NetworkManager(session: mockSession)

        var error: NetworkingError?
        let exp = expectation(description: "Loading")

        sut.execute { _, err in
            error = err
            exp.fulfill()
        }

        waitForExpectations(timeout: 3)
        XCTAssertEqual(error, .unauthorized)

    }

    func test_500() {

        let urlResponse = HTTPURLResponse(url: url, statusCode: 500, httpVersion: "", headerFields: [:])
        let mockSession = NetworkSessionMock(data: nil, response: urlResponse, error: nil)
        let sut = NetworkManager(session: mockSession)

        var error: NetworkingError?
        let exp = expectation(description: "Loading")

        sut.execute { _, err in
            error = err
            exp.fulfill()
        }

        waitForExpectations(timeout: 3)
        XCTAssertEqual(error, .internalServerError)

    }

    func test_unknown() {
        let urlResponse = HTTPURLResponse(url: url, statusCode: 1000, httpVersion: "", headerFields: [:])
        let mockSession = NetworkSessionMock(data: nil, response: urlResponse, error: nil)
        let sut = NetworkManager(session: mockSession)

        var error: NetworkingError?
        let exp = expectation(description: "Loading")

        sut.execute { _, err in
            error = err
            exp.fulfill()
        }

        waitForExpectations(timeout: 3)
        XCTAssertEqual(error, .unknownStatusCode)
    }

    func test_backendError() {

        enum TestError: Error {
            case error
        }

        let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "", headerFields: [:])
        let mockSession = NetworkSessionMock(data: nil, response: urlResponse, error: TestError.error)
        let sut = NetworkManager(session: mockSession)

        var error: NetworkingError?
        let exp = expectation(description: "Loading")

        sut.execute { _, err in
            error = err
            exp.fulfill()
        }

        waitForExpectations(timeout: 3)
        XCTAssertEqual(error, .backendError)
    }

    func test_goodData() {
        let dummy = Dummy(name: "Name")
        var encoded: Data?
        do {
            encoded = try JSONEncoder().encode(dummy)
        } catch {
            XCTFail()
            return
        }

        let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "", headerFields: [:])
        let mockSession = NetworkSessionMock(data: encoded, response: urlResponse, error: nil)
        let sut = NetworkManager(session: mockSession)

        let exp = expectation(description: "Loading")

        var resultDummy: Dummy?

        sut.execute { dummy, _ in
            resultDummy = dummy
            exp.fulfill()
        }

        waitForExpectations(timeout: 3)
        XCTAssertEqual(resultDummy?.name, "Name")
    }

    func test_fromJson() {
        let json = """
        {"name": "Dummy"}
        """

        let data = Data(json.utf8)

        let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "", headerFields: [:])
        let mockSession = NetworkSessionMock(data: data, response: urlResponse, error: nil)
        let sut = NetworkManager(session: mockSession)

        let exp = expectation(description: "Loading")

        var resultDummy: Dummy?

        sut.execute { dummy, _ in
            resultDummy = dummy
            exp.fulfill()
        }

        waitForExpectations(timeout: 3)
        XCTAssertEqual(resultDummy?.name, "Dummy")
    }

    func test_parsingError() {
        let json = """
        {"nameeeeeeeee": "Dummy"}
        """

        let data = Data(json.utf8)

        let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "", headerFields: [:])
        let mockSession = NetworkSessionMock(data: data, response: urlResponse, error: nil)
        let sut = NetworkManager(session: mockSession)

        let exp = expectation(description: "Loading")
        var error: NetworkingError?

        sut.execute { _, err in
            error = err
            exp.fulfill()
        }

        waitForExpectations(timeout: 3)
        XCTAssertEqual(error, .parsingError)
    }

    func test_noData() {
        let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "", headerFields: [:])
        let mockSession = NetworkSessionMock(data: nil, response: urlResponse, error: nil)
        let sut = NetworkManager(session: mockSession)

        let exp = expectation(description: "Loading")
        var error: NetworkingError?

        sut.execute { _, err in
            error = err
            exp.fulfill()
        }

        waitForExpectations(timeout: 3)
        XCTAssertEqual(error, .backendError)
    }
}

class NetworkSessionMock: NetworkSession {
    var data: Data?
    var error: Error?
    var response: URLResponse?

    init(data: Data?, response: URLResponse?, error: Error?) {
        self.data = data
        self.response = response
        self.error = error
    }

    func loadData(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        completionHandler(data, response, error)
    }
}

private extension NetworkManager {
    func execute(completion: @escaping (Dummy?, NetworkingError?) -> Void) {
        execute(Endpoint(urlString: "www.google.com",
                         method: .GET,
                         headers: [:]),
                dataType: Dummy.self) { result in
            switch result {
            case .success(let dummy):
                completion(dummy, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}
