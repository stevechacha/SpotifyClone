//
//  Recommended.swift
//  SpotifyClone
//
//  Created by stephen chacha on 25/12/2024.
//
import Foundation

final class RecommendedApiCaller {
    
    static let shared = RecommendedApiCaller()
    
    private init() {}

    
    
    struct Constants {
        static let baseAPURL = "https://api.spotify.com/v1"
        
    }
    
    
    
    func getRecommedations(genres: Set<String>, completion: @escaping ((Result<RecommendationsResponse,Error>)->Void)){
        let seeds = genres.joined(separator: ",")
        
        AuthManager.shared.performRequest(
            url: URL(string: Constants.baseAPURL + "/recommendations?seed_genres=\(seeds)"),
            type: .GET,
            responseType: RecommendationsResponse.self,
            completion: completion
        )
        
    }
    
    
    func getRecommendedGenre(completion: @escaping ((Result<GenreSeedsResponse,Error>)->Void)) {
        AuthManager.shared.performRequest(
            url: URL(string: "https://api.spotify.com/v1/recommendations/available-genre-seeds"),
            type: .GET,
            responseType: GenreSeedsResponse.self,
            completion: completion
        )
    }
    
    
    func getAvailableGenreSeeds(completion: @escaping (Result<GenreSeedsResponse, Error>) -> Void) {
        let url = URL(string: "https://api.spotify.com/v1/recommendations/available-genre-seeds")
        
        AuthManager.shared.performRequest(
            url: URL(string: "https://api.spotify.com/v1/recommendations/available-genre-seeds"),
            type: .GET,
            responseType: GenreSeedsResponse.self,
            completion: completion
        )
        
    }
    
    func fetchAvailableGenres(completion: @escaping (Result<[String], Error>) -> Void) {
        guard let url = URL(string: "\(Constants.baseAPURL)/recommendations/available-genre-seeds") else {
            completion(.failure(ApiError.invalidURL))
            return
        }
        
        AuthManager.shared.createRequest(with: url, type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(GenreSeedsResponse.self, from: data)
                    completion(.success(response.genres))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    func getRecommendations(seedArtists: [String] = [],
                                seedGenres: [String] = [],
                                seedTracks: [String] = [],
                                completion: @escaping (Result<[RecommendationTrack], Error>) -> Void) {
            guard let url = buildURL(seedArtists: seedArtists, seedGenres: seedGenres, seedTracks: seedTracks) else {
                completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
                return
            }
            
            AuthManager.shared.createRequest(with: url, type: .GET) { request in
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        print("Network error: \(error)")
                        completion(.failure(error))
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        print("HTTP Status Code: \(httpResponse.statusCode)")
                    }
                    
                    guard let data = data else {
                        print("No data received from the server.")
                        completion(.failure(NSError(domain: "NoData", code: 500, userInfo: nil)))
                        return
                    }
                    
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Raw JSON Response: \(jsonString)")
                    } else {
                        print("Failed to decode response as string.")
                    }
                    
                    do {
                        let recommendations = try JSONDecoder().decode(RecommendationsResponses.self, from: data)
                        completion(.success(recommendations.tracks))
                    } catch {
                        print("Decoding error: \(error)")
                        completion(.failure(error))
                    }
                }
                task.resume()


            }
        }
        
        private func buildURL(seedArtists: [String], seedGenres: [String], seedTracks: [String]) -> URL? {
            var components = URLComponents(string: "https://api.spotify.com/v1/recommendations")
            var queryItems: [URLQueryItem] = []
            
            if !seedArtists.isEmpty {
                queryItems.append(URLQueryItem(name: "seed_artists", value: seedArtists.joined(separator: ",")))
            }
            if !seedGenres.isEmpty {
                queryItems.append(URLQueryItem(name: "seed_genres", value: seedGenres.joined(separator: ",")))
            }
            if !seedTracks.isEmpty {
                queryItems.append(URLQueryItem(name: "seed_tracks", value: seedTracks.joined(separator: ",")))
            }
            
            queryItems.append(URLQueryItem(name: "limit", value: "20")) // Adjust limit if needed
            components?.queryItems = queryItems
            
            return components?.url
        }

    
    struct RecommendationsResponses: Decodable {
        let tracks: [RecommendationTrack]
    }

    struct RecommendationTrack: Decodable {
        let name: String
        let durationMs: Int?
        let previewUrl: String?
        let album: Album
        let artists: [Artist]
        
        enum CodingKeys: String, CodingKey {
            case name
            case durationMs = "duration_ms"
            case previewUrl = "preview_url"
            case album
            case artists
        }
    }






}







