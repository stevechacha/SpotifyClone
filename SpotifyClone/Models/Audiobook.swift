//
//  Audiobook.swift
//  SpotifyClone
//
//  Created by stephen chacha on 03/01/2025.
//

import Foundation
// MARK: - Audiobook Structure
struct Audiobook: Codable {
    let authors: [Author]?
    let availableMarkets: [String]?
    let copyrights: [Copyright]?
    let description: String?
    let htmlDescription: String?
    let edition: String?
    let explicit: Bool?
    let externalUrls: ExternalURLs?
    let href: String?
    let id: String?
    let images: [APIImage]?
    let languages: [String]?
    let mediaType: String?
    let name: String?
    let narrators: [Narrator]?
    let publisher: String?
    let type: String?
    let uri: String?
    let totalChapters: Int?

    enum CodingKeys: String, CodingKey {
        case authors
        case availableMarkets = "available_markets"
        case copyrights
        case description
        case htmlDescription = "html_description"
        case edition
        case explicit
        case externalUrls = "external_urls"
        case href
        case id
        case images
        case languages
        case mediaType = "media_type"
        case name
        case narrators
        case publisher
        case type
        case uri
        case totalChapters = "total_chapters"
    }
}
