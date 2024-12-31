//
//  TrackRecommendationsResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 29/12/2024.
//

import Foundation

struct TrackRecommendationsResponse: Codable {
    let seeds: [Seed]
    let tracks: [Track]
}

struct TrackSeed: Codable {
    let afterFilteringSize: Int
    let afterRelinkingSize: Int
    let href: String?
    let id: String
    let initialPoolSize: Int
    let type: String
}
