//
//  UserProfile.swift
//  SpotifyClone
//
//  Created by stephen chacha on 04/12/2024.
//

// MARK: - UserProfile Model
struct UserProfile: Codable {
    let id: String
    let display_name: String
    let email: String
    let country: String
    let product: String // Free, Premium, etc.
    let external_urls: [String: String] // Spotify profile links
    let images: [APIImage]?
}

struct APIImage: Codable {
    let url: String
}

// MARK: - ApiError Enum
enum ApiError: Error {
    case tokenNotFound
    case invalidURL
    case noData
}

