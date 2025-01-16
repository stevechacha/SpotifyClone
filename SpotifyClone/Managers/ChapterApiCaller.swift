//
//  ChapterApiCaller.swift
//  SpotifyClone
//
//  Created by stephen chacha on 27/12/2024.
//


import Foundation
import UIKit

final class ChapterApiCaller {
    
    static let shared = ChapterApiCaller()
    
    private init() {}
    
    struct Constants {
        static let baseAPURL = "https://api.spotify.com/v1"
        
    }
    
    
    
//    // MARK: - Generic API Fetch Function
//    private func fetch<T: Decodable>(
//        endpoint: String,
//        type: AuthManager.HTTPMethod,
//        responseType: T.Type,
//        completion: @escaping (Result<T, Error>) -> Void
//    ) {
//        let urlString = Constants.baseAPURL + endpoint
//        guard let url = URL(string: urlString) else {
//            completion(.failure(ApiError.invalidURL))
//            return
//        }
//        
//        AuthManager.shared.createRequest(with: url, type: type) { request in
//            let task = URLSession.shared.dataTask(with: request) { data, response, error in
//                if let error = error {
//                    completion(.failure(ApiError.apiError(error.localizedDescription)))
//                    return
//                }
//                
//                guard let data = data else {
//                    completion(.failure(ApiError.failedToGetData))
//                    return
//                }
//                
//                do {
//                    let decodedResponse = try JSONDecoder().decode(T.self, from: data)
//                    completion(.success(decodedResponse))
//                } catch {
//                    completion(.failure(ApiError.decodingError(error.localizedDescription)))
//                }
//            }
//            task.resume()
//        }
//    }
    
    // MARK: - Helper Methods
    private func fetch<T: Decodable>(
        endpoint: String,
        type: AuthManager.HTTPMethod,
        responseType: T.Type,
        retryCount: Int = 3,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        let urlString = Constants.baseAPURL + endpoint
        guard let url = URL(string: urlString) else {
            completion(.failure(ApiError.invalidURL))
            return
        }
        
        AuthManager.shared.createRequest(with: url,type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("Status Code: \(httpResponse.statusCode)")
                    
                    // Handle Rate Limit Exceeded (429)
                    if httpResponse.statusCode == 429 {
                        if let retryAfterString = httpResponse.value(forHTTPHeaderField: "Retry-After"),
                           let retryAfter = Double(retryAfterString) {
                            print("Rate limit exceeded. Retrying after \(retryAfter) seconds.")
                            
                            // Show feedback to the user that a wait is required
                            DispatchQueue.main.async {
                                let alert = UIAlertController(
                                    title: "Rate Limit Exceeded",
                                    message: "Please wait for \(Int(retryAfter)) seconds before trying again.",
                                    preferredStyle: .alert
                                )
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                // Present alert to the user
                                if let viewController = self.topMostViewController() {
                                    viewController.present(alert, animated: true, completion: nil)
                                }
                            }
                            
                            // Wait before retrying based on Retry-After header
                            DispatchQueue.global().asyncAfter(deadline: .now() + retryAfter) {
                                self.fetch(
                                    endpoint: urlString,
                                    type: type,
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
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response JSON: \(jsonString)")
                }
                
                do {
                    let result = try JSONDecoder().decode(responseType, from: data)
                    completion(.success(result))
                } catch {
                    // Log raw response for debugging
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
    
    
    
    // MARK: - Fetch Shows
    public func getSeveralShows(
        ids: [String],
        completion: @escaping (Result<ShowsResponse, Error>) -> Void
    ) {
        let idsString = ids.joined(separator: ",")
        fetch(
            endpoint: "/shows?ids=\(idsString)",
            type: .GET,
            responseType: ShowsResponse.self,
            completion: completion
        )
    }
    
    
    public func getPodcastDetails(
        showID: String,
        completion: @escaping (Result<Show, Error>) -> Void
    ) {
        fetch(
            endpoint: "/shows/\(showID)",
            type: .GET,
            responseType: Show.self,
            completion: completion
        )
    }
    
    
    // MARK: - Fetch Episodes
    public func getSeveralEpisodes(
        ids: [String],
        completion: @escaping (Result<EpisodesResponse, Error>) -> Void
    ) {
        let idsString = ids.joined(separator: ",")
        fetch(
            endpoint: "/episodes?ids=\(idsString)",
            type: .GET,
            responseType: EpisodesResponse.self,
            completion: completion
        )
    }
    
    public func getEpisodeDetails(
        episodeID: String,
        completion: @escaping (Result<Episode, Error>) -> Void
    ) {
        fetch(
            endpoint: "/episodes/\(episodeID)",
            type: .GET,
            responseType: Episode.self,
            completion: completion
        )
    }
    
    
    public func getPodcastEpisodes(
        showID: String,
        completion: @escaping (Result<EpisodesResponse, Error>) -> Void
    ) {
        fetch(
            endpoint: "/shows/\(showID)/episodes",
            type: .GET,
            responseType: EpisodesResponse.self,
            completion: completion
        )
    }
    
    // MARK: - Fetch Chapters
    public func getSeveralChapters(
        ids: [String],
        completion: @escaping (Result<ChaptersResponse, Error>) -> Void
    ) {
        let idsString = ids.joined(separator: ",")
        fetch(
            endpoint: "/chapters?ids=\(idsString)",
            type: .GET,
            responseType: ChaptersResponse.self,
            completion: completion
        )
    }
    
    public func getChapterDetails(
        chapterID: String,
        completion: @escaping (Result<Chapter, Error>) -> Void
    ) {
        fetch(
            endpoint: "/chapters/\(chapterID)",
            type: .GET,
            responseType: Chapter.self,
            completion: completion
        )
    }
    
    // MARK: - Fetch User's Saved Shows
    public func getUserSavedPodCasts(
        completion: @escaping (Result<UsersSavedShows, Error>) -> Void
    ) {
        //        guard let url = URL(string: "https://api.spotify.com/v1/me/shows?limit=20") else { return }
        fetch(
            endpoint: "/me/shows",
            type: .GET, responseType: UsersSavedShows.self,
            completion: completion
        )
    }
    
    func getUserSavedEpisodes(
        completion: @escaping (Result<UserSavedEpisodesResponse, Error>) -> Void
    ) {
        fetch(
            endpoint: "/me/episodes",
            type: .GET, responseType: UserSavedEpisodesResponse.self,
            completion: completion
        )
    }
    
    
    public func search(
        query: String, type: String,
        completion: @escaping (Result<SearchResponses, Error>) -> Void
    ) {
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
    public func searchSpotifyItem(
        query: String,
        type: String,
        completion: @escaping (Result<[String], Error>) -> Void
    ) {
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
