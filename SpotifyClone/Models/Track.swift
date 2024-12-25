//
//  Track.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//

import Foundation

//curl --request GET \
//  --url https://api.spotify.com/v1/tracks/11dFghVXANMlKmJXsNCbNl \
//  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
//Get Track
//@GET(/tracks/{id})
// MARK: - Track
struct Track: Codable {
    let album: Album?
    let artists: [Artist]?
    let availableMarkets: [String]?
    let discNumber: Int?
    let durationMs: Int?
    let explicit: Bool?
    let externalIds: ExternalIds?
    let externalUrls: ExternalURLs?
    let href: String?
    let id: String?
    let isPlayable: Bool?
    let linkedFrom: [String: String]?
    let restrictions: Restrictions?
    let name: String?
    let popularity: Int?
    let previewUrl: String?
    let trackNumber: Int?
    let type: String?
    let uri: String?
    let isLocal: Bool?
    
    enum CodingKeys: String, CodingKey {
        case album, artists
        case availableMarkets = "available_markets"
        case discNumber = "disc_number"
        case durationMs = "duration_ms"
        case explicit
        case externalIds = "external_ids"
        case externalUrls = "external_urls"
        case href, id
        case isPlayable = "is_playable"
        case linkedFrom = "linked_from"
        case restrictions, name, popularity
        case previewUrl = "preview_url"
        case trackNumber = "track_number"
        case type, uri
        case isLocal = "is_local"
    }
}

