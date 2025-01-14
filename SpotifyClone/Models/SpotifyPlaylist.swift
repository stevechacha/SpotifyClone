//
//  SpotifyPlaylist.swift
//  SpotifyClone
//
//  Created by stephen chacha on 13/01/2025.
//


import Foundation

struct SpotifyPlaylist: Codable {
    let collaborative: Bool?
    let description: String?
    let externalUrls: ExternalUrls?
    let followers: Followers?
    let href: String?
    let id: String
    let images: [APIImage]?
    let name: String?
    let owner: Owner?
    let isPublic: Bool?
    let snapshotID: String?
    let tracks: SpotifyPlaylistTracks?
    let type: String?
    let uri: String?

    enum CodingKeys: String, CodingKey {
        case collaborative
        case description
        case externalUrls = "external_urls"
        case followers
        case href
        case id
        case images
        case name
        case owner
        case isPublic = "public"
        case snapshotID = "snapshot_id"
        case tracks
        case type
        case uri
    }
}


struct SpotifyPlaylistTracks: Codable {
    let href: String
    let limit: Int
    let next: String?
    let offset: Int
    let previous: String?
    let total: Int
    let items: [SpotifyPlaylistTrackItem]
}

struct SpotifyPlaylistTrackItem: Codable {
    let addedAt: String
    let addedBy: AddedBy
    let isLocal: Bool
    let track: Track

    enum CodingKeys: String, CodingKey {
        case addedAt = "added_at"
        case addedBy = "added_by"
        case isLocal = "is_local"
        case track
    }
}


