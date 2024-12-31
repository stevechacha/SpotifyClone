//
//  PlaylistApi.swift
//  SpotifyClone
//
//  Created by stephen chacha on 25/12/2024.
//
import Foundation


final class PlaylistApiCaller {
    
    static let shared = PlaylistApiCaller()
    
    private init() {}

    
    struct Constants {
        static let baseAPIURL = "https://api.spotify.com/v1"
    }
    
    // MARK: - Get Current User's Playlists
    public func getCurrentUsersPlaylist(completion: @escaping (Result<CurrentUsersPlaylistsResponse, Error>) -> Void) {
        AuthManager.shared.createRequest(with: URL(string: "\(Constants.baseAPIURL)/me/playlists"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                do {
                    let response = try JSONDecoder().decode(CurrentUsersPlaylistsResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    print("Error decoding CurrentUsersPlaylistsResponse: \(error)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - Save a Playlist
    public func savePlaylist(playlistID: String, completion: @escaping (Result<Playlists, Error>) -> Void) {
        AuthManager.shared.createRequest(with: URL(string: "\(Constants.baseAPIURL)/playlists/\(playlistID)"), type: .PUT) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(Playlists.self, from: data)
                    print(result)
                    completion(.success(result))
                } catch {
                    print("Error decoding Playlists: \(error)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - Create a Playlist
    public func createPlaylist(userId: String, name: String, description: String, isPublic: Bool, completion: @escaping (Result<CreatePlaylistResponse, Error>) -> Void) {
        guard let url = URL(string: "\(Constants.baseAPIURL)/users/\(userId)/playlists") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = AuthManager.HTTPMethod.POST.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "name": name,
            "description": description,
            "public": isPublic
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        
        AuthManager.shared.createRequest(with: url, type: .POST) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                do {
                    let response = try JSONDecoder().decode(CreatePlaylistResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    print("Error decoding CreatePlaylistResponse: \(error)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - Get Featured Playlists
    public func getFeaturedPlaylists(completion: @escaping (Result<FeaturedPlayListResponse, Error>) -> Void) {
        AuthManager.shared.createRequest(with: URL(string: "\(Constants.baseAPIURL)/browse/featured-playlists"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                do {
                    let response = try JSONDecoder().decode(FeaturedPlayListResponse.self, from: data)
                    print("result\(response)")
                    completion(.success(response))
                } catch {
                    print("Error decoding FeaturedPlayListResponse: \(error)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    
    // MARK: - Get Playlist by ID
    public func getPlaylist(playlistID: String, completion: @escaping (Result<Playlists, Error>) -> Void) {
        guard let url = URL(string: "\(Constants.baseAPIURL)/playlists/\(playlistID)") else { return }
        
        AuthManager.shared.createRequest(with: url, type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                do {
                    let response = try JSONDecoder().decode(Playlists.self, from: data)
                    completion(.success(response))
                } catch {
                    print("Error decoding Playlists: \(error)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - Get Playlist Tracks
    public func getPlaylistTracks(playlistID: String, completion: @escaping (Result<PlaylistTracksResponse, Error>) -> Void) {
        guard let url = URL(string: "\(Constants.baseAPIURL)/playlists/\(playlistID)/tracks") else { return }
        
        AuthManager.shared.createRequest(with: url, type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                do {
                    let response = try JSONDecoder().decode(PlaylistTracksResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    print("Error decoding PlaylistTracksResponse: \(error)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - Get Playlist Cover Image
    public func getPlaylistCoverImage(playlistID: String, completion: @escaping (Result<[APIImage], Error>) -> Void) {
        AuthManager.shared.createRequest(with: URL(string: "\(Constants.baseAPIURL)/playlists/\(playlistID)/images"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                do {
                    let response = try JSONDecoder().decode([APIImage].self, from: data)
                    completion(.success(response))
                } catch {
                    print("Error decoding Playlist Cover Image: \(error)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - Unified Playlist Fetcher
    public func fetchAllPlaylistDetails(playlistID: String, userID: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        var combinedResponse: [String: Any] = [:]
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        getCurrentUsersPlaylist { result in
            switch result {
            case .success(let userPlaylists):
                combinedResponse["UserPlaylists"] = userPlaylists
            case .failure(let error):
                print("Error fetching user's playlists: \(error)")
            }
            dispatchGroup.leave()
        }
        
        // Fetch Featured Playlists
        dispatchGroup.enter()
        getFeaturedPlaylists { result in
            switch result {
            case .success(let featuredPlaylists):
                combinedResponse["FeaturedPlaylists"] = featuredPlaylists
            case .failure(let error):
                print("Error fetching featured playlists: \(error)")
            }
            dispatchGroup.leave()
        }
        
        // Fetch Playlist Details
        dispatchGroup.enter()
        getPlaylist(playlistID: playlistID) { result in
            switch result {
            case .success(let playlistDetails):
                combinedResponse["PlaylistDetails"] = playlistDetails
            case .failure(let error):
                print("Error fetching playlist details: \(error)")
            }
            dispatchGroup.leave()
        }
        
        // Fetch Playlist Tracks
        dispatchGroup.enter()
        getPlaylistTracks(playlistID: playlistID) { result in
            switch result {
            case .success(let playlistTracks):
                combinedResponse["PlaylistTracks"] = playlistTracks
            case .failure(let error):
                print("Error fetching playlist tracks: \(error)")
            }
            dispatchGroup.leave()
        }
        
        // Fetch Playlist Cover Image
        dispatchGroup.enter()
        getPlaylistCoverImage(playlistID: playlistID) { result in
            switch result {
            case .success(let coverImages):
                combinedResponse["PlaylistCoverImage"] = coverImages
            case .failure(let error):
                print("Error fetching playlist cover image: \(error)")
            }
            dispatchGroup.leave()
        }
        
        // Create a Playlist
        dispatchGroup.enter()
        createPlaylist(userId: userID, name: "New Playlist", description: "Generated by App", isPublic: true) { result in
            switch result {
            case .success(let newPlaylist):
                combinedResponse["CreatedPlaylist"] = newPlaylist
            case .failure(let error):
                print("Error creating playlist: \(error)")
            }
            dispatchGroup.leave()
        }
        
        // Wait for all API calls to complete
        dispatchGroup.notify(queue: .main) {
            completion(.success(combinedResponse))
        }
    }

}
