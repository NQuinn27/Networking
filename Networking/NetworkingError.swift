//
//  NetworkingError.swift
//  Networking
//
//  Created by Niall Quinn on 07/08/2021.
//

import Foundation

enum NetworkingError: Error, Equatable {
    case unableToBuildURL(String)
    case unauthorized
    case internalServerError
    case unknownResponse
    case unknownStatusCode
    case backendError
    case parsingError
}
