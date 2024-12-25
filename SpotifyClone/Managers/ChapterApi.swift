//
//  ChapterApi.swift
//  SpotifyClone
//
//  Created by stephen chacha on 25/12/2024.
//

import Foundation

final  class ChapterApiCaller {
    
    //Get Several Chapters
    //curl --request GET \
    //--url 'https://api.spotify.com/v1/chapters?ids=0IsXVP0JmcB2adSE338GkK%2C3ZXb8FKZGU0EHALYX6uCzU%2C0D5wENdkdwbqlrHoaJ9g29' \
    //--header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
    // @GET(https://api.spotify.com/v1/chapters)
    
    public func getSeveralChapters(completion: @escaping (Result<ChaptersResponse,Error>)-> Void){
        createRequest(with: URL(string: "https://api.spotify.com/v1/chapters"), type: .GET) { request in
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
    
    //Get a Chapter // Chapter Details
    //curl --request GET \
    //  --url https://api.spotify.com/v1/chapters/0D5wENdkdwbqlrHoaJ9g29 \
    //  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
    //@GET(https://api.spotify.com/v1/chapters/{id}
    // MARK: - Chapter Structure
    
    public func getChaptersDetails(completion: @escaping (Result<Chapter,Error>)-> Void){
        createRequest(with: URL(string: "https://api.spotify.com/v1/chapters/{id}"), type: .GET) { request in
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
