//
//  NetworkManager.swift
//  Networking
//
//  Created by Niall Quinn on 07/08/2021.
//

import Foundation

protocol Networking {
    func execute<T: Decodable>(_ endpoint: Endpoint,
                               dataType: T.Type,
                               completion: @escaping (Result<T, NetworkingError>) -> Void)
}

class NetworkManager: Networking {

    let session: NetworkSession

    init(session: NetworkSession = URLSession.shared) {
        self.session = session
    }

    func execute<T: Decodable>(_ endpoint: Endpoint,
                               dataType: T.Type,
                               completion: @escaping (Result<T, NetworkingError>) -> Void) {

        guard let urlRequest = endpoint.buildUrlRequest() else {
            completion(.failure(.unableToBuildURL(endpoint.urlString)))
            return
        }

        session.loadData(with: urlRequest) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.unknownResponse))
                return
            }

            switch httpResponse.statusCode {
            case 200...201:
                break
            case 401:
                completion(.failure(.unauthorized))
                return
            case 500:
                completion(.failure(.internalServerError))
                return
            default:
                completion(.failure(.unknownStatusCode))
                return
            }

            if let _ = error {
                completion(.failure(.backendError))
                return
            }

            guard let data = data else {
                completion(.failure(.backendError))
                return
            }

            do {
                let decodedObject = try JSONDecoder().decode(T.self, from: data)

                completion(.success(decodedObject))
            } catch {
                completion(.failure(.parsingError))
            }
        }
    }
}

private extension Endpoint {
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
