//
//  MarketApi.swift
//  SpotifyClone
//
//  Created by stephen chacha on 25/12/2024.
//
import Foundation

final class MarketApiCaller {
    
    public func getMarkets(completion: @escaping (Result<MarketResponse,Error>)-> Void){
        AuthManager.shared.createRequest(with: URL(string: "https://api.spotify.com/v1/markets"), type: .GET) { request in
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
}
