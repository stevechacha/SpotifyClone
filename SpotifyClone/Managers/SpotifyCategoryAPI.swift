//
//  SpotifyCategoryAPI.swift
//  SpotifyClone
//
//  Created by stephen chacha on 10/01/2025.
//


import Foundation

class SpotifyCategoryAPI {
    static let shared = SpotifyCategoryAPI()

    // Fetch categories from Spotify API
    func getSeveralBrowseCategories(
        completion: @escaping (Result<[SingleBrowseCategory], Error>) -> Void
    ) {
        guard let url = URL(string: "https://api.spotify.com/v1/browse/categories") else {
            completion(.failure(ApiError.invalidURL))
            return
        }

        AuthManager.shared.createRequest(with: url, type: .GET) { request in
            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(SpotifyBrowseCategories.self, from: data)
                    completion(.success(response.items))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
    }
    
    func getSeveralBrowseCategories(
        categoryId: String,
        completion: @escaping (Result<SingleBrowseCategory, Error>) -> Void
    ) {
        guard let url = URL(string: "https://api.spotify.com/v1/browse/categories/\(categoryId)") else {
            completion(.failure(ApiError.invalidURL))
            return
        }

        AuthManager.shared.createRequest(with: url, type: .GET) { request in
            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(SingleBrowseCategory.self, from: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
    }
}

