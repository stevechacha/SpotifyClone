//
//  ApiCaller.swift
//  SpotifyClone
//
//  Created by stephen chacha on 04/12/2024.
//

import Foundation

final class UserApiCaller {
    static let shared = UserApiCaller()
    
    private let decoder: JSONDecoder
    
    
    private init() {
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .useDefaultKeys
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    struct Constants {
        static let baseApiUrl = "https://api.spotify.com/v1"
        
    }
    
    
    func getCurrentUserProfile(completion : @escaping (Result<UserProfile, Error>)-> Void){
        AuthManager.shared.createRequest(
            with: URL(string: Constants.baseApiUrl + "/me"),
            type: .GET
        ){ baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data , response, error in
                guard let data = data , error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                if let response = response as? HTTPURLResponse {
                    print("Response Code: \(response.statusCode)")
                }
                
                do {
                    let userProfile = try JSONDecoder().decode(UserProfile.self, from: data)
                    print(userProfile)
                    completion(.success(userProfile))
                } catch {
                    print("Decoding Error: \(error)")
                    completion(.failure(error))
                }
            }
            task.resume()
            
        }
    }
    // Get Followed Artists
    func getFollowedArtists(completion: @escaping (Result<[FollowedArtist], Error>) -> Void) {
        guard let url = URL(string: "https://api.spotify.com/v1/me/following?type=artist&limit=20") else {
            completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: nil)))
            return
        }
        
        AuthManager.shared.createRequest(with: url, type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "NoData", code: 0, userInfo: nil)))
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(FollowedArtistsResponse.self, from: data)
                    completion(.success(decodedResponse.artists.items))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    func getUserProfile(userID: String,completion : @escaping (Result<UserProfile,Error>)->Void){
        AuthManager.shared.createRequest(
            with: URL(string: Constants.baseApiUrl + "/users/\(userID)"),
            type: .GET
        ){ request in
            let task = URLSession.shared.dataTask(with: request) { data , response, error in
                guard let data = data , error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                if let response = response as? HTTPURLResponse {
                    print(" From UserApi Response Code: \(response.statusCode)")
                }
                
                
                do {
                    let userProfile = try JSONDecoder().decode(UserProfile.self, from: data)
                    print(userProfile)
                    completion(.success(userProfile))
                } catch {
                    print("Decoding Error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            task.resume()
            
        }
    }
    
    // MARK: - Get Current User's Playlists
    public func getUserPlaylists(completion: @escaping (Result<CurrentUsersPlaylistsResponse, Error>) -> Void) {
        AuthManager.shared.createRequest(with: URL(string: "\(Constants.baseApiUrl)/me/playlists"), type: .GET) { request in
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
    
   
    
    func getUserTopItems(type: String, limit: Int = 1, completion: @escaping (Result<[TopItem], Error>) -> Void) {
        var items: [TopItem] = []
        var nextURL: URL? = URL(string: "\(Constants.baseApiUrl)/me/top/\(type)?limit=\(limit)")

        func fetchNextPage() {
            guard let url = nextURL else {
                completion(.success(items)) // Return all accumulated items
                return
            }

            AuthManager.shared.createRequest(with: url, type: .GET) { request in
                let task = URLSession.shared.dataTask(with: request) { data, _, error in
                    guard let data = data, error == nil else {
                        completion(.failure(ApiError.failedToGetData))
                        return
                    }

                    do {
                        let response = try JSONDecoder().decode(TopItemsResponse.self, from: data)
                        items.append(contentsOf: response.items ?? [])
                        nextURL = response.next.flatMap { URL(string: $0) }
                        fetchNextPage() // Fetch the next page
                    } catch {
                        completion(.failure(error))
                    }
                }
                task.resume()
            }
        }

        fetchNextPage()
    }
    
    private func constructURL(base: String, parameters: [String: String]) -> URL? {
        var components = URLComponents(string: base)
        components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        return components?.url
    }

    
    // MARK: - Helper Methods

    private func performRequest<T: Decodable>(
        url: URL?,
        responseType: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let apiURL = url else {
            completion(.failure(ApiError.invalidURL))
            return
        }
        AuthManager.shared.createRequest(with: apiURL, type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(error ?? ApiError.failedToGetData))
                    return
                }
                
                do {
                    let response = try self.decoder.decode(T.self, from: data)
//                    print(response)
                    completion(.success(response))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
}




