//
//  ChapterApiCaller.swift
//  SpotifyClone
//
//  Created by stephen chacha on 27/12/2024.
//


import Foundation

final class ChapterApiCaller {
    
    static let shared = ChapterApiCaller()
    
    private init() {}
    
    struct Constants {
        static let baseAPURL = "https://api.spotify.com/v1"

    }
    
    
    
    // MARK: - API Error Enum
    enum ApiError: Error {
        case invalidURL
        case failedToGetData
        case decodingError(String)
    }
    
    
    
    // MARK: - Generic API Fetch Function
    private func fetch<T: Decodable>(
        url: String,
        type: AuthManager.HTTPMethod,
        responseType: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = URL(string: url) else {
            completion(.failure(ApiError.invalidURL))
            return
        }
        
        AuthManager.shared.createRequest(with: url, type: type) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedResponse))
                } catch {
                    print(error)
                    completion(.failure(ApiError.decodingError(error.localizedDescription)))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - Fetch Shows
    public func getSeveralShow(ids: [String], completion: @escaping (Result<ShowsResponse, Error>) -> Void) {
        let idsString = ids.joined(separator: ",")
        fetch(
            url: "https://api.spotify.com/v1/shows?ids=\(idsString)",
            type: .GET,
            responseType: ShowsResponse.self,
            completion: completion
        )
    }
    
    public func getShowDetail(showID: String, completion: @escaping (Result<Show, Error>) -> Void) {
        fetch(
            url: "https://api.spotify.com/v1/shows/\(showID)",
            type: .GET,
            responseType: Show.self,
            completion: completion
        )
    }
    
    // MARK: - Fetch Episodes
    public func getSeveralEpisodes(ids: [String], completion: @escaping (Result<EpisodesResponse, Error>) -> Void) {
        let idsString = ids.joined(separator: ",")
        fetch(
            url: "https://api.spotify.com/v1/episodes?ids=\(idsString)",
            type: .GET,
            responseType: EpisodesResponse.self,
            completion: completion
        )
    }
    
    public func getEpisodeDetails(episodeID: String, completion: @escaping (Result<Episode, Error>) -> Void) {
        fetch(url: "https://api.spotify.com/v1/episodes/\(episodeID)",
              type: .GET,
              responseType: Episode.self,
              completion: completion
        )
    }
    
    public func getShowEpisodes(showID: String, completion: @escaping (Result<EpisodesResponse, Error>) -> Void) {
        fetch(url: "https://api.spotify.com/v1/shows/\(showID)/episodes",
              type: .GET,
              responseType: EpisodesResponse.self,
              completion: completion
        )
    }
    
    // MARK: - Fetch Chapters
    public func getSeveralChapters(ids: [String], completion: @escaping (Result<ChaptersResponse, Error>) -> Void) {
        let idsString = ids.joined(separator: ",")
        fetch(
            url: "https://api.spotify.com/v1/chapters?ids=\(idsString)",
            type: .GET,
            responseType: ChaptersResponse.self,
            completion: completion
        )
    }
    
    public func getChapterDetails(chapterID: String, completion: @escaping (Result<Chapter, Error>) -> Void) {
        fetch(
            url: "https://api.spotify.com/v1/chapters/\(chapterID)",
            type: .GET,
            responseType: Chapter.self,
            completion: completion
        )
    }
    
    // MARK: - Fetch User's Saved Shows
    public func getUserSavedShows(completion: @escaping (Result<UsersSavedShows, Error>) -> Void) {
//        guard let url = URL(string: "https://api.spotify.com/v1/me/shows?limit=20") else { return }
        fetch(
            url: "https://api.spotify.com/v1/me/shows",
            type: .GET, responseType: UsersSavedShows.self,
            completion: completion
        )
    }
    
//    func getUserSavedShows(completion: @escaping (Result<UsersSavedShows, Error>) -> Void) {
//        guard let url = URL(string: "https://api.spotify.com/v1/me/shows?limit=20") else { return }
//
//        // Use AuthManager to create the request
//        AuthManager.shared.createRequest(with: url, type: .GET) { request in
//            let task = URLSession.shared.dataTask(with: request) { data, _, error in
//                guard let data = data, error == nil else {
//                    completion(.failure(ApiError.failedToGetData))
//                    return
//                }
//                
//                do {
//                    // Decode the response into UserShowsResponse
//                    let response = try JSONDecoder().decode(UsersSavedShows.self, from: data)
//                    completion(.success(response))
//                } catch {
//                    print("Error decoding UserShowsResponse: \(error)")
//                    completion(.failure(error))
//                }
//            }
//            task.resume()
//        }
//    }

    
    
    
    // Add this method to ChapterApiCaller
    public func search(query: String, type: String, completion: @escaping (Result<SearchResponse, Error>) -> Void) {
        // Encode the query to handle special characters
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.failure(ApiError.invalidURL))
            return
        }
        
        // Construct the search URL
        guard let url = URL(string: "https://api.spotify.com/v1/search?q=\(encodedQuery)&type=\(type)") else {
            completion(.failure(ApiError.invalidURL))
            return
        }
        
        // Create the request
        AuthManager.shared.createRequest(with: url, type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                // Debug: Print raw JSON response
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON response: \(jsonString)")
                }
                
                // Try to decode the response
                do {
                    let decoder = JSONDecoder()
                    let searchResponse = try decoder.decode(SearchResponse.self, from: data)
                    completion(.success(searchResponse))
                } catch {
                    print("Decoding Error: \(error.localizedDescription)")
                    completion(.failure(ApiError.decodingError(error.localizedDescription)))
                }
            }
            task.resume()
        }
    }
    
    func getUserSavedEpisodes(completion: @escaping (Result<UserSavedEpisodesResponse, Error>) -> Void) {
            let urlString = "https://api.spotify.com/v1/me/episodes"
            guard let url = URL(string: urlString) else {
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
                        let decodedResponse = try JSONDecoder().decode(UserSavedEpisodesResponse.self, from: data)
                        completion(.success(decodedResponse))
                    } catch {
                        completion(.failure(ApiError.decodingError(error.localizedDescription)))
                    }
                }
                task.resume()
            }
        }

    
    
    // MARK: - Search Items (Dynamic IDs)
    public func searchSpotifyItem(query: String, type: String, completion: @escaping (Result<[String], Error>) -> Void) {
        let query = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        fetch(
            url: "\(Constants.baseAPURL)/search?q=\(query)&type=\(type)&limit=10",
            type: .GET,
            responseType: SearchResponses.self
        ) { result in
            switch result {
            case .success(let searchResponse):
                switch type {
                case "show":
                    let ids = searchResponse.shows?.items.compactMap { $0.id } ?? []
                    completion(.success(ids))
                case "episode":
                    let ids = searchResponse.episodes?.items.compactMap { $0.id } ?? []
                    completion(.success(ids))
                case "chapter":
                    let ids = searchResponse.chapters?.items.compactMap { $0.id } ?? []
                    completion(.success(ids))
                default:
                    completion(.failure(ApiError.failedToGetData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

}
