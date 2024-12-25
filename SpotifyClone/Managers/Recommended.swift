//
//  Recommended.swift
//  SpotifyClone
//
//  Created by stephen chacha on 25/12/2024.
//
import Foundation

final class RecommendedApiCaller {
    
    static let shared = RecommendedApiCaller()

    
    struct Constants {
        static let baseAPURL = "https://api.spotify.com/v1"

    }
    // Get Recommendations
    //curl --request GET \
    //  --url 'https://api.spotify.com/v1/recommendations?seed_artists=4NHQUGzhtTLFvgF5SZesLK&seed_genres=classical%2Ccountry&seed_tracks=0c6xIDDpzE81m2q797ordA' \
    //  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
    // MARK: - RecommendationsResponse
    //@Get(/recommendations?)
    
    
    func getRecommedations(genres: Set<String>, completion: @escaping ((Result<RecommendationsResponse,Error>)->Void)){
        let seeds = genres.joined(separator: ",")
        createRequest(
            with: URL(string: Constants.baseAPURL + "/recommendations?limit=50&seed_genres=\(seeds)"),
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
    
    //Get Available Genre Seeds
    //curl --request GET \
    //  --url https://api.spotify.com/v1/recommendations/available-genre-seeds \
    //  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
    // return GenresResponse
    //@GET"(recommendations/available-genre-seeds

    func getRecommendedGenre(genres: Set<String>, completion: @escaping ((Result<GenresResponse,Error>)->Void)) {
        let genreUrl = "https://api.spotify.com/v1/recommendations/available-genre-seeds"
        createRequest(
            with: URL(string: genreUrl),
            type: .GET
        ) { request in
            // Debugging logs
            print("Request URL: \(request.url?.absoluteString ?? "Invalid URL")")
            print("Authorization Header: \(request.allHTTPHeaderFields?["Authorization"] ?? "No Authorization Header")")

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    completion(.failure(ApiError.failedToGetData))
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("HTTP Status Code: \(httpResponse.statusCode)")
                    if !(200...299).contains(httpResponse.statusCode) {
                        print("Unexpected HTTP Status Code: \(httpResponse.statusCode)")
                        if let data = data {
                            print("Error Response Body: \(String(data: data, encoding: .utf8) ?? "No Data")")
                        }
                        completion(.failure(ApiError.failedToGetData))
                        return
                    }
                }

                guard let data = data else {
                    print("No data received")
                    completion(.failure(ApiError.failedToGetData))
                    return
                }

                do {
                    let result = try JSONDecoder().decode(GenresResponse.self, from: data)
                    print("Recommended Genres: \(result)")
                    completion(.success(result))
                } catch {
                    print("Decoding Error: \(error.localizedDescription)")
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
