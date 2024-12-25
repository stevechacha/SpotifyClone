//
//  CreatePlaylistResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//

import Foundation
// MARK: - CreatePlaylistResponse
struct CreatePlaylistResponse: Codable {
    let collaborative: Bool
    let description: String
    let externalUrls: ExternalURLs
    let followers: Followers
    let href: String
    let id: String
    let images: [APIImage]
    let name: String
    let owner: Owner
    let isPublic: Bool
    let snapshotId: String
    let tracks: Tracks
    let type: String
    let uri: String
    
    enum CodingKeys: String, CodingKey {
        case collaborative, description
        case externalUrls = "external_urls"
        case followers, href, id, images, name, owner
        case isPublic = "public"
        case snapshotId = "snapshot_id"
        case tracks, type, uri
    }
}
