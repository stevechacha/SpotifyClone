//
//  Tracks.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//


import Foundation

struct Tracks: Codable {
    let href: String
    let limit: Int
    let next: String?
    let offset: Int
    let previous: String?
    let total: Int
    let items: [TrackItem]?
    
}

struct TrackItem: Codable {
    let artists: [Artist]?
    let availableMarkets: [String]
    let discNumber: Int
    let durationMs: Int
    let explicit: Bool
    let externalUrls: ExternalUrls?
    let href: String
    let id: String
    let isPlayable: Bool
    let linkedFrom: LinkedFrom?
    let restrictions: Restrictions?
    let name: String
    let previewUrl: String?
    let trackNumber: Int
    let type: String
    let uri: String
    let isLocal: Bool

    enum CodingKeys: String, CodingKey {
        case artists
        case availableMarkets = "available_markets"
        case discNumber = "disc_number"
        case durationMs = "duration_ms"
        case explicit
        case externalUrls = "external_urls"
        case href, id
        case isPlayable = "is_playable"
        case linkedFrom = "linked_from"
        case restrictions, name
        case previewUrl = "preview_url"
        case trackNumber = "track_number"
        case type, uri
        case isLocal = "is_local"
    }
}
