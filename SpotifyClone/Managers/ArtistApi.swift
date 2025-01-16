//
//  ArtistApi.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//


import Foundation
import UIKit

final class ArtistApiCaller {

    static let shared = ArtistApiCaller()

    private struct Constants {
        static let artistBaseUrl = "https://api.spotify.com/v1/artists"
        static let baseAPIUrl = "https://api.spotify.com/v1"
    }

    private let decoder: JSONDecoder

    private init() {
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .useDefaultKeys
        self.decoder.dateDecodingStrategy = .iso8601
    }


    private func constructURL(base: String, parameters: [String: String]) -> URL? {
        var components = URLComponents(string: base)
        components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        return components?.url
    }


    func getArtistDetails(
        artistID: String,
        completion: @escaping (Result<SpotifyArtistsDetailResponse, Error>) -> Void
    ) {
        guard let url = URL(string: "\(Constants.artistBaseUrl)/\(artistID)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        performRequest(
            url: url,
            responseType: SpotifyArtistsDetailResponse.self,
            completion: completion
        )
    }


    func getSeveralArtists(
        artistIDs: [String],
        completion: @escaping (Result<SpotifyArtistsResponse, Error>) -> Void
    ) {
        guard let url = constructURL(
            base: Constants.artistBaseUrl,
            parameters: ["ids": artistIDs.joined(separator: ",")]
        ) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        performRequest(
            url: url,
            responseType: SpotifyArtistsResponse.self,
            completion: completion
        )
    }

  
    func getArtistAlbums(
        artistID: String,
        completion: @escaping (Result<SpotifyArtistsAlbumsResponse, Error>) -> Void
    ) {
        guard let url = URL(string: "\(Constants.artistBaseUrl)/\(artistID)/albums") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        performRequest(
            url: url,
            responseType: SpotifyArtistsAlbumsResponse.self,
            completion: completion
        )
    }



    func getArtistsTopTracks(
        for artistID: String,
        completion: @escaping (Result<SpotifyArtistsTopTracksResponse, Error>) -> Void
    ) {
        guard let url = URL(string: "\(Constants.artistBaseUrl)/\(artistID)/top-tracks") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        performRequest(
            url: url,
            responseType: SpotifyArtistsTopTracksResponse.self,
            completion: completion
        )
    }

    func getRelatedArtists(
        artistID: String,
        completion: @escaping (Result<SpotifyArtistRelatedArtistsResponse, Error>) -> Void
    ) {
        guard let url = URL(string: "\(Constants.artistBaseUrl)/\(artistID)/related-artists") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        performRequest(
            url: url,
            responseType: SpotifyArtistRelatedArtistsResponse.self,
            completion: completion
        )
    }
    

    func searchArtists(
        query: String,
        completion: @escaping (Result<[Artist], Error>) -> Void
    ) {
        guard let url = constructURL(
            base: "\(Constants.baseAPIUrl)/search",
            parameters: [
                "q": query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "",
                "type": "artist",
                "limit": "10"
            ]
        ) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        performRequest(url: url, responseType: SpotifySearchResponse.self) { result in
            switch result {
            case .success(let response):
                completion(.success(response.artists.items))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    

    func searchArtistByName(
        name: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        searchArtists(query: name) { result in
            switch result {
            case .success(let artists):
                if let firstArtist = artists.first?.id {
                    completion(.success(firstArtist))
                } else {
                    completion(.failure(NSError(domain: "Artist not found", code: 404, userInfo: nil)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
   
    
    
    // MARK: - Helper Methods
    private func performRequest<T: Decodable>(
        url: URL?,
        responseType: T.Type,
        retryCount: Int = 3,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let apiURL = url else {
            completion(.failure(ApiError.invalidURL))
            return
        }
        
        AuthManager.shared.createRequest(with: apiURL,type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("Status Code: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 429 {
                        if let retryAfterString = httpResponse.value(forHTTPHeaderField: "Retry-After"),
                           let retryAfter = Double(retryAfterString) {
                            print("Rate limit exceeded. Retrying after \(retryAfter) seconds.")
                            
                            DispatchQueue.main.async {
                                let alert = UIAlertController(
                                    title: "Rate Limit Exceeded",
                                    message: "Please wait for \(Int(retryAfter)) seconds before trying again.",
                                    preferredStyle: .alert
                                )
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                if let viewController = self.topMostViewController() {
                                    viewController.present(alert, animated: true, completion: nil)
                                }
                            }
                            
                           DispatchQueue.global().asyncAfter(deadline: .now() + retryAfter) {
                                self.performRequest(
                                    url: url,
                                    responseType: responseType,
                                    retryCount: retryCount - 1,
                                    completion: completion
                                )
                            }
                        }
                        return
                    }
                    
                    guard (200...299).contains(httpResponse.statusCode) else {
                        completion(.failure(ApiError.failedToGetData))
                        return
                    }
                }
                
                // Debugging: Log raw data
//                if let jsonString = String(data: data, encoding: .utf8) {
//                    print("Response JSON: \(jsonString)")
//                }
                
                do {
                    let result = try JSONDecoder().decode(responseType, from: data)
                    completion(.success(result))
                } catch {
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Raw Response: \(responseString)")
                    }
                    completion(.failure(ApiError.decodingError(error.localizedDescription)))
                }
            }
            task.resume()
        }
    }
    
    // Helper function to get the top-most view controller
    func topMostViewController() -> UIViewController? {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            var topController = window.rootViewController
            
            while let presentedVC = topController?.presentedViewController {
                topController = presentedVC
            }
            
            return topController
        }
        return nil
    }
}

    

enum ArtistApiError : LocalizedError {
    case invalidURL
    case invalidResponse(statusCode: Int)
    case decodingError
    case unableToComplete(description: String)
    case unknownError(error: Error)
    case jsonParsingFailure
    case decodeDataError
    
    var errorDescription: String? {
        switch self {
        case .decodeDataError: return "Faild to decode data"
        case .invalidURL:
            return "The URL provided was invalid."
        case .invalidResponse(let statusCode):
            return "Received invalid response from server with status code \(statusCode)."
        case .decodingError:
            return "Failed to decode the response."
        case .unableToComplete(let description):
            return "Unable to complete the request: \(description)"
        case .unknownError(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        case .jsonParsingFailure:
            return "Failed to parse JSON data."
        }
    }
}


