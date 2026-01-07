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
    case rateLimitExceeded(retryAfter: String? = nil)
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
    
    /// User-friendly error message for display in UI
    var userMessage: String {
        switch self {
        case .code:
            return "Authentication failed. Please try logging in again."
        case .tokenNotFound:
            return "Your session has expired. Please log in again."
        case .invalidInput:
            return "Invalid input. Please check your search and try again."
        case .invalidURL:
            return "Something went wrong. Please try again."
        case .failedToGetData:
            return "Unable to load data. Please check your internet connection."
        case .decodeError, .decodingError:
            return "Unable to process the response. Please try again."
        case .rateLimitExceeded(let retryAfter):
            if let retryAfter = retryAfter, let seconds = Int(retryAfter) {
                return "Too many requests. Please wait \(seconds) seconds and try again."
            }
            return "Too many requests. Please wait a moment and try again."
        case .invalidResponse(let statusCode):
            switch statusCode {
            case 401:
                return "Your session has expired. Please log in again."
            case 403:
                return "You don't have permission to access this."
            case 404:
                return "The requested item was not found."
            case 429:
                return "Too many requests. Please wait a moment."
            case 500...599:
                return "Server error. Please try again later."
            default:
                return "Something went wrong. Please try again."
            }
        case .noGenresAvailable:
            return "No genres are currently available."
        case .apiError(let message):
            return "Error: \(message)"
        case .encodingError(let message):
            return "Encoding error: \(message)"
        case .unknownError(let message):
            return "An unexpected error occurred: \(message)"
        case .jsonSerializationFailed, .jsonParsingFailed:
            return "Unable to process the data. Please try again."
        }
    }
    
    /// Suggested recovery action for the error
    var recoveryAction: String? {
        switch self {
        case .tokenNotFound, .code:
            return "Log In"
        case .failedToGetData:
            return "Retry"
        case .rateLimitExceeded:
            return "Wait"
        case .invalidResponse(let statusCode) where statusCode == 401:
            return "Log In"
        default:
            return nil
        }
    }
}
