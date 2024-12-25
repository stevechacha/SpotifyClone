//
//  AlbumApi.swift
//  SpotifyClone
//
//  Created by stephen chacha on 25/12/2024.
//
import Foundation

final class AlbumApiCaller {
    
    static let shared = AlbumApiCaller()
    
    private init() {}
    
    struct Constants {
        static let baseAPURL = "https://api.spotify.com/v1"

    }
    //Get Album
    //curl --request GET \
    //  --url https://api.spotify.com/v1/albums/4aawyAB9vmqN3uQ7FjRGTy \
    //  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
    // Return Response should be Album
    // @Get(https://api.spotify.com/v1/albums/{id}
    
    func getAlbum(completion: @escaping ((Result<Album, Error>) -> Void )){
        createRequest(with: URL(string: Constants.baseAPURL + "albums/{id}"), type: .GET){ request in
            let task = URLSession.shared.dataTask(with: request) { data , _, error in
                guard let data = data , error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(Album.self, from: data)
                    print("result\(result)")
                    completion(.success(result))
                }
                
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
            
        }
    }

    //Get Several Albums
    //curl --request GET \
    //  --url 'https://api.spotify.com/v1/albums?ids=382ObEPsp2rxGrnsizN5TX%2C1A2GTWGtFfWp7KSQTwWOyo%2C2noRn2Aes5aoNVsU6iWThc' \
    //  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
    // @Return Response of list of SpotifyAlbumResponse
    // @Get(https://api.spotify.com/v1/albums
    
    func getAlbum(completion: @escaping ((Result<AlbumsResponse, Error>) -> Void )){
        createRequest(with: URL(string: Constants.baseAPURL + "albums"), type: .GET){ request in
            let task = URLSession.shared.dataTask(with: request) { data , _, error in
                guard let data = data , error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(AlbumsResponse.self, from: data)
                    print("result\(result)")
                    completion(.success(result))
                }
                
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
            
        }
    }

    //Get Album Tracks
    //curl --request GET \
    //  --url https://api.spotify.com/v1/albums/4aawyAB9vmqN3uQ7FjRGTy/tracks \
    //  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
    // @GET(https://api.spotify.com/v1/albums/{id}/tracks
    // Response should be Tracks
    
    func getAlbumTracks(completion: @escaping ((Result<Tracks, Error>) -> Void )){
        createRequest(with: URL(string: Constants.baseAPURL + "albums/{id}/tracks"), type: .GET){ request in
            let task = URLSession.shared.dataTask(with: request) { data , _, error in
                guard let data = data , error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(Tracks.self, from: data)
                    print("result\(result)")
                    completion(.success(result))
                }
                
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
            
        }
    }


    //Get User's Saved Albums
    //curl --request GET \
    //  --url https://api.spotify.com/v1/me/albums \
    //  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
    //@Get(https://api.spotify.com/v1/me/albums
    // Response should be SpotifyUsersSavedResponse
    
    func getSavedAlbum(completion: @escaping ((Result<SpotifyUsersSavedResponse, Error>) -> Void )){
        createRequest(with: URL(string: Constants.baseAPURL + "me/albums"), type: .GET){ request in
            let task = URLSession.shared.dataTask(with: request) { data , _, error in
                guard let data = data , error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(SpotifyUsersSavedResponse.self, from: data)
                    print("result\(result)")
                    completion(.success(result))
                }
                
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
            
        }
    }


    //Save Albums for Current User
    //curl --request PUT \
    //  --url 'https://api.spotify.com/v1/me/albums?ids=382ObEPsp2rxGrnsizN5TX%2C1A2GTWGtFfWp7KSQTwWOyo%2C2noRn2Aes5aoNVsU6iWThc' \
    //  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z' \
    //  --header 'Content-Type: application/json' \
    //  --data '{
    //    "ids": [
    //        "string"
    //    ]
    //}'
    //@PUT(https://api.spotify.com/v1/me/albums)
    
    func saveAlbumsCurrentUser(completion: @escaping ((Result<SpotifyUsersSavedResponse, Error>) -> Void )){
        createRequest(with: URL(string: Constants.baseAPURL + "me/albums"), type: .PUT){ request in
            let task = URLSession.shared.dataTask(with: request) { data , _, error in
                guard let data = data , error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(SpotifyUsersSavedResponse.self, from: data)
                    print("result\(result)")
                    completion(.success(result))
                }
                
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
            
        }
    }

    //Remove Users' Saved Albums
    //curl --request DELETE \
    //--url 'https://api.spotify.com/v1/me/albums?ids=382ObEPsp2rxGrnsizN5TX%2C1A2GTWGtFfWp7KSQTwWOyo%2C2noRn2Aes5aoNVsU6iWThc' \
    //--header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z' \
    //--header 'Content-Type: application/json' \
    //--data '{
    //  "ids": [
    //      "string"
    //  ]
    //}'
    //@DELETE(https://api.spotify.com/v1/me/albums)
    
    func removeUsersSavedAlbums(completion: @escaping ((Result<SpotifyUsersSavedResponse, Error>) -> Void )){
        createRequest(with: URL(string: Constants.baseAPURL + "me/albums"), type: .DELETE){ request in
            let task = URLSession.shared.dataTask(with: request) { data , _, error in
                guard let data = data , error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(SpotifyUsersSavedResponse.self, from: data)
                    print("result\(result)")
                    completion(.success(result))
                }
                
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
            
        }
    }


    //Get New Releases

    //curl --request GET \
    //  --url https://api.spotify.com/v1/browse/new-releases \
    //  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
    // @GET(https://api.spotify.com/v1/browse/new-releases)
    // // Response should be SpotifyNewReleasesAlbumsResponse
    
    func getNewReleases(completion: @escaping ((Result<SpotifyNewReleasesAlbumsResponse, Error>) -> Void )){
        createRequest(with: URL(string: Constants.baseAPURL + "browse/new-releases"), type: .DELETE){ request in
            let task = URLSession.shared.dataTask(with: request) { data , _, error in
                guard let data = data , error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(SpotifyNewReleasesAlbumsResponse.self, from: data)
                    print("result\(result)")
                    completion(.success(result))
                }
                
                catch {
                    print(error.localizedDescription)
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
        case DELETE
    }

}
