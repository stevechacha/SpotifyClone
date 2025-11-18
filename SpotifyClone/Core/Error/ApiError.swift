//
//  ApiError.swift
//  SpotifyClone
//
//  Created by ChatGPT on 18/11/2025.
//

import Foundation

/// Canonical error type for Spotify network and parsing failures.
enum ApiError: LocalizedError {
    case code
    case tokenNotFound
    case invalidInput
    case invalidURL
    case failedToGetData
    case decodeError
    case encodingError(String)
    case invalidResponse(statusCode: Int)
    case noGenresAvailable
    case apiError(String)
    case decodingError(String)
    case unknownError(String)
    case rateLimitExceeded
    case jsonSerializationFailed
    case jsonParsingFailed

    var errorDescription: String? {
        switch self {
        case .code:
            return "API code error"
        case .tokenNotFound:
            return "Missing access token"
        case .invalidInput:
            return "Invalid input provided"
        case .invalidURL:
            return "Invalid URL"
        case .failedToGetData:
            return "Failed to retrieve data"
        case .decodeError:
            return "Failed to decode data"
        case .encodingError(let message):
            return "Encoding error: \(message)"
        case .invalidResponse(let statusCode):
            return "Unexpected HTTP response (\(statusCode))"
        case .noGenresAvailable:
            return "No genres available in the response"
        case .apiError(let message):
            return "API error: \(message)"
        case .decodingError(let message):
            return "Decoding error: \(message)"
        case .unknownError(let message):
            return "Unknown error: \(message)"
        case .rateLimitExceeded:
            return "Rate limit exceeded"
        case .jsonSerializationFailed:
            return "JSON serialization failed"
        case .jsonParsingFailed:
            return "JSON parsing failed"
        }
    }
}
