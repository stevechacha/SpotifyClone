//
//  ApiCaller.swift
//  SpotifyClone
//
//  Created by stephen chacha on 04/12/2024.
//

import Foundation

final class UserApiCaller {
    static let shared = UserApiCaller()
    
    private init() {}
    
    struct Constants {
        static let baseAPURL = "https://api.spotify.com/v1"

    }
    
    
    func getCurrentUserProfile(completion : @escaping (Result<UserProfile, Error>)-> Void){
        AuthManager.shared.createRequest(
            with: URL(string: Constants.baseAPURL + "/me"),
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
                    print("Decoding Error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            task.resume()
            
        }
    }
    
    func getUserProfile(userID: String,completion : @escaping (Result<UserProfile,Error>)->Void){
        AuthManager.shared.createRequest(
            with: URL(string: Constants.baseAPURL + "/users/\(userID)"),
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
                    print("Decoding Error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            task.resume()
            
        }
    }
    
    func getUserTopItems(type: String, limit: Int = 20, completion: @escaping (Result<[TopItem], Error>) -> Void) {
        var items: [TopItem] = []
        var nextURL: URL? = URL(string: "\(Constants.baseAPURL)/me/top/\(type)?limit=\(limit)")

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

    
    func parseTopItemsResponse(data: Data) {
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(TopItemsResponse.self, from: data)
            
            // Access the top items
            for item in response.items ?? [] {
                print("Name: \(item.name)")
                print("Genres: \(item.genres?.joined(separator: ", ") ?? "Uknown Genre")")
                print("Popularity: \(item.popularity ?? 0)")
                if let imageUrl = item.images?.first?.url {
                    print("Image URL: \(imageUrl)")
                }
                print("Spotify URL: \(item.externalUrls?.spotify ?? "No Spotify Url")")
                print("Followers: \(item.followers?.total ?? 0 )")
                print("---------------------------")
            }
        } catch {
            print(error)
            print("Failed to parse top items: \(error.localizedDescription)")
        }
    }


}

struct SpotifyAPIErrorResponse: Decodable {
    let error: SpotifyErrorDetails
}

struct SpotifyErrorDetails: Decodable {
    let status: Int
    let message: String
}




