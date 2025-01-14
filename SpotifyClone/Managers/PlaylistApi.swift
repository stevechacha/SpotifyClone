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
    
    // MARK: - Get Playlist by ID
    public func getPlaylistDetails(playlistID: String, completion: @escaping (Result<SpotifyPlaylist, Error>) -> Void) {
        guard let url = URL(string: "\(Constants.baseAPIURL)/playlists/\(playlistID)") else { return }
        
        AuthManager.shared.createRequest(with: url, type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                do {
                    let response = try JSONDecoder().decode(SpotifyPlaylist.self, from: data)
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
    public func savePlaylist(
        playlistID: String,
        completion: @escaping (Result<Playlists, Error>) -> Void
    ) {
        AuthManager.shared.createRequest(with: URL(string: "\(Constants.baseAPIURL)/playlists/\(playlistID)"), type: .PUT) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(Playlists.self, from: data)
                    completion(.success(result))
                } catch {
                    print("Error decoding Playlists: \(error)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func createPlaylist(name: String, completion: @escaping (Bool, String?) -> Void) {
        UserApiCaller.shared.getCurrentUserProfile { [weak self] result in
            switch result {
            case .success(let profile):
                guard let url = URL(string: "\(Constants.baseAPIURL)/users/\(profile.id ?? "")/playlists") else {
                    completion(false, nil)
                    return
                }
                
                AuthManager.shared.createRequest(with: url, type: .POST) { baseRequest in
                    var request = baseRequest
                    let json = [
                        "name": name
                    ]
                    request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    
                    let task = URLSession.shared.dataTask(with: request) { data, _, error in
                        guard let data = data, error == nil else {
                            completion(false, nil)
                            return
                        }
                        
                        if let response = (try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)) as? [String: Any],
                           let playlistID = response["id"] as? String {
                            completion(true, playlistID) // Pass playlistID here
                        } else {
                            completion(false, nil)
                        }
                    }
                    task.resume()
                }
                
            case .failure:
                completion(false, nil)
            }
        }
    }

    
//    Change Playlist Details
    func changePlaylistDetails(
        playlistID: String,
        name: String, description: String, isPublic: Bool = false,
        completion: @escaping (Result<Playlists, Error>) -> Void
    ){
        AuthManager.shared.createRequest(with: URL(string: "\(Constants.baseAPIURL)/playlists/\(playlistID)"), type: .PUT) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(Playlists.self, from: data)
                    completion(.success(result))
                } catch {
                    print("Error decoding Playlists: \(error)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
//    Update Playlist Items // UpdateTracksInPlaylist
    func updatePlaylistItems(playlistID: String,completion : @escaping (Result<[String],Error>)->Void){
        AuthManager.shared.createRequest(with: URL(string: "\(Constants.baseAPIURL)//playlists/\(playlistID)/tracks"), type: .PUT) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode([String].self, from: data)
                    completion(.success(result))
                } catch {
                    print("Error decoding Playlists: \(error)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
//    Add Items to Playlist
    func addTracksToPlayList(
        track: Track,
        playlistID: String,
        completion : @escaping (Bool)->Void
    ){
        AuthManager.shared.createRequest(
            with: URL(string: "\(Constants.baseAPIURL)/playlists/\(playlistID)/tracks"),
            type: .POST
        ) { baseRequest in
            var request = baseRequest
            var json = [
                "uris": [
                    "spotify:track:\(track.id ?? "")"
                    ]
            ]
            print(json)
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    completion(false)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    completion(false)
                    return
                }
                
                do {
                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    print(result)
                    if let response = result as? [String: Any],
                       response["snapshot_id"] as? String != nil {
                        completion(true)
                    } else {
                        completion(false)
                    }
                } catch {
                    print("Error decoding Playlists: \(error)")
                    completion(false)
                }
            }
            task.resume()
        }
    }
    
    //    Add Items to Playlist
        func removeTracksToPlayList(
            track: Track,
            playlistID: String,
            completion : @escaping (Result< Bool,Error>)->Void
        ){
            AuthManager.shared.createRequest(
                with: URL(string: "\(Constants.baseAPIURL)/playlists/\(playlistID)/tracks"),
                type: .DELETE
            ) { baseRequest in
                var request = baseRequest
                var json : [String: Any] = [
                    "tracks": [
                        [
                            "uri": "spotify:track:\(track.id ?? "")"
                        ]
                    ]
                ]
                request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        completion(.failure(ApiError.failedToGetData))
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                        completion(.failure(ApiError.invalidResponse(statusCode: 400)))
                        return
                    }
                    
                    do {
                        let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        print(result)
                        if let response = result as? [String: Any],
                           response["snapshot_id"] as? String != nil {
                            completion(.success(true))
                        } else {
                            completion(.failure(ApiError.invalidResponse(statusCode: httpResponse.statusCode)))
                        }
                    } catch {
                        print("Error decoding Playlists: \(error)")
                        completion(.failure(ApiError.invalidResponse(statusCode: httpResponse.statusCode)))
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
        
        // Fetch Playlist Details
        dispatchGroup.enter()
        getPlaylistDetails(playlistID: playlistID) { result in
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
        
        // Wait for all API calls to complete
        dispatchGroup.notify(queue: .main) {
            completion(.success(combinedResponse))
        }
    }

}
