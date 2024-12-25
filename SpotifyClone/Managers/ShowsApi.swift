//
//  ShowsApi.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
import Foundation

final class ShowsApiCaller {
    // curl --request GET \
    //  --url https://api.spotify.com/v1/me/shows \
    // --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
    //Get User's Saved Shows
    //@GET(/me/shows)
    //UsersSavedShows
    
    static let shared = ShowsApiCaller()
    
    private init() {}
    
    struct Constants {
        static let baseAPURL = "https://api.spotify.com/v1"

    }
    
    public func getArtistAlbums(completion: @escaping (Result<UsersSavedShows,Error>)-> Void){
        createRequest(with: URL(string: "https://api.spotify.com/v1/me/shows"), type: .GET) { request in
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
    
    //Get Show Episodes
    //curl --request GET \
    //  --url https://api.spotify.com/v1/shows/38bS44xjbVVZ3No3ByF1dJ/episodes \
    //  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
    //@GET(/shows/{id}/episodes)

    // MARK: - EpisodesResponse
    
    public func getShowEpisodes(completion: @escaping (Result<UsersSavedShows,Error>)-> Void){
        createRequest(with: URL(string: "https://api.spotify.com/v1/shows/38bS44xjbVVZ3No3ByF1dJ/episodes"), type: .GET) { request in
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
    
    //Get Several Shows
    //@GET(/shows)
    //curl --request GET \
    //  --url 'https://api.spotify.com/v1/shows?ids=5CfCWKI5pZ28U0uOzXkDHe%2C5as3aKmN2k11yfDDDSrvaZ' \
    //  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'

    // MARK: - ShowsResponse
    
    public func getSeveralShow(completion: @escaping (Result<UsersSavedShows,Error>)-> Void){
        createRequest(with: URL(string: "https://api.spotify.com/v1/shows"), type: .GET) { request in
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
    
    //Get Show
    //@GET(shows/id)
    //curl --request GET \
    //  --url https://api.spotify.com/v1/shows/38bS44xjbVVZ3No3ByF1dJ \
    //  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
    //// MARK: - Show
    
    //Get Show
    //@GET(shows/id)
    //curl --request GET \
    //  --url https://api.spotify.com/v1/shows/38bS44xjbVVZ3No3ByF1dJ \
    //  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
    //// MARK: - Show
    
    public func getShowDetail(completion: @escaping (Result<UsersSavedShows,Error>)-> Void){
        createRequest(with: URL(string: "https://api.spotify.com/v1/shows/{id}"), type: .GET) { request in
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
    
    ////curl --request GET \
    ////  --url https://api.spotify.com/v1/me/shows \
    ////  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
    //Get User's Saved Shows
    //@GET(/me/shows)
    //UsersSavedShows
    
    public func getUserSavedshows(completion: @escaping (Result<UsersSavedShows,Error>)-> Void){
        createRequest(with: URL(string: "https://api.spotify.com/v1/me/shows"), type: .GET) { request in
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
    
    //Get Show Episodes
    //curl --request GET \
    //  --url https://api.spotify.com/v1/shows/38bS44xjbVVZ3No3ByF1dJ/episodes \
    //  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
    //@GET(/shows/{id}/episodes)

    // MARK: - EpisodesResponse
    
    public func getShowsEpisodes(completion: @escaping (Result<UsersSavedShows,Error>)-> Void){
        createRequest(with: URL(string: "https://api.spotify.com/v1/shows/{id}/episode"), type: .GET) { request in
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











