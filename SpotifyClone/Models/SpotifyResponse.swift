//
//  SpotifyResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//


import Foundation

// MARK: - Root
struct SpotifyResponse: Codable {
    let tracks: PagedData<Track>
    let artists: PagedData<Artist>
    let albums: PagedData<Album>
    let playlists: PagedData<PlaylistItem>
    let shows: PagedData<Show>
    let episodes: PagedData<Episode>
    let audiobooks: PagedData<Audiobook>
}

// MARK: - PagedData
struct PagedData<T: Codable>: Codable {
    let href: String
    let limit: Int
    let next: String?
    let offset: Int
    let previous: String?
    let total: Int
    let items: [T]
}





struct PlaylistOwner: Codable {
    let externalURLs: ExternalURLs?
    let followers: Followers?
    let href: String
    let id: String
    let type: String
    let uri: String
    let displayName: String

    enum CodingKeys: String, CodingKey {
        case externalURLs = "external_urls"
        case followers, href, id, type, uri
        case displayName = "display_name"
    }
}

struct ResumePoint: Codable {
    let fullyPlayed: Bool
    let resumePositionMS: Int

    enum CodingKeys: String, CodingKey {
        case fullyPlayed = "fully_played"
        case resumePositionMS = "resume_position_ms"
    }
}




