//
//  ArtistApi.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//


import Foundation

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

    // MARK: - Helper Methods

    private func performRequest<T: Decodable>(
        url: URL?,
        responseType: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let apiURL = url else {
            completion(.failure(ApiError.invalidURL))
            return
        }
        AuthManager.shared.createRequest(with: apiURL, type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(error ?? ApiError.failedToGetData))
                    return
                }
                
                do {
                    let response = try self.decoder.decode(T.self, from: data)
                    completion(.success(response))
                } catch {
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

        performRequest(url: url, responseType: SpotifyArtistsResponse.self, completion: completion)
    }

    func getArtistDetails(
        artistID: String,
        completion: @escaping (Result<SpotifyArtistsDetailResponse, Error>) -> Void
    ) {
        guard let url = URL(string: "\(Constants.artistBaseUrl)/\(artistID)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        performRequest(url: url, responseType: SpotifyArtistsDetailResponse.self, completion: completion)
    }

    func getArtistAlbums(
        artistID: String,
        completion: @escaping (Result<SpotifyArtistsAlbumsResponse, Error>) -> Void
    ) {
        guard let url = URL(string: "\(Constants.artistBaseUrl)/\(artistID)/albums") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        performRequest(url: url, responseType: SpotifyArtistsAlbumsResponse.self, completion: completion)
    }



    func getArtistsTopTracks(
        for artistID: String,
        market: String = "US",
        completion: @escaping (Result<SpotifyArtistsTopTracksResponse, Error>) -> Void
    ) {
        guard let url = constructURL(
            base: "\(Constants.artistBaseUrl)/\(artistID)/top-tracks",
            parameters: ["market": market]
        ) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        performRequest(url: url, responseType: SpotifyArtistsTopTracksResponse.self, completion: completion)
    }

    func getArtistsRelatedArtists(
        artistID: String,
        completion: @escaping (Result<SpotifyArtistRelatedArtistsResponse, Error>) -> Void
    ) {
        guard let url = URL(string: "\(Constants.artistBaseUrl)/\(artistID)/related-artists") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        performRequest(url: url, responseType: SpotifyArtistRelatedArtistsResponse.self, completion: completion)
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
                if let firstArtist = artists.first {
                    completion(.success(firstArtist.id))
                } else {
                    completion(.failure(NSError(domain: "Artist not found", code: 404, userInfo: nil)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
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


