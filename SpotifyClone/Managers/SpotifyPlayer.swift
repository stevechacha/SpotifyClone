//
//  SpotifyPlayer.swift
//  SpotifyClone
//
//  Created by stephen chacha on 07/01/2025.
//

import Foundation

class SpotifyPlayer {
    static let shared = SpotifyPlayer()
    
    func playTrack(uri: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = URL(string: "https://api.spotify.com/v1/me/player/play")!
        
        AuthManager.shared.createRequest(with: url, type: .PUT) { request in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(()))
            }
            task.resume()
        }
    }
    
    func playTracks(uri: String, deviceID: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        var urlString = "https://api.spotify.com/v1/me/player/play"
        if let deviceID = deviceID {
            urlString += "?device_id=\(deviceID)"
        }
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        AuthManager.shared.createRequest(with: url, type: .PUT) { request in
            var request = request
            let body = ["uris": [uri]]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                    completion(.failure(NSError(domain: "Playback failed", code: statusCode, userInfo: nil)))
                    return
                }
                completion(.success(()))
            }
            task.resume()
        }
    }
    
    func getAvailableDevices(completion: @escaping (Result<[SpotifyDevice], Error>) -> Void) {
        let url = URL(string: "https://api.spotify.com/v1/me/player/devices")!
        AuthManager.shared.createRequest(with: url, type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                    return
                }
                do {
                    let devicesResponse = try JSONDecoder().decode(DevicesResponse.self, from: data)
                    completion(.success(devicesResponse.devices))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    func setVolume(level: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard level >= 0, level <= 100 else {
            completion(.failure(NSError(domain: "SpotifyAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Volume level must be between 0 and 100"])))
            return
        }
        
        let url = URL(string: "https://api.spotify.com/v1/me/player/volume?volume_percent=\(level)")!
        AuthManager.shared.createRequest(with: url, type: .PUT) { request in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(()))
            }
            task.resume()
        }
    }
    
    func getPlaybackState(completion: @escaping (Result<PlaybackState, Error>) -> Void) {
        let url = URL(string: "https://api.spotify.com/v1/me/player")!
        
        AuthManager.shared.createRequest(with: url, type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(NSError(domain: "Invalid response", code: 0, userInfo: nil)))
                    return
                }
                
                if httpResponse.statusCode == 204 {
                    completion(.failure(NSError(domain: "No active playback", code: 204, userInfo: nil)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                    return
                }
                
                do {
                    let playbackState = try JSONDecoder().decode(PlaybackState.self, from: data)
                    completion(.success(playbackState))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    func getCurrentPlaying(completion: @escaping (Result<PlaybackState, Error>) -> Void) {
        let url = URL(string: "https://api.spotify.com/v1/me/player/currently-playing")!
        
        AuthManager.shared.createRequest(with: url, type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                    return
                }
                do {
                    let currentlyPlaying = try JSONDecoder().decode(PlaybackState.self, from: data)
                    completion(.success(currentlyPlaying))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // Pause playback
    func pausePlayback(completion: @escaping (Result<Void, Error>) -> Void) {
        let url = URL(string: "https://api.spotify.com/v1/me/player/pause")!
        AuthManager.shared.createRequest(with: url, type: .PUT) { request in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(()))
            }
            task.resume()
        }
    }
    
    // Skip to next track
    func skipToNextTrack(completion: @escaping (Result<Void, Error>) -> Void) {
        let url = URL(string: "https://api.spotify.com/v1/me/player/next")!
        AuthManager.shared.createRequest(with: url, type: .POST) { request in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(()))
            }
            task.resume()
        }
    }
    
    // Skip to previous track
    func skipToPreviousTrack(completion: @escaping (Result<Void, Error>) -> Void) {
        let url = URL(string: "https://api.spotify.com/v1/me/player/previous")!
        AuthManager.shared.createRequest(with: url, type: .POST) { request in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(()))
            }
            task.resume()
        }
    }
    

    
    // Toggle shuffle mode
    func seekToPosition(positionMS: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = URL(string: "https://api.spotify.com/v1/me/player/seek?position_ms=\(positionMS)")!
        AuthManager.shared.createRequest(with: url, type: .PUT) { request in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(()))
            }
            task.resume()
        }
    }
    
    func toggleShuffle(enabled: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = URL(string: "https://api.spotify.com/v1/me/player/shuffle?state=\(enabled)")!
        AuthManager.shared.createRequest(with: url, type: .PUT) { request in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(()))
            }
            task.resume()
        }
    }
    
    // MARK: - Get Recently Played
    public func getRecentlyPlayed(completion: @escaping (Result<RecentlyPlayedResponse, Error>) -> Void) {
        AuthManager.shared.createRequest(
            with: URL(string: "https://api.spotify.com/v1/me/player/recently-played"),
            type: .GET
        ) { request in
            
            // Perform the network task
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                // Check for network error
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                // Validate the HTTP response
                guard
                    let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode)
                else {
                    if let httpResponse = response as? HTTPURLResponse {
                        print("HTTP Error: Status Code \(httpResponse.statusCode)")
                    } else {
                        print("Invalid response from server.")
                    }
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                // Ensure data is non-nil
                guard let data = data else {
                    print("No data received.")
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                // Log raw JSON response for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("From PlaylistAPI Response JSON: \(jsonString)")
                }
                
                // Decode the JSON response
                do {
                    let decodedResponse = try JSONDecoder().decode(RecentlyPlayedResponse.self, from: data)
                    completion(.success(decodedResponse))
                } catch {
                    print("Decoding error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }

    
    func fetchCategories(completion: @escaping ([SpotifyCategory]) -> Void) {
        guard let url = URL(string: "https://api.spotify.com/v1/browse/categories") else { return }

        AuthManager.shared.createRequest(with: url, type: .GET) { request in
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else { return }
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let dict = json as? [String: Any],
                       let categoriesDict = dict["categories"] as? [String: Any],
                       let items = categoriesDict["items"] as? [[String: Any]] {
                        let categories: [SpotifyCategory] = items.compactMap { item in
                            guard let id = item["id"] as? String,
                                  let name = item["name"] as? String,
                                  let icons = item["icons"] as? [[String: Any]],
                                  let iconURL = icons.first?["url"] as? String else { return nil }
                            return SpotifyCategory(id: id, name: name, imageURL: iconURL)
                        }
                        completion(categories)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }.resume()
    
        }
    }
    
    func fetchCategoryDetails(categoryID: String, completion: @escaping ([SpotifyCategory]) -> Void) {
        let urlString = "https://api.spotify.com/v1/browse/categories/\(categoryID)"
        guard let url = URL(string: urlString) else { return }
        
        AuthManager.shared.createRequest(with: url, type: .GET) { request in
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else { return }
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let dict = json as? [String: Any],
                       let playlists = dict["playlists"] as? [String: Any],
                       let items = playlists["items"] as? [[String: Any]] {
                        let result: [SpotifyCategory] = items.compactMap { item in
                            guard let name = item["name"] as? String,
                                  let images = item["images"] as? [[String: Any]],
                                  let imageURL = images.first?["url"] as? String,
                                  let playlistID = item["id"] as? String else { return nil }
                            return SpotifyCategory(id: playlistID, name: name, imageURL: imageURL)
                        }
                        completion(result)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }.resume()
        }
    }
    
    func getCategoryDetails(for categoryId: String, completion: @escaping (Result<CategoryDetails, Error>) -> Void) {
        guard let url = URL(string: "https://api.spotify.com/v1/browse/categories/\(categoryId)") else {
            completion(.failure(ApiError.invalidURL))
            return
        }

        AuthManager.shared.createRequest(with: url, type: .GET) { request in
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                do {
                    let details = try JSONDecoder().decode(CategoryDetails.self, from: data)
                    completion(.success(details))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
    }


}


