//
//  Owner.swift
//  SpotifyClone
//
//  Created by stephen chacha on 13/01/2025.
//

// MARK: - Owner
struct Owner: Codable {
    let externalUrls: ExternalURLs?
    let followers: Followers?
    let href: String?
    let id: String?
    let type: String?
    let uri: String?
    let displayName: String?
    
    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case followers, href, id, type, uri
        case displayName = "display_name"
    }
}

//struct Owner: Codable {
//    let externalUrls: ExternalUrls
//    let followers: Followers
//    let href: String
//    let id: String
//    let type: String
//    let uri: String
//    let displayName: String
//
//    enum CodingKeys: String, CodingKey {
//        case externalUrls = "external_urls"
//        case followers
//        case href
//        case id
//        case type
//        case uri
//        case displayName = "display_name"
//    }
//}
