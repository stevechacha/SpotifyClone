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
        static let baseAPURL = "https://api.spotify.com/v1"

    }
    

    //Get Track's Audio Analysis
    //curl --request GET \
    //  --url https://api.spotify.com/v1/audio-analysis/11dFghVXANMlKmJXsNCbNl \
    //  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
    //@Get(/audio-analysis/{id})

    // MARK: - AudioAnalysisResponse
    
    func getTracksAudioAnalysis(genres: Set<String>, completion: @escaping ((Result<AudioAnalysisResponse,Error>)->Void)){
        let seeds = genres.joined(separator: ",")
        createRequest(
            with: URL(string: Constants.baseAPURL + "/audio-analysis/{id})"),
            type: .GET
        ){ request in
            let task = URLSession.shared.dataTask(with: request){ data, _, error in
                guard let data = data , error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(AudioAnalysisResponse.self, from: data)
                    print(result)
                    completion(.success(result))
                }
                catch {
                    print(error)
                    completion(.failure(error))
                }
            }
            task.resume()
            
        }
    }

    //Get Track's Audio Features
    //curl --request GET \
    //  --url https://api.spotify.com/v1/audio-features/11dFghVXANMlKmJXsNCbNl \
    //  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
    //@Get(/audio-features/{id})
    // MARK: - AudioFeatures
    
    
    
    func getTracksAudioFeatures(genres: Set<String>, completion: @escaping ((Result<AudioFeatures,Error>)->Void)){
        let seeds = genres.joined(separator: ",")
        createRequest(
            with: URL(string: Constants.baseAPURL + "/audio-analysis/{id})"),
            type: .GET
        ){ request in
            let task = URLSession.shared.dataTask(with: request){ data, _, error in
                guard let data = data , error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(AudioFeatures.self, from: data)
                    print(result)
                    completion(.success(result))
                }
                catch {
                    print(error)
                    completion(.failure(error))
                }
            }
            task.resume()
            
        }
    }


    //Get Several Tracks' Audio Features
    //@GET(/audio-features)
    //curl --request GET \
    //  --url 'https://api.spotify.com/v1/audio-features?ids=7ouMYWpwJ422jRcDASZB7P%2C4VqPOruhp5EdPBeR92t6lQ%2C2takcwOaAZWiXQijPHIx7B' \
    //  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'

    // MARK: - AudioFeaturesResponse
    
    func getSeveralTracksAudioFeature(genres: Set<String>, completion: @escaping ((Result<AudioFeaturesResponse,Error>)->Void)){
        let seeds = genres.joined(separator: ",")
        createRequest(
            with: URL(string: Constants.baseAPURL + "/audio-features"),
            type: .GET
        ){ request in
            let task = URLSession.shared.dataTask(with: request){ data, _, error in
                guard let data = data , error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(AudioFeaturesResponse.self, from: data)
                    print(result)
                    completion(.success(result))
                }
                catch {
                    print(error)
                    completion(.failure(error))
                }
            }
            task.resume()
            
        }
    }

    //curl --request GET \
    //  --url https://api.spotify.com/v1/tracks/11dFghVXANMlKmJXsNCbNl \
    //  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
    //Get Track
    //@GET(/tracks/{id})
    // MARK: - Track
    
    func getTrack(genres: Set<String>, completion: @escaping ((Result<Track,Error>)->Void)){
        let seeds = genres.joined(separator: ",")
        createRequest(
            with: URL(string: Constants.baseAPURL + "tracks/{id}"),
            type: .GET
        ){ request in
            let task = URLSession.shared.dataTask(with: request){ data, _, error in
                guard let data = data , error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(Track.self, from: data)
                    print(result)
                    completion(.success(result))
                }
                catch {
                    print(error)
                    completion(.failure(error))
                }
            }
            task.resume()
            
        }
    }

    //Get Several Tracks
    //curl --request GET \
    //  --url 'https://api.spotify.com/v1/tracks?ids=7ouMYWpwJ422jRcDASZB7P%2C4VqPOruhp5EdPBeR92t6lQ%2C2takcwOaAZWiXQijPHIx7B' \
    //  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
    //'
    //GET(/tracks)
    // MARK: - TracksResponse
    
    
    func getServeralTracks(genres: Set<String>, completion: @escaping ((Result<TracksResponse,Error>)->Void)){
        let seeds = genres.joined(separator: ",")
        createRequest(
            with: URL(string: Constants.baseAPURL + "/tracks"),
            type: .GET
        ){ request in
            let task = URLSession.shared.dataTask(with: request){ data, _, error in
                guard let data = data , error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(TracksResponse.self, from: data)
                    print(result)
                    completion(.success(result))
                }
                catch {
                    print(error)
                    completion(.failure(error))
                }
            }
            task.resume()
            
        }
    }
    



    //Get User's Saved Tracks
    //@GET(me/tracks)
    //curl --request GET \
    //  --url https://api.spotify.com/v1/me/tracks \
    //  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
    //
    // MARK: - UsersSavedTracks
    
    func getUserSavedTracks(genres: Set<String>, completion: @escaping ((Result<UsersSavedTracks,Error>)->Void)){
        let seeds = genres.joined(separator: ",")
        createRequest(
            with: URL(string: Constants.baseAPURL + "/me/tracks"),
            type: .GET
        ){ request in
            let task = URLSession.shared.dataTask(with: request){ data, _, error in
                guard let data = data , error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(UsersSavedTracks.self, from: data)
                    print(result)
                    completion(.success(result))
                }
                catch {
                    print(error)
                    completion(.failure(error))
                }
            }
            task.resume()
            
        }
    }
    
    
    private func createRequest(
        with url: URL?,
        type: HTTPMethod,
        completion: @escaping (URLRequest) -> Void
    ) {
        AuthManager.shared.withvalidToken { token in
            guard let apiURL = url else { return }
            
            var request = URLRequest(url: apiURL)
            request.httpMethod = type.rawValue
            // Fix: Add a space between "Bearer" and the token
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.timeoutInterval = 30
            completion(request)
        }
    }

    
    enum HTTPMethod : String {
        case GET
        case POST
    }
}



