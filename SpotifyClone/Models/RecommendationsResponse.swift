//
//  RecommendationsResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 05/12/2024.
//

import Foundation


// MARK: - RecommendationsResponse
struct RecommendationsResponse: Codable {
    let tracks: [Track]
}


struct RecommendAudioTracks: Codable {
    let album: Album
    let artists: [Artist]
    let available_markets: [String]
    let disc_number: Int
    let duration_ms: Int
    let explicit: Bool
    let external_urls: [String: String]
    let id: String
    let name: String
    let popularity: Int
}













