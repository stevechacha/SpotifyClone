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
    
    func getUserTopItems(type: String) {
        guard let url = URL(string: "\(Constants.baseAPURL)/me/top/\(type)") else {
            print("Invalid URL")
            return
        }

        AuthManager.shared.createRequest(with: url, type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Failed to fetch top \(type): \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("No data received")
                    return
                }

                self.parseTopItemsResponse(data: data)
            }
            task.resume()
        }
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




