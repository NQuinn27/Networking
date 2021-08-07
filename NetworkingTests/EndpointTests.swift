//
//  EndpointTests.swift
//  NetworkingTests
//
//  Created by Niall Quinn on 07/08/2021.
//

import XCTest
@testable import Networking

class EndpointTests: XCTestCase {

    func test_buildUrlRequest() {
        let urlString = "http://example.com"
        let endpoint = Endpoint(urlString: urlString,
                                method: .GET,
                                headers: ["aKey": "aValue",
                                          "anotherKey": "anotherValue"])

        let urlRequest = endpoint.buildUrlRequest()

        XCTAssertNotNil(urlRequest)
        XCTAssertEqual(urlRequest?.url, URL(string: urlString)!)
        XCTAssertEqual(urlRequest?.value(forHTTPHeaderField: "aKey"), "aValue")
        XCTAssertEqual(urlRequest?.value(forHTTPHeaderField: "anotherKey"), "anotherValue")
        XCTAssertEqual(urlRequest?.httpMethod, HTTPMethod.GET.rawValue)
    }

    func test_badURL() {
        let urlString = "http://example.com/ó" 
        let endpoint = Endpoint(urlString: urlString,
                                method: .GET,
                                headers: [:])
        let urlRequest = endpoint.buildUrlRequest()
        XCTAssertNil(urlRequest)
    }

}
