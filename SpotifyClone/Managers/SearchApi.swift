//
//  SearchApi.swift
//  SpotifyClone
//
//  Created by stephen chacha on 03/01/2025.
//
import Foundation

final class SearchApi {
    private let baseURL = "https://api.spotify.com/v1"
    
    static let shared = SearchApi()
    
    private init() {}
    
    /// Perform a search with a dynamic query
    func performSearch(query: String, completion: @escaping (Result<SearchResponses, Error>) -> Void) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Query cannot be empty"])))
            return
        }
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "\(baseURL)/search?q=\(encodedQuery)&type=album,artist,track,show,episode,audiobook&limit=3"
        
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
                
        
        AuthManager.shared.createRequest(with: url, type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                do {
                    let response = try JSONDecoder().decode(SearchResponses.self, from: data)
                    completion(.success(response))
                } catch {
                    print("Error decoding SearchResponses: \(error)")
                    print(error)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    private func constructURL(base: String, parameters: [String: String]) -> URL? {
        var components = URLComponents(string: base)
        components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        return components?.url
    }

}
