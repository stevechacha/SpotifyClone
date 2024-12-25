//
//  ApiCaller.swift
//  SpotifyClone
//
//  Created by stephen chacha on 04/12/2024.
//

import Foundation

final class ApiCaller {
    static let shared = ApiCaller()
    
    private init() {}
    
    struct Constants {
        static let baseAPURL = "https://api.spotify.com/v1"

    }
    
    public func getAlbum(albumIDs: [String], completion: @escaping (Result<SpotifyAlbumResponse, Error>) -> Void) {
        // Ensure the album IDs are joined as a comma-separated string
        let idsParam = albumIDs.joined(separator: ",")
        guard let url = URL(string: Constants.baseAPURL + "/albums?ids=\(idsParam)") else {
            completion(.failure(ApiError.invalidURL))
            return
        }
        
        // Call createRequest with the correct URL and make the request
        createRequest(with: url, type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                do {
                    // Try to decode the response
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    // Check if the response contains an error (API error like the "missing ids")
                    if let jsonObject = try? JSONSerialization.jsonObject(with: data),
                       let jsonDict = jsonObject as? [String: Any],
                       jsonDict["error"] != nil {
                        // Decode the error response and handle it
                        let errorResponse = try decoder.decode(SpotifyAPIErrorResponse.self, from: data)
                        print("API Error:", errorResponse.error.message)
                        completion(.failure(ApiError.apiError(errorResponse.error.message)))
                        return
                    }
                    
                    // Decode the success response if no error
                    let decodedResponse = try decoder.decode(SpotifyAlbumResponse.self, from: data)
                    completion(.success(decodedResponse))
                    
                } catch let DecodingError.keyNotFound(key, context) {
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("CodingPath:", context.codingPath)
                    completion(.failure(ApiError.decodingError("Key '\(key)' not found in JSON.")))
                } catch let DecodingError.valueNotFound(value, context) {
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("CodingPath:", context.codingPath)
                    completion(.failure(ApiError.decodingError("Value '\(value)' is missing in JSON.")))
                } catch let DecodingError.typeMismatch(type, context) {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("CodingPath:", context.codingPath)
                    completion(.failure(ApiError.decodingError("Type mismatch for type '\(type)'.")))
                } catch {
                    print("Error decoding JSON:", error.localizedDescription)
                    completion(.failure(ApiError.decodingError("Unexpected decoding error: \(error.localizedDescription)")))
                }
            }
            task.resume()
        }
    }

    
    
    
    public func getAlbumDetails(for album: Album , completion: @escaping (Result<String,Error>)-> Void){
        createRequest(with: URL(string: Constants.baseAPURL + "/albums/" + album.id), type: .GET) { request in
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
    
    func getCurrentProfile(completion : @escaping (Result<UserProfile, Error>)-> Void){
        createRequest(
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
    
    // MARK: - Get Current User Profile
    public func getCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        guard let token = AuthManager.shared.accessToken else {
            completion(.failure(ApiError.tokenNotFound))
            return
        }
        
        guard let url = URL(string:Constants.baseAPURL + "/me") else {
            completion(.failure(ApiError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(ApiError.failedToGetData))
                return
            }
            
            do {
                let userProfile = try JSONDecoder().decode(UserProfile.self, from: data)
                print("user json \(userProfile)")
                completion(.success(userProfile))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    
    


    public func getSavedShows(completion: @escaping (Result<UsersSavedShows, Error>) -> Void) {
        guard let token = AuthManager.shared.accessToken else {
            completion(.failure(ApiError.tokenNotFound))
            return
        }
        
        guard let url = URL(string: Constants.baseAPURL + "/me/shows?offset=0&limit=20") else {
            completion(.failure(ApiError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(ApiError.failedToGetData))
                return
            }
            
            do {
                let showsResponse = try JSONDecoder().decode(UsersSavedShows.self, from: data)
                print("showsResponse json \(showsResponse)")
                completion(.success(showsResponse))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    
    
    func getFeaturedPlayLists(completion: @escaping ((Result<FeaturedPlayListResponse, Error>) -> Void )){
        createRequest(with: URL(string: Constants.baseAPURL + "/browse/featured-playlists"), type: .GET){ request in
            let task = URLSession.shared.dataTask(with: request) { data , _, error in
                guard let data = data , error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(FeaturedPlayListResponse.self, from: data)
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
    }
}

struct SpotifyAPIErrorResponse: Decodable {
    let error: SpotifyErrorDetails
}

struct SpotifyErrorDetails: Decodable {
    let status: Int
    let message: String
}




