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
    
    
    
    // MARK: - Generic API Fetch Function
    private func fetch<T: Decodable>(
        endpoint: String,
        type: AuthManager.HTTPMethod,
        responseType: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        let urlString = Constants.baseAPURL + endpoint
        guard let url = URL(string: urlString) else {
            completion(.failure(ApiError.invalidURL))
            return
        }
        
        AuthManager.shared.createRequest(with: url, type: type) { request in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(ApiError.apiError(error.localizedDescription)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedResponse))
                } catch {
                    completion(.failure(ApiError.decodingError(error.localizedDescription)))
                }
            }
            task.resume()
        }
    }
    
    
    
    // MARK: - Fetch Shows
    public func getSeveralShows(ids: [String], completion: @escaping (Result<ShowsResponse, Error>) -> Void) {
        let idsString = ids.joined(separator: ",")
        fetch(
            endpoint: "/shows?ids=\(idsString)",
            type: .GET,
            responseType: ShowsResponse.self,
            completion: completion
        )
    }
    
    
    public func getPodcastDetails(showID: String, completion: @escaping (Result<Show, Error>) -> Void) {
        fetch(
            endpoint: "/shows/\(showID)",
            type: .GET,
            responseType: Show.self,
            completion: completion
        )
    }
    
    
    // MARK: - Fetch Episodes
    public func getSeveralEpisodes(ids: [String], completion: @escaping (Result<EpisodesResponse, Error>) -> Void) {
        let idsString = ids.joined(separator: ",")
        fetch(
            endpoint: "/episodes?ids=\(idsString)",
            type: .GET,
            responseType: EpisodesResponse.self,
            completion: completion
        )
    }
    
    public func getEpisodeDetails(episodeID: String, completion: @escaping (Result<Episode, Error>) -> Void) {
        fetch(
            endpoint: "/episodes/\(episodeID)",
            type: .GET,
            responseType: Episode.self,
            completion: completion
        )
    }
    
    
    public func getPodcastEpisodes(showID: String, completion: @escaping (Result<EpisodesResponse, Error>) -> Void) {
        fetch(
            endpoint: "/shows/\(showID)/episodes",
            type: .GET,
            responseType: EpisodesResponse.self,
            completion: completion
        )
    }
    
    // MARK: - Fetch Chapters
    public func getSeveralChapters(ids: [String], completion: @escaping (Result<ChaptersResponse, Error>) -> Void) {
        let idsString = ids.joined(separator: ",")
        fetch(
            endpoint: "/chapters?ids=\(idsString)",
            type: .GET,
            responseType: ChaptersResponse.self,
            completion: completion
        )
    }
    
    public func getChapterDetails(chapterID: String, completion: @escaping (Result<Chapter, Error>) -> Void) {
        fetch(
            endpoint: "/chapters/\(chapterID)",
            type: .GET,
            responseType: Chapter.self,
            completion: completion
        )
    }
    
    // MARK: - Fetch User's Saved Shows
    public func getUserSavedPodCasts(completion: @escaping (Result<UsersSavedShows, Error>) -> Void) {
        //        guard let url = URL(string: "https://api.spotify.com/v1/me/shows?limit=20") else { return }
        fetch(
            endpoint: "/me/shows",
            type: .GET, responseType: UsersSavedShows.self,
            completion: completion
        )
    }
    
    func getUserSavedEpisodes(completion: @escaping (Result<UserSavedEpisodesResponse, Error>) -> Void) {
        fetch(
            endpoint: "/me/episodes",
            type: .GET, responseType: UserSavedEpisodesResponse.self,
            completion: completion
        )
    }
    
    
    public func search(query: String, type: String, completion: @escaping (Result<SearchResponses, Error>) -> Void) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.failure(ApiError.invalidURL))
            return
        }
        fetch(
            endpoint: "/search?q=\(encodedQuery)&type=\(type)",
            type: .GET,
            responseType: SearchResponses.self,
            completion: completion
        )
    }
    
    
    
    
    // MARK: - Search Items
    public func searchSpotifyItem(query: String, type: String, completion: @escaping (Result<[String], Error>) -> Void) {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        fetch(
            endpoint: "/search?q=\(encodedQuery)&type=\(type)&limit=10",
            type: .GET,
            responseType: SearchResponses.self
        ) { result in
            switch result {
            case .success(let searchResponse):
                switch type {
                case "show":
                    completion(.success(searchResponse.shows?.items.compactMap { $0.id } ?? []))
                case "episode":
                    completion(.success(searchResponse.episodes?.items.compactMap { $0.id } ?? []))
                case "chapter":
                    completion(.success(searchResponse.chapters?.items.compactMap { $0.id } ?? []))
                default:
                    completion(.failure(ApiError.failedToGetData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
