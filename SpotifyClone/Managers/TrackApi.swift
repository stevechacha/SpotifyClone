//
//  TrackApi.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//

import Foundation
import UIKit

final class TrackApiCaller {
    static let shared = TrackApiCaller()
    
    private init() {}
    
    struct Constants {
        static let baseAPIURL = "https://api.spotify.com/v1"
    }
    
    private func perform<T: Decodable>(request: URLRequest, decoding type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? ApiError.failedToGetData))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                completion(.success(result))
            } catch {
                print("Decoding Error: \(error)")
                print("Response Data: \(String(data: data, encoding: .utf8) ?? "No data")")
                completion(.failure(error))
            }
        }
        task.resume()
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
                    
                    // Handle Rate Limit Exceeded (429)
                    if httpResponse.statusCode == 429 {
                        if let retryAfterString = httpResponse.value(forHTTPHeaderField: "Retry-After"),
                           let retryAfter = Double(retryAfterString) {
                            print("Rate limit exceeded. Retrying after \(retryAfter) seconds.")
                            
                            // Show feedback to the user that a wait is required
                            DispatchQueue.main.async {
                                // Example of how to show a message or loading indicator
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

    
    
    // MARK: - Audio Analysis
    func getTracksAudioAnalysis(audioID: String, completion: @escaping (Result<AudioAnalysisResponse, Error>) -> Void) {
        AuthManager.shared.createRequest(
            with: URL(string: Constants.baseAPIURL + "/audio-analysis/\(audioID)"),
            type: .GET
        ) { request in
            self.perform(request: request, decoding: AudioAnalysisResponse.self, completion: completion)
        }
    }
    
    // MARK: - Audio Features
    func getTracksAudioFeatures(audioID: String, completion: @escaping (Result<AudioFeatures, Error>) -> Void) {
        AuthManager.shared.createRequest(
            with: URL(string: Constants.baseAPIURL + "/audio-features/\(audioID)"),
            type: .GET
        ) { request in
            self.perform(request: request, decoding: AudioFeatures.self, completion: completion)
        }
    }
    
    func getSeveralTracksAudioFeatures(trackIDs: [String], completion: @escaping (Result<AudioFeaturesResponse, Error>) -> Void) {
        let idsQuery = trackIDs.joined(separator: ",")
        AuthManager.shared.createRequest(
            with: URL(string: Constants.baseAPIURL + "/audio-features?ids=\(idsQuery)"),
            type: .GET
        ) { request in
            self.perform(request: request, decoding: AudioFeaturesResponse.self, completion: completion)
        }
    }
    
    // MARK: - Tracks
    func getTrack(trackID: String, completion: @escaping (Result<Track, Error>) -> Void) {
        AuthManager.shared.createRequest(
            with: URL(string: Constants.baseAPIURL + "/tracks/\(trackID)"),
            type: .GET
        ) { request in
            self.perform(request: request, decoding: Track.self, completion: completion)
        }
    }
    
    func getSeveralTracks(trackIDs: [String], completion: @escaping (Result<TracksResponse, Error>) -> Void) {
        let idsQuery = trackIDs.joined(separator: ",")
        AuthManager.shared.createRequest(
            with: URL(string: Constants.baseAPIURL + "/tracks?ids=\(idsQuery)"),
            type: .GET
        ) { request in
            self.perform(request: request, decoding: TracksResponse.self, completion: completion)
        }
    }
    
    // MARK: - User's Saved Tracks
    func getUserSavedTracks(completion: @escaping (Result<UsersSavedTracks, Error>) -> Void) {
        AuthManager.shared.createRequest(
            with: URL(string: Constants.baseAPIURL + "/me/tracks"),
            type: .GET
        ) { request in
            self.perform(request: request, decoding: UsersSavedTracks.self, completion: completion)
        }
    }
    
    

    func searchFirstTrackID(query: String, completion: @escaping (Result<String, Error>) -> Void) {
        searchTracks(query: query) { result in
            switch result {
            case .success(let trackIDs):
                if let firstTrackID = trackIDs.first {
                    completion(.success(firstTrackID))
                } else {
                    completion(.failure(ApiError.failedToGetData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getTrackIDsFromPlaylist(playlistID: String, completion: @escaping (Result<[String], Error>) -> Void) {
        let urlString = "\(TrackApiCaller.Constants.baseAPIURL)/playlists/\(playlistID)/tracks"
        
        AuthManager.shared.createRequest(
            with:  URL(string: urlString),
            type: .GET
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                do {
                    let playlistTracksResponse = try JSONDecoder().decode(PlaylistTracksResponse.self, from: data)
                    let trackIDs = playlistTracksResponse.items?.map { $0.track?.id ?? ""}
                    completion(.success(trackIDs ?? []))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    

    
   
    func searchTrackByName(name: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(Constants.baseAPIURL)/search?type=track&q=\(name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else {
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
                    let result = try JSONDecoder().decode(SearchTrackResponse.self, from: data)
                    if let firstTrack = result.tracks.items?.first  {
                        completion(.success(firstTrack.id ?? ""))
                    } else {
                        completion(.failure(ApiError.decodeError))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }

   
    func searchTracks(query: String, completion: @escaping (Result<[String], Error>) -> Void) {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(TrackApiCaller.Constants.baseAPIURL)/search?q=\(encodedQuery)&type=track"
        
        AuthManager.shared.createRequest(
            with: URL(string: urlString),
            type: .GET
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                do {
                    let searchResponse = try JSONDecoder().decode(SearchResponses.self, from: data)
                    let trackIDs = searchResponse.tracks?.items.map { $0.id ?? "" }
                    completion(.success(trackIDs ?? [])) // Provide a default value here
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    
//    func searchTracks(query: String, completion: @escaping (Result<[String], Error>) -> Void) {
//        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
//        let urlString = "\(TrackApiCaller.Constants.baseAPIURL)/search?q=\(encodedQuery)&type=track"
//
//        AuthManager.shared.createRequest(
//            with: URL(string: urlString),
//            type: .GET
//        ) { request in
//            TrackApiCaller.shared.perform(request: request, decoding: SearchResponse.self) { result in
//                switch result {
//                case .success(let searchResponse):
//                    let trackIDs = searchResponse.tracks.items?.map { $0.id }
//                    completion(.success(trackIDs!))
//                case .failure(let error):
//                    completion(.failure(error))
//                }
//            }
//        }
//    }
    
    
   
}



