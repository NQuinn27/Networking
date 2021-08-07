//
//  Endpoint.swift
//  Networking
//
//  Created by Niall Quinn on 07/08/2021.
//

import Foundation

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
}

struct Endpoint {
    var urlString: String
    var method: HTTPMethod
    var headers: [String: String]

    func buildUrlRequest() -> URLRequest? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        return request
    }
}
