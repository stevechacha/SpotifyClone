//
//  TopItemsResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 29/12/2024.
//

import Foundation

struct TopItemsResponse: Codable {
    let href: String?
    let limit: Int?
    let next: String?
    let offset: Int?
    let previous: String?
    let total: Int?
    let items: [TopItem]?
}

struct TopItem: Codable , Identifiable {
    let externalUrls: ExternalURLs?
    let followers: Followers?
    let genres: [String]?
    let href: String
    let id: String?
    let images: [APIImage]?
    let name: String
    let popularity: Int?
    let type: String?
    let uri: String?

    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case followers, genres, href, id, images, name, popularity, type, uri
    }
}

