//
//  UserProfile.swift
//  SpotifyClone
//
//  Created by stephen chacha on 04/12/2024.
//

import Foundation

// MARK: - UserProfile Model
struct UserProfile: Codable {
    let id: String?
    let display_name: String?
    let followers: Followers?
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
    case invalidInput
    case invalidURL
    case failedToGetData
    case decodeError
    case encodingError(String) // Add this case for encoding errors
    case invalidResponse(statusCode: Int) // Now properly expects an Int argument
    case noGenresAvailable
    case apiError(String) // Handles specific API errors with a message
    case decodingError(String) // Correctly named to handle decoding errors
    case unknownError(String) // Handles unexpected errors with a message
    case rateLimitExceeded

    var errorDescription: String? {
        switch self {
        case .rateLimitExceeded: return "Exceded limit"
        case .code:
            return "API code error."
        case .tokenNotFound:
            return "Failed to find the token."
        case .invalidURL:
            return "Invalid URL."
        case .failedToGetData:
            return "Failed to retrieve data."
        case .decodeError:
            return "Failed to decode data."
        case .encodingError(let message):
            return "Encoding Error: \(message)"
        case .invalidResponse(let statusCode):
            return "The server returned an invalid response (HTTP \(statusCode))."
        case .noGenresAvailable:
            return "No genres available in the response."
        case .apiError(let message):
            return "API Error: \(message)"
        case .decodingError(let message):
            return "Decoding Error: \(message)"
        case .unknownError(let message):
            return "An unknown error occurred: \(message)"
        case .invalidInput:
            return "Invalid Input"
        }
    }
}


