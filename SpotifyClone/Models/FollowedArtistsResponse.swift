//
//  FollowedArtistsResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 06/01/2025.
//

import Foundation

struct FollowedArtistsResponse: Decodable {
    struct Artists: Decodable {
        let items: [FollowedArtist]
    }
    let artists: Artists
    let cursors: Cursors?
    let href: String?
    let limit: Int?
    let next: String?
    let total: Int?
}



struct FollowedArtist: Decodable {
    let name: String?
    let id: String?
    let images: [APIImage]?
    let genres: [String]?
    let popularity: Int?
    let followers: Followers?
    let type: String?
    let uri: String?
    let href: String?
    let externalUrls: ExternalUrls?
}




