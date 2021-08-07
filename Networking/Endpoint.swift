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
}
