//
//  Artist.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//

import Foundation

struct Artist: Codable {
    let externalUrls: ExternalUrls
    let href: String
    let id: String
    let name: String
    let type: String
    let uri: String

    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case href, id, name, type, uri
    }
}
