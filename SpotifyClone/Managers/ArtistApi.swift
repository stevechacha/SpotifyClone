//
//  ArtistApi.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//


import Foundation

final class ArtistApiCaller {
    struct Constants {
        static let artistBaseUrl = "https://api.spotify.com/v1/artists/"
        static let baseAPURL = "https://api.spotify.com/v1"
    }
    
    private let decoder: JSONDecoder
    
    init() {
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .useDefaultKeys
        decoder.dateDecodingStrategy = .iso8601 // If using Date type for lastUpdated
    }
    
    ////Get Recommendations
    //curl --request GET \
    //  --url 'https://api.spotify.com/v1/recommendations?seed_artists=4NHQUGzhtTLFvgF5SZesLK&seed_genres=classical%2Ccountry&seed_tracks=0c6xIDDpzE81m2q797ordA' \
    //  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
    //
    //@Get(/recommendations?)
    
    func getRecommedationsArtist(genres: Set<String>, completion: @escaping ((Result<RecommendationsResponse,Error>)->Void)){
        let seeds = genres.joined(separator: ",")
        createRequest(
            with: URL(string: Constants.baseAPURL + "/recommendations?seed_artists"),
            type: .GET
        ){ request in
            let task = URLSession.shared.dataTask(with: request){ data, _, error in
                guard let data = data , error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(RecommendationsResponse.self, from: data)
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
    
    // Get Several Artists
    // curl --request GET \
    //--url 'https://api.spotify.com/v1/artists?ids=2CIMQHirSU0MQqyYHq0eOx%2C57dN52uHvrHOxijzpIgu3E%2C1vCWHaC5f2uS3yhpwWbIA6' \
    //--header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
    // @GET(ttps://api.spotify.com/v1/artists/artists)
    // @return response should a list of  SpotifyArtistResponse
    
    func getArtistAlbums() async throws ->  [SpotifyArtistsResponse] {
        let getArtistUrl = Constants.artistBaseUrl + "artists"
        
        guard let url = URL(string: getArtistUrl) else {
            throw ArtistApiError.invalidURL
        }
        do{
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else {
                throw ArtistApiError.invalidResponse(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
            }
            // Debugging: Print received JSON
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Received JSON: \(jsonString)")
            }
            
            do {
                let coins = try decoder.decode([SpotifyArtistsResponse].self, from: data)
                return coins
            } catch let decodingError as DecodingError {
                print("Decoding Error: \(decodingError)")
                throw ArtistApiError.decodeDataError
            }
            
        } catch let error as ArtistApiError {
            throw error
        } catch {
            throw ArtistApiError.unableToComplete(description: error.localizedDescription)
        }
    }
    //Get Artist // Details
    //curl --request GET \
    //  --url https://api.spotify.com/v1/artists/0TnOYISbd1XYRBk9myaseg \
    //  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
    // @GET(https://api.spotify.com/v1/artists/{id}
    // SpotifyArtistsDetailResponse
    
    public func getAlbumDetails(completion: @escaping (Result<SpotifyArtistsDetailResponse,Error>)-> Void){
        createRequest(with: URL(string: Constants.artistBaseUrl + "/id"), type: .GET) { request in
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
    
    //Get Artist's Albums
    // return SpotifyArtistsAlbumsResponse
    //curl --request GET \
    //--url https://api.spotify.com/v1/artists/0TnOYISbd1XYRBk9myaseg/albums \
    //--header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
    // @GET(https://api.spotify.com/v1/artists/{id}/albums
    
    public func getArtistAlbums(completion: @escaping (Result<SpotifyArtistsAlbumsResponse,Error>)-> Void){
        createRequest(with: URL(string: Constants.artistBaseUrl + "/id" + "albums"), type: .GET) { request in
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
    
    // Get Artist's Top Tracks
    //curl --request GET \
    //  --url https://api.spotify.com/v1/artists/0TnOYISbd1XYRBk9myaseg/top-tracks \
    //  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
    // @GET(https://api.spotify.com/v1/artists/{id}/top-tracks \
    // Returns the response SpotifyArtistsTopTracksResponse
    
    public func getArtistsTopTracks(completion: @escaping (Result<SpotifyArtistsTopTracksResponse,Error>)-> Void){
        createRequest(with: URL(string: Constants.artistBaseUrl + "/id" + "top-tracks"), type: .GET) { request in
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
    
    //curl --request GET \
    //--url https://api.spotify.com/v1/artists/0TnOYISbd1XYRBk9myaseg/related-artists \
    //--header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
    // @GET(https://api.spotify.com/v1/artists/{id}/related-artists)
    // SpotifyArtistRelatedArtistsResponse
    
    public func getArtistsRelatedArtist(completion: @escaping (Result<SpotifyArtistRelatedArtistsResponse,Error>)-> Void){
        createRequest(with: URL(string: Constants.artistBaseUrl + "/id" + "related-artists"), type: .GET) { request in
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
    




enum ArtistApiError : LocalizedError {
    case invalidURL
    case invalidResponse(statusCode: Int)
    case decodingError
    case unableToComplete(description: String)
    case unknownError(error: Error)
    case jsonParsingFailure
    case decodeDataError
    
    var errorDescription: String? {
        switch self {
        case .decodeDataError: return "Faild to decode data"
        case .invalidURL:
            return "The URL provided was invalid."
        case .invalidResponse(let statusCode):
            return "Received invalid response from server with status code \(statusCode)."
        case .decodingError:
            return "Failed to decode the response."
        case .unableToComplete(let description):
            return "Unable to complete the request: \(description)"
        case .unknownError(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        case .jsonParsingFailure:
            return "Failed to parse JSON data."
        }
        
    }

}


