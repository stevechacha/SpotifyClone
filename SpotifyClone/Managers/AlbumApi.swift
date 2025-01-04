//
//  AlbumApi.swift
//  SpotifyClone
//
//  Created by stephen chacha on 25/12/2024.
//
import Foundation

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

    // MARK: - Helper Methods
    private func createAndExecuteRequest<T: Decodable>(
        with url: URL?,
        type: AuthManager.HTTPMethod = .GET,
        decodingType: T.Type,
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
                    guard (200...299).contains(httpResponse.statusCode) else {
                        completion(.failure(.failedToGetData))
                        return
                    }
                }
                
                // Debugging: Log raw data
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response JSON: \(jsonString)")
                }


                do {
                    let result = try JSONDecoder().decode(decodingType, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(.decodingError(error.localizedDescription)))
                }
            }
            task.resume()
        }
    }

   

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


    func getAllAlbumTracks(albumID: String, completion: @escaping (Result<[Track], ApiError>) -> Void) {
        var allTracks: [Track] = []
        var nextURL: String? = "\(Constants.albumsEndpoint)\(albumID)/tracks"

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
                        nextURL = next
                        fetchTracks(urlString: next)
                    } else {
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
    func getSavedAlbums(completion: @escaping (Result<SpotifyUsersAlbumSavedResponse, ApiError>) -> Void) {
        guard let url = URL(string: Constants.savedAlbumsEndpoint) else {
            completion(.failure(.invalidURL))
            return
        }

        createAndExecuteRequest(with: url, type: .GET, decodingType: SpotifyUsersAlbumSavedResponse.self, completion: completion)
    }

    // MARK: - Save Albums for Current User
    func saveAlbumsForCurrentUser(albumIDs: [String], completion: @escaping (Result<Bool, ApiError>) -> Void) {
        guard let url = URL(string: Constants.savedAlbumsEndpoint) else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["ids": albumIDs]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        } catch {
            completion(.failure(.encodingError("Failed to encode the request body.")))
            return
        }

        AuthManager.shared.createRequest(with: url, type: .PUT) { request in
            let task = URLSession.shared.dataTask(with: request) { _, response, error in
                if let error = error {
                    completion(.failure(.apiError(error.localizedDescription)))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    completion(.failure(.invalidResponse(statusCode: 400)))
                    return
                }

                completion(.success(true))
            }
            task.resume()
        }
    }

    // MARK: - Remove Saved Albums for Current User
    func removeSavedAlbums(albumIDs: [String], completion: @escaping (Result<Bool, ApiError>) -> Void) {
        guard let url = URL(string: Constants.savedAlbumsEndpoint) else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["ids": albumIDs]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        } catch {
            completion(.failure(.encodingError("")))
            return
        }

        AuthManager.shared.createRequest(with: url, type: .DELETE) { request in
            let task = URLSession.shared.dataTask(with: request) { _, response, error in
                if let error = error {
                    completion(.failure(.apiError(error.localizedDescription)))
                    return
                }
               

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    completion(.failure(.invalidResponse(statusCode: 400)))
                    return
                }

                completion(.success(true))
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
            AlbumApiCaller.shared.getSavedAlbums { result in
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
}


