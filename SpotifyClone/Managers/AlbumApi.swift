//
//  AlbumApi.swift
//  SpotifyClone
//
//  Created by stephen chacha on 25/12/2024.
//
import Foundation
import UIKit

final class AlbumApiCaller {
    static let shared = AlbumApiCaller()
    
    private init() {}

    struct Constants {
        static let baseAPIURL = "https://api.spotify.com/v1/"
        static let albumsEndpoint = baseAPIURL + "albums/"
        static let savedAlbumsEndpoint = baseAPIURL + "me/albums"
        static let newReleasesEndpoint = baseAPIURL + "browse/new-releases"
        static let searchEndpoint = baseAPIURL + "search"
    }
    private var cachedTracks: [String: [Track]] = [:]


   

    // MARK: - Get Album Details
    func getAlbumDetails(albumID: String, completion: @escaping (Result<Album, ApiError>) -> Void) {
        guard let url = URL(string: "\(Constants.albumsEndpoint)\(albumID)") else {
            completion(.failure(.invalidURL))
            return
        }

        createAndExecuteRequest(with: url, type: .GET, decodingType: Album.self, completion: completion)
    }

    // MARK: - Get Several Albums
    func getSeveralAlbums(albumIDs: [String], completion: @escaping (Result<SpotifyAlbumResponse, ApiError>) -> Void) {
        guard !albumIDs.isEmpty else {
            completion(.failure(.invalidURL))
            return
        }

        let ids = albumIDs.joined(separator: ",")
        guard let url = URL(string: "\(Constants.albumsEndpoint)?ids=\(ids)") else {
            completion(.failure(.invalidURL))
            return
        }

        createAndExecuteRequest(with: url, type: .GET, decodingType: SpotifyAlbumResponse.self, completion: completion)
    }


    // MARK: - Get Albums Tracks
    func getAllAlbumTracks(albumID: String, completion: @escaping (Result<[Track], ApiError>) -> Void) {
        // Check if the tracks are already cached
        if let cached = cachedTracks[albumID] {
            completion(.success(cached))
            return
        }
        
        var allTracks: [Track] = []
        let nextURL: String? = "\(Constants.albumsEndpoint)\(albumID)/tracks"
        
        func fetchTracks(urlString: String) {
            guard let url = URL(string: urlString) else {
                completion(.failure(.invalidURL))
                return
            }
            
            createAndExecuteRequest(with: url, type: .GET, decodingType: AlbumTracksResponse.self) { result in
                switch result {
                case .success(let response):
                    allTracks.append(contentsOf: response.items)
                    if let next = response.next {
                        fetchTracks(urlString: next)
                    } else {
                        // Cache the fetched tracks
                        self.cachedTracks[albumID] = allTracks
                        completion(.success(allTracks))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        if let next = nextURL {
            fetchTracks(urlString: next)
        }
    }

    // MARK: - Get User's Saved Albums
    func getUserSavedAlbums(completion: @escaping (Result<SpotifyUsersAlbumSavedResponse, ApiError>) -> Void) {
        guard let url = URL(string: Constants.savedAlbumsEndpoint) else {
            completion(.failure(.invalidURL))
            return
        }

        createAndExecuteRequest(with: url, type: .GET, decodingType: SpotifyUsersAlbumSavedResponse.self, completion: completion)
    }
    


    // MARK: - Save Albums for Current User
    func saveAlbumsForCurrentUser(albumIDs: String, completion: @escaping (Result<Bool, ApiError>) -> Void) {
        guard let url = URL(string: Constants.savedAlbumsEndpoint + "?ids=\(albumIDs)") else {
            completion(.failure(.invalidURL))
            return
        }

        AuthManager.shared.createRequest(with: url, type: .PUT) { baseRequest in
            var request = baseRequest
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request) { _, response, error in
                if let error = error {
                    completion(.failure(.apiError(error.localizedDescription)))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    completion(.failure(.invalidResponse(statusCode: 400)))
                    return
                }
                if httpResponse.statusCode == 200 {
                    completion(.success(true))
                } else {
                    completion(.failure(.invalidResponse(statusCode: httpResponse.statusCode)))
                }
              
            }
            task.resume()
        }
    }

    // MARK: - Remove Saved Albums for Current User
    func removeSavedAlbums(albumIDs: String, completion: @escaping (Result<Bool, ApiError>) -> Void) {
        guard let url = URL(string: Constants.savedAlbumsEndpoint + "?ids=\(albumIDs)") else {
            completion(.failure(.invalidURL))
            return
        }
        AuthManager.shared.createRequest(with: url, type: .DELETE) { baseRequest in
            var request = baseRequest
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let task = URLSession.shared.dataTask(with: request) { _, response, error in
                if let error = error {
                    completion(.failure(.apiError(error.localizedDescription)))
                    return
                }
               

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    completion(.failure(.invalidResponse(statusCode: 400)))
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    completion(.success(true))
                } else {
                    completion(.failure(.invalidResponse(statusCode: httpResponse.statusCode)))
                }

            }
            task.resume()
        }
    }

    // MARK: - Get New Releases
    func getNewReleases(completion: @escaping (Result<SpotifyNewReleasesAlbumsResponse, ApiError>) -> Void) {
        guard let url = URL(string: Constants.newReleasesEndpoint) else {
            completion(.failure(.invalidURL))
            return
        }

        createAndExecuteRequest(with: url, type: .GET, decodingType: SpotifyNewReleasesAlbumsResponse.self, completion: completion)
    }

    // MARK: - Search for Albums
    func searchForAlbums(query: String, completion: @escaping (Result<[Album], ApiError>) -> Void) {
        var components = URLComponents(string: Constants.searchEndpoint)
        components?.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: "album")
        ]

        guard let url = components?.url else {
            completion(.failure(.invalidURL))
            return
        }

        createAndExecuteRequest(with: url, type: .GET, decodingType: SearchResponses.self) { result in
            switch result {
            case .success(let response):
                completion(.success(response.albums?.items ?? []))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchAlbumIDs(completion: @escaping (Result<[String], Error>) -> Void) {
            AlbumApiCaller.shared.getUserSavedAlbums { result in
                switch result {
                case .success(let savedAlbumsResponse):
                    // Extract album IDs from the response
                    let albumIDs = savedAlbumsResponse.items.compactMap { $0.album?.id }
                    completion(.success(albumIDs))
                case .failure(let error):
                    completion(.failure(error))
                }
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
    
    
    // MARK: - Helper Methods
    private func createAndExecuteRequest<T: Decodable>(
        with url: URL?,
        type: AuthManager.HTTPMethod = .GET,
        decodingType: T.Type,
        retryCount: Int = 3,
        completion: @escaping (Result<T, ApiError>) -> Void
    ) {
        guard let apiURL = url else {
            completion(.failure(ApiError.invalidURL))
            return
        }
        
        AuthManager.shared.createRequest(with: apiURL, type: type) { request in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    completion(.failure(.failedToGetData))
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
                                self.createAndExecuteRequest(
                                    with: url,
                                    type: type,
                                    decodingType: decodingType,
                                    retryCount: retryCount - 1,
                                    completion: completion
                                )
                            }
                        }
                        return
                    }
                    
                    guard (200...299).contains(httpResponse.statusCode) else {
                        completion(.failure(.failedToGetData))
                        return
                    }
                }
                
                // Debugging: Log raw data
//                if let jsonString = String(data: data, encoding: .utf8) {
//                    print("Response JSON: \(jsonString)")
//                }
//                
                do {
                    let result = try JSONDecoder().decode(decodingType, from: data)
                    completion(.success(result))
                } catch {
                    // Log raw response for debugging
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Raw Response: \(responseString)")
                    }
                    completion(.failure(.decodingError(error.localizedDescription)))
                }
            }
            task.resume()
        }
    }
}





