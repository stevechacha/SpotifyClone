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
        static let baseAPURL = "https://api.spotify.com/v1/"
        static let albumsEndpoint = baseAPURL + "albums/"
        static let savedAlbumsEndpoint = baseAPURL + "me/albums"
        static let newReleasesEndpoint = baseAPURL + "browse/new-releases"
    }
    
    // MARK: - Get Album Recommendations
    func getRecommendationsForAlbum(
        genres: Set<String>,
        seedAlbums: [String],
        seedTracks: [String],
        completion: @escaping (Result<RecommendedGenresResponse, ApiError>) -> Void
    ) {
        var urlString = "\(Constants.baseAPURL)recommendations?seed_albums=\(seedAlbums.joined(separator: ","))"
        
        if !genres.isEmpty {
            urlString += "&genres=\(genres.joined(separator: ","))"
        }
        
        if !seedTracks.isEmpty {
            urlString += "&seed_tracks=\(seedTracks.joined(separator: ","))"
        }
        
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        AuthManager.shared.createRequest(with: url, type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(RecommendedGenresResponse.self, from: data)
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
        
        AuthManager.shared.createRequest(with: url, type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(Album.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(.decodingError(error.localizedDescription)))
                }
            }
            task.resume()
        }
    }
    
    
    // MARK: - Get Several Albums
    func getSeveralAlbums(albumIDs: [String], completion: @escaping (Result<SpotifyAlbumResponse, ApiError>) -> Void) {
        guard !albumIDs.isEmpty else {
            completion(.failure(.invalidURL)) // No album IDs provided
            return
        }
        
        let ids = albumIDs.joined(separator: ",")
        let urlString = "\(Constants.baseAPURL)albums?ids=\(ids)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        AuthManager.shared.createRequest(with: url, type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(.apiError(error.localizedDescription)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    if let httpResponse = response as? HTTPURLResponse {
                        completion(.failure(.apiError("Received HTTP \(httpResponse.statusCode)")))
                    } else {
                        completion(.failure(.invalidResponse))
                    }
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(SpotifyAlbumResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(.decodingError(error.localizedDescription)))
                }
            }
            task.resume()
        }
    }
    
    
    
    
    // MARK: - Get Album Tracks
    func getAlbumTracks(albumID: String, completion: @escaping (Result<AlbumTracksResponse, Error>) -> Void) {
        guard let url = URL(string: "https://api.spotify.com/v1/albums/\(albumID)/tracks") else { return }

        // Use AuthManager to create the request
        AuthManager.shared.createRequest(with: url, type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                do {
                    // Decode the response into AlbumTracksResponse
                    let response = try JSONDecoder().decode(AlbumTracksResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    print("Error decoding AlbumTracksResponse: \(error)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }

    
    

    
    // MARK: - Get User's Saved Albums
    
    
    func getSavedAlbums(completion: @escaping (Result<SpotifyUsersAlbumSavedResponse, ApiError>) -> Void) {
        guard let url = URL(string: Constants.savedAlbumsEndpoint) else {
            completion(.failure(.invalidURL))
            return
        }
        
        AuthManager.shared.createRequest(with: url, type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(.failedToGetData))
                    return
                }
                
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON Response: \(jsonString)")
                }
                
                
                do {
                    // Decode the saved albums response into an array of Album objects
                    let result = try JSONDecoder().decode(SpotifyUsersAlbumSavedResponse.self, from: data)
                    if result.items.isEmpty {
                        print("No saved albums found for the user.")
                        return
                    }
                    for item in result.items {
                        if let album = item.album {
                            print("Album Name: \(album.name)")
                        } else {
                            print("Missing album data for item added at: \(item.addedAt)")
                        }
                    }
                    
                    completion(.success(result))
                } catch {
                    print("Failed to decode response: \(error)")
                    completion(.failure(.decodingError(error.localizedDescription)))
                }
            }
            task.resume()
        }
    }
    
    
    
    // MARK: - Save Albums for Current User
    func saveAlbumsCurrentUser(completion: @escaping ((Result<SpotifyUsersAlbumSavedResponse, Error>) -> Void )){
        AuthManager.shared.createRequest(with: URL(string: Constants.baseAPURL + "me/albums"), type: .PUT){ request in
            let task = URLSession.shared.dataTask(with: request) { data , _, error in
                guard let data = data , error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(SpotifyUsersAlbumSavedResponse.self, from: data)
                    print("result\(result)")
                    completion(.success(result))
                }
                
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
            
        }
    }
    
    // MARK: - Remove Saved Albums for Current User
    func removeUsersSavedAlbums(completion: @escaping ((Result<SpotifyUsersAlbumSavedResponse, Error>) -> Void )){
        AuthManager.shared.createRequest(with: URL(string: Constants.baseAPURL + "me/albums"), type: .DELETE){ request in
            let task = URLSession.shared.dataTask(with: request) { data , _, error in
                guard let data = data , error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(SpotifyUsersAlbumSavedResponse.self, from: data)
                    print("result\(result)")
                    completion(.success(result))
                }
                
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
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
        
        AuthManager.shared.createRequest(with: url, type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(SpotifyNewReleasesAlbumsResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(.decodingError(error.localizedDescription)))
                }
            }
            task.resume()
        }
    }
    
    func getAllAlbumTracks(albumID: String, completion: @escaping (Result<[Track], Error>) -> Void) {
        var allTracks: [Track] = []
        var nextURL: String? = "\(Constants.baseAPURL)albums/\(albumID)/tracks"
        
        func fetchTracks(urlString: String) {
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
                        let result = try JSONDecoder().decode(AlbumTracksResponse.self, from: data)
                        allTracks.append(contentsOf: result.items)
                        
                        // Check for paginatio
                        if let next = result.next {
                            nextURL = next
                            fetchTracks(urlString: next)
                        } else {
                            let tracksCopy = allTracks
                            completion(.success(tracksCopy))
                        }
                    } catch {
                        completion(.failure(error))
                    }
                }
                task.resume()
            }
        }
        
        // Start the first request
        if let next = nextURL {
            fetchTracks(urlString: next)
        }
    }
    
    func searchForAlbums(query: String, completion: @escaping (Result<[Album], ApiError>) -> Void) {
        guard let url = URL(string: "https://api.spotify.com/v1/search?q=\(query)&type=album") else {
            completion(.failure(.invalidURL))
            return
        }
        
        AuthManager.shared.createRequest(with: url, type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(.failedToGetData))
                    return
                }
                
                do {
                    // Decode the search results response into the Album model
                    let result = try JSONDecoder().decode(SearchResponse.self, from: data)
                    completion(.success(result.albums.items)) // Return album items
                } catch {
                    completion(.failure(.decodingError(error.localizedDescription)))
                }
            }
            task.resume()
        }
    }
    
    public func getAlbum(albumIDs: [String], completion: @escaping (Result<SpotifyAlbumResponse, Error>) -> Void) {
        // Ensure the album IDs are joined as a comma-separated string
        let idsParam = albumIDs.joined(separator: ",")
        guard let url = URL(string: Constants.baseAPURL + "/albums?ids=\(idsParam)") else {
            completion(.failure(ApiError.invalidURL))
            return
        }
        
        // Call createRequest with the correct URL and make the request
        AuthManager.shared.createRequest(with: url, type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                do {
                    // Try to decode the response
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    // Check if the response contains an error (API error like the "missing ids")
                    if let jsonObject = try? JSONSerialization.jsonObject(with: data),
                       let jsonDict = jsonObject as? [String: Any],
                       jsonDict["error"] != nil {
                        // Decode the error response and handle it
                        let errorResponse = try decoder.decode(SpotifyAPIErrorResponse.self, from: data)
                        print("API Error:", errorResponse.error.message)
                        completion(.failure(ApiError.apiError(errorResponse.error.message)))
                        return
                    }
                    
                    // Decode the success response if no error
                    let decodedResponse = try decoder.decode(SpotifyAlbumResponse.self, from: data)
                    completion(.success(decodedResponse))
                    
                } catch let DecodingError.keyNotFound(key, context) {
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("CodingPath:", context.codingPath)
                    completion(.failure(ApiError.decodingError("Key '\(key)' not found in JSON.")))
                } catch let DecodingError.valueNotFound(value, context) {
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("CodingPath:", context.codingPath)
                    completion(.failure(ApiError.decodingError("Value '\(value)' is missing in JSON.")))
                } catch let DecodingError.typeMismatch(type, context) {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("CodingPath:", context.codingPath)
                    completion(.failure(ApiError.decodingError("Type mismatch for type '\(type)'.")))
                } catch {
                    print("Error decoding JSON:", error.localizedDescription)
                    completion(.failure(ApiError.decodingError("Unexpected decoding error: \(error.localizedDescription)")))
                }
            }
            task.resume()
        }
    }

}
