//
//  MarketApi.swift
//  SpotifyClone
//
//  Created by stephen chacha on 25/12/2024.
//
import Foundation

final class MarketApiCaller {
    // Get Available Markets
    //curl --request GET \
    //  --url https://api.spotify.com/v1/markets \
    //  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
    
    public func getMarkets(completion: @escaping (Result<MarketResponse,Error>)-> Void){
        createRequest(with: URL(string: "https://api.spotify.com/v1/markets"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request){ data, _ , error in
                guard let data = data , error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                do {
                    let json = try JSONSerialization.jsonObject(with: data , options: .allowFragments)
                    print(json)
                } catch {
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
