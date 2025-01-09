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
        AuthManager.shared.createRequest(with: URL(string: "https://api.spotify.com/v1/me/player/recently-played"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                if let httpResponse = response as? HTTPURLResponse {
                    print("Status Code: \(httpResponse.statusCode)")
                    guard (200...299).contains(httpResponse.statusCode) else {
                        completion(.failure(ApiError.failedToGetData))
                        return
                    }
                }
                
                // Debugging: Log raw data
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("From PlaylistAPI Response JSON: \(jsonString)")
                }
                do {
                    let response = try JSONDecoder().decode(RecentlyPlayedResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    print("Error decoding CurrentUsersPlaylistsResponse: \(error)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
}
