//
//  PlaylistApi.swift
//  SpotifyClone
//
//  Created by stephen chacha on 25/12/2024.
//
import Foundation

final class PlaylistApiCaller {
    
    
    struct Constants {
        static let baseAPURL = "https://api.spotify.com/v1"

    }
    //playlists/{playlist_id}/tracks
    // curl --request PUT \
    //--url https://api.spotify.com/v1/playlists/3cEYpjA9oz9GiPac4AsH4n/tracks \
    //--header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z' \
    //--header 'Content-Type: application/json' \
    //--data '{
    //  "range_start": 1,
    //  "insert_before": 3,
    //  "range_length": 2
    //}'
    // UpdatePlaylistItems
    
    
    //Get Current User's Playlists
    //curl --request GET \
    //  --url https://api.spotify.com/v1/me/playlists \
    //  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
    // @GET(/me/playlists)
    
    
    public func getCurrentUsersPlaylist(completion: @escaping (Result<CurrentUsersPlaylistsResponse,Error>)-> Void){
        createRequest(with: URL(string: "https://api.spotify.com/v1/me/playlists"), type: .GET) { request in
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
    
    //curl --request POST \
    //  --url https://api.spotify.com/v1/users/smedjan/playlists \
    //  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z' \
    //  --header 'Content-Type: application/json' \
    //  --data '{
    //    "name": "New Playlist",
    //    "description": "New playlist description",
    //    "public": false
    //}'
    // @POST(/users/{user_id}/playlists)
    // MARK: - CreatePlaylistResponse
    
    
    public func createPlaylist(completion: @escaping (Result<CurrentUsersPlaylistsResponse,Error>)-> Void){
        createRequest(with: URL(string: "https://api.spotify.com/v1/users/{user_id}/playlists"), type: .POST) { request in
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
    
    
    //Get Featured Playlists
    //curl --request GET \
    //  --url https://api.spotify.com/v1/browse/featured-playlists \
    //  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
    // @GET(https://api.spotify.com/v1/browse/featured-playlists)
    
    public func getFeaturedPlaylist(completion: @escaping (Result<FeaturedPlayListResponse,Error>)-> Void){
        createRequest(with: URL(string: "https://api.spotify.com/v1/browse/featured-playlists"), type: .GET) { request in
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
    
    
    //// Get Playlist
    //curl --request GET \
    //  --url https://api.spotify.com/v1/playlists/3cEYpjA9oz9GiPac4AsH4n \
    //  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
    // @GET(https://api.spotify.com/v1/playlists/player_list_id)
    // response Playlist
    
    func getPlaylist(genres: Set<String>, completion: @escaping ((Result<Playlists,Error>)->Void)){
        let seeds = genres.joined(separator: ",")
        createRequest(
            with: URL(string: Constants.baseAPURL + "/playlists/player_list_id"),
            type: .GET
        ){ request in
            let task = URLSession.shared.dataTask(with: request){ data, _, error in
                guard let data = data , error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(Playlists.self, from: data)
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
    
    // Change Playlist Details
    // data added Playlist
    //curl --request PUT \
    //  --url https://api.spotify.com/v1/playlists/3cEYpjA9oz9GiPac4AsH4n \
    //  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z' \
    //  --header 'Content-Type: application/json' \
    //  --data '{
    //    "name": "Updated Playlist Name",
    //    "description": "Updated playlist description",
    //    "public": false
    //}'

    // @PUT(https://api.spotify.com/v1/playlists/player_list_id)
    
    func savePlaylist(genres: Set<String>, completion: @escaping ((Result<Playlists,Error>)->Void)){
        let seeds = genres.joined(separator: ",")
        createRequest(
            with: URL(string: Constants.baseAPURL + "/playlists/player_list_id"),
            type: .PUT
        ){ request in
            let task = URLSession.shared.dataTask(with: request){ data, _, error in
                guard let data = data , error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(Playlists.self, from: data)
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

    //Get Playlist Items
    ///playlists/{playlist_id}/tracks
    ///curl --request GET \
    //--url https://api.spotify.com/v1/playlists/3cEYpjA9oz9GiPac4AsH4n/tracks \
    //--header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'

    // MARK: - PlayerListShowItem
    
    func getPlaylistTracks(genres: Set<String>, completion: @escaping ((Result<PlayerListShowItem,Error>)->Void)){
        let seeds = genres.joined(separator: ",")
        createRequest(
            with: URL(string: Constants.baseAPURL + "/playlists/{playlist_id}/tracks"),
            type: .PUT
        ){ request in
            let task = URLSession.shared.dataTask(with: request){ data, _, error in
                guard let data = data , error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(PlayerListShowItem.self, from: data)
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
        case PUT
    }

}
