//
//  UserProfile.swift
//  SpotifyClone
//
//  Created by stephen chacha on 04/12/2024.
//

import Foundation

// MARK: - UserProfile Model
struct UserProfile: Codable {
    let id: String
    let display_name: String
    let email: String?
    let country: String?
    let product: String?// Free, Premium, etc.
    let external_urls: [String: String] // Spotify profile links
    let images: [APIImage]?
}



// MARK: - ApiError Enum
enum ApiError: LocalizedError {
    case code
    case tokenNotFound
    case invalidURL
    case failedToGetData
    case decodeError
    case invalidResponse
    case noGenresAvailable
    case apiError(String) // New case for handling API errors
    case decodingError(String) // Add this case to handle decoding errors

    var errorDescription: String? {
        switch self {
        case .code : return "api code error"
        case .apiError(let message): // Use the associated value
            return "API Error: \(message)"
        case .decodingError(let message): // Use the associated value
            return "Decoding Error: \(message)"
        case .invalidResponse:
            return "The server returned an invalid response."
        case .tokenNotFound:
            return "Failed to find the token."
        case .invalidURL:
            return "Invalid URL."
        case .failedToGetData:
            return "No data found."
        case .decodeError:
            return "Failed to decode data."
        case .noGenresAvailable:
            return "No genres available in the response."
        }
    }
}
