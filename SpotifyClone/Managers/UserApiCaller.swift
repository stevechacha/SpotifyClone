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
    
}

struct SpotifyAPIErrorResponse: Decodable {
    let error: SpotifyErrorDetails
}

struct SpotifyErrorDetails: Decodable {
    let status: Int
    let message: String
}




