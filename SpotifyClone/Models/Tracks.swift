//
//  Tracks.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//


import Foundation

struct Tracks: Codable {
    let href: String?
    let limit: Int?
    let next: String?
    let offset: Int?
    let previous: String?
    let total: Int?
    let items: [Track]?  // Optional, since it might be missing or empty

    enum CodingKeys: String, CodingKey {
        case href
        case limit
        case next
        case offset
        case previous
        case total
        case items
    }
}



struct Track: Codable {
    let artists: [Artist]?
    let album: Album?
    let availableMarkets: [String]?
    let discNumber: Int?
    let durationMs: Int?
    let explicit: Bool?
    let externalUrls: ExternalUrls?
    let externalIds: ExternalIds?
    let href: String?
    let id: String
    let isPlayable: Bool?
    let linkedFrom: LinkedFrom?
    let restrictions: Restrictions?
    let name: String
    let popularity: Int?
    let previewUrl: String?
    let trackNumber: Int
    let type: String?
    let uri: String?
    let isLocal: Bool?

    enum CodingKeys: String, CodingKey {
        case artists, album
        case availableMarkets = "available_markets"
        case discNumber = "disc_number"
        case durationMs = "duration_ms"
        case explicit
        case externalIds = "external_ids"
        case externalUrls = "external_urls"
        case href, id
        case isPlayable = "is_playable"
        case linkedFrom = "linked_from"
        case restrictions, name,popularity
        case previewUrl = "preview_url"
        case trackNumber = "track_number"
        case type, uri
        case isLocal = "is_local"
    }
    
}

