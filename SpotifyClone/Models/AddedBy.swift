//
//  AddedBy.swift
//  SpotifyClone
//
//  Created by stephen chacha on 13/01/2025.
//


// MARK: - Added By
struct AddedBy: Codable {
    let externalUrls: ExternalURLs?
    let followers: Followers?
    let href: String
    let id: String
    let type: String
    let uri: String
    
    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case followers, href, id, type, uri
    }
}



//
//struct AddedBy: Codable {
//    let externalUrls: ExternalUrls
//    let followers: Followers
//    let href: String
//    let id: String
//    let type: String
//    let uri: String
//
//    enum CodingKeys: String, CodingKey {
//        case externalUrls = "external_urls"
//        case followers
//        case href
//        case id
//        case type
//        case uri
//    }
//}


