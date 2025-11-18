//
//  SpotifyAPIClient.swift
//  SpotifyClone
//
//  Created by ChatGPT on 18/11/2025.
//

import Foundation

final class SpotifyAPIClient {
    static let shared = SpotifyAPIClient()

    private let baseURL = URL(string: "https://api.spotify.com/v1")!
    private let decoder: JSONDecoder

    init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
        self.decoder.keyDecodingStrategy = .useDefaultKeys
        self.decoder.dateDecodingStrategy = .iso8601
    }

    func send<T: Decodable>(
        _ endpoint: Endpoint,
        decoder customDecoder: JSONDecoder? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false) else {
            completion(.failure(ApiError.invalidURL))
            return
        }

        components.queryItems = endpoint.queryItems

        guard let url = components.url else {
            completion(.failure(ApiError.invalidURL))
            return
        }

        AuthManager.shared.createRequest(with: url, type: endpoint.method) { request in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                    if httpResponse.statusCode == 429 {
                        completion(.failure(ApiError.rateLimitExceeded))
                        return
                    }
                    completion(.failure(ApiError.invalidResponse(statusCode: httpResponse.statusCode)))
                    return
                }

                guard let data = data else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }

                let decoder = customDecoder ?? self.decoder

                do {
                    let decoded = try decoder.decode(T.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(error))
                }
            }

            task.resume()
        }
    }
}
