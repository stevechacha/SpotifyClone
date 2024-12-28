//
//  ArtistApi.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//


import Foundation

final class ArtistApiCaller {
    
    static let shared = ArtistApiCaller()
    struct Constants {
        static let artistBaseUrl = "https://api.spotify.com/v1/artists"
        static let baseAPURL = "https://api.spotify.com/v1"
    }
    
    private let decoder: JSONDecoder
    
    init() {
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .useDefaultKeys
        decoder.dateDecodingStrategy = .iso8601 // If using Date type for lastUpdated
    }
    

    
    func getRecommendationsArtist(genres: Set<String>, seedArtists: [String], seedTracks: [String], completion: @escaping (Result<RecommendationsResponse, Error>) -> Void) {
        // Construct URL parameters
        let seedArtistsParam = seedArtists.joined(separator: ",")
        let seedGenresParam = genres.joined(separator: ",")
        let seedTracksParam = seedTracks.joined(separator: ",")
        
        // Build the full URL
        let urlString = "\(Constants.baseAPURL)/recommendations?seed_artists=\(seedArtistsParam)&seed_genres=\(seedGenresParam)&seed_tracks=\(seedTracksParam)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        
        AuthManager.shared.createRequest(with: url, type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                do {
                    let result = try self.decoder.decode(RecommendationsResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }

    

    func getSeveralArtists(
        artistIDs: [String],
        completion: @escaping (Result<SpotifyArtistsResponse, Error>) -> Void
    ) {
        // Ensure artistIDs are properly formatted as a comma-separated string
        let ids = artistIDs.joined(separator: ",")
        let urlString = "https://api.spotify.com/v1/artists?ids=\(ids)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        
        // Create the request
        AuthManager.shared.createRequest(with: url, type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                // Print the raw JSON response for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON Response: \(jsonString)")
                }
                
                // Decode the response
                do {
                    let response = try JSONDecoder().decode(SpotifyArtistsResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }

    
    public func getArtistDetails(artistID: String, completion: @escaping (Result<SpotifyArtistsDetailResponse, Error>) -> Void) {
        // Ensure the URL is constructed dynamically with the artist's ID
        guard let url = URL(string: "\(Constants.artistBaseUrl)/\(artistID)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        
        AuthManager.shared.createRequest(with: url, type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                // Debug: Print raw JSON response
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON Response: \(jsonString)")
                }
                
                do {
                    // Decode JSON response into your `SpotifyArtistsDetailResponse` model
                    let response = try JSONDecoder().decode(SpotifyArtistsDetailResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }


    

    public func getArtistAlbums(artistID: String, completion: @escaping (Result<SpotifyArtistsAlbumsResponse, Error>) -> Void) {
        // Correct URL construction
        let urlString = "\(Constants.artistBaseUrl)/\(artistID)/albums"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        
        AuthManager.shared.createRequest(with: url, type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                do {
                    let response = try self.decoder.decode(SpotifyArtistsAlbumsResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }

    func fetchAlbumsOfArtist(artistID: String, completion: @escaping (Result<SpotifyArtistRelatedArtistsResponse, Error>) -> Void) {
        let urlString = "https://api.spotify.com/v1/artists/\(artistID)/albums"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        AuthManager.shared.createRequest(with: url, type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "No data", code: 500, userInfo: nil)))
                    return
                }

                // Print the raw JSON response for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON Response: \(jsonString)")
                }

                do {
                    let response = try JSONDecoder().decode(SpotifyArtistRelatedArtistsResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }


    

    public func getArtistsTopTracks(for artistID: String, market: String = "us", completion: @escaping (Result<SpotifyArtistsTopTracksResponse, Error>) -> Void) {
        // Construct the URL with the artist ID and the market query parameter
        let urlString = "https://api.spotify.com/v1/artists/\(artistID)/top-tracks?market=\(market)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        
        // Create a request
        AuthManager.shared.createRequest(with: url, type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                // Debugging: Print raw JSON response
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON Response: \(jsonString)")
                }
                
                
                do {
                    let trackResponse = try JSONDecoder().decode(SpotifyArtistsTopTracksResponse.self, from: data)
                    print("Decoded response: \(trackResponse)")
                    completion(.success(trackResponse))
                } catch {
                    print("Error decoding top tracks: \(error)")
                    // Optionally log the raw data here to inspect
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Raw JSON response: \(jsonString)")
                    }
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }

    
  
    public func getArtistsRelatedArtist(artistID: String, completion: @escaping (Result<SpotifyArtistRelatedArtistsResponse, Error>) -> Void) {
        let urlString = "https://api.spotify.com/v1/artists/\(artistID)/related-artists"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(ApiError.failedToGetData))
            return
        }
        
        AuthManager.shared.createRequest(with: url, type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                do {
                    // Decode the response into the correct model
                    let response = try JSONDecoder().decode(SpotifyArtistRelatedArtistsResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }


    
    func searchArtists(query: String, completion: @escaping (Result<[Artist], Error>) -> Void) {
        let urlString = "https://api.spotify.com/v1/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&type=artist&limit=10"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        
        AuthManager.shared.createRequest(with: url, type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                // Debugging raw JSON response
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Search Artists Raw JSON Response: \(jsonString)")
                }
                
                // Decode the JSON response
                do {
                    let response = try JSONDecoder().decode(SpotifySearchResponse.self, from: data)
                    completion(.success(response.artists.items))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func searchArtist(by name: String, completion: @escaping (Result<String, Error>) -> Void) {
        let urlString = "https://api.spotify.com/v1/search?q=\(name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&type=artist&limit=1"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        
        AuthManager.shared.createRequest(with: url, type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(SpotifySearchResponse.self, from: data)
                    if let artist = response.artists.items.first {
                        completion(.success(artist.id))
                    } else {
                        completion(.failure(NSError(domain: "Artist not found", code: 404, userInfo: nil)))
                    }
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    func searchArtistByName(artistName: String, completion: @escaping (Result<String, Error>) -> Void) {
        let urlString = "https://api.spotify.com/v1/search?q=\(artistName)&type=artist"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        
        // Use createRequest to prepare the request
        AuthManager.shared.createRequest(with: url, type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "No data", code: 500, userInfo: nil)))
                    return
                }
                
                do {
                    // Decode the artist search response
                    let response = try JSONDecoder().decode(SpotifySearchResponse.self, from: data)
                    if let artist = response.artists.items.first {
                        completion(.success(artist.id))
                    } else {
                        completion(.failure(NSError(domain: "Artist not found", code: 404, userInfo: nil)))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
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


