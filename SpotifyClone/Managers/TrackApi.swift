//
//  TrackApi.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//

import Foundation

final class TrackApiCaller {
    static let shared = TrackApiCaller()
    
    private init() {}
    
    struct Constants {
        static let baseAPIURL = "https://api.spotify.com/v1"
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
                        completion(.success(firstTrack.id))
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
                    let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
                    let trackIDs = searchResponse.tracks.items?.map { $0.id }
                    completion(.success(trackIDs!))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
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
                    let trackIDs = playlistTracksResponse.items.map { $0.track.id }
                    completion(.success(trackIDs ))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    
    
    func fetchRecommendations(
        seedArtists: [String],
        seedTracks: [String],
        seedGenres: [String],
        limit: Int = 20,
        completion: @escaping (Result<[Track], Error>) -> Void
    ) {
        var components = URLComponents(string: "\(Constants.baseAPIURL)/recommendations")
        components?.queryItems = [
            URLQueryItem(name: "seed_artists", value: seedArtists.joined(separator: ",")),
            URLQueryItem(name: "seed_tracks", value: seedTracks.joined(separator: ",")),
            URLQueryItem(name: "seed_genres", value: seedGenres.joined(separator: ",")),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        
        guard let url = components?.url else {
            completion(.failure(ApiError.invalidURL))
            return
        }
        
        AuthManager.shared.createRequest(with: url, type: .GET) { request in
            self.perform(request: request, decoding: TrackRecommendationsResponse.self) { result in
                switch result {
                case .success(let response):
                    completion(.success(response.tracks))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func parseRecommendationsResponse(data: Data) {
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(TrackRecommendationsResponse.self, from: data)
            
            // Print details of the seeds
            for seed in response.seeds {
                print("Seed ID: \(seed.id), Type: \(seed.type)")
            }
            
            // Print details of the tracks
            for track in response.tracks {
                print("Track Name: \(track.name)")
                print("Artists: \(track.artists?.map { $0.name }.joined(separator: ", ") ?? "Unknown Artist")")
                print("Album: \(track.album?.name ?? "Unknow Album name")")
                print("Duration: \((track.durationMs ?? 0 ) / 1000) seconds")
                print("Popularity: \(track.popularity ?? 0)")
                if let previewUrl = track.previewUrl {
                    print("Preview URL: \(previewUrl)")
                }
                print("---------------------------")
            }
        } catch {
            print("Failed to parse recommendations: \(error.localizedDescription)")
        }
    }
}



