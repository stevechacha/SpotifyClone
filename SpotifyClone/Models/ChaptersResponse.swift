//
//  ChaptersResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//

import Foundation


struct ChaptersResponse: Codable {
    let chapters: [Chapter]?

    enum CodingKeys: String, CodingKey {
        case chapters
    }
}

// MARK: - Chapter Structure
struct Chapter: Codable {
    let audioPreviewURL: String?
    let availableMarkets: [String]
    let chapterNumber: Int
    let description: String
    let htmlDescription: String
    let durationMS: Int
    let explicit: Bool
    let externalUrls: ExternalURLs?
    let href: String
    let id: String
    let images: [APIImage]?
    let isPlayable: Bool?
    let languages: [String]
    let name: String
    let releaseDate: String
    let releaseDatePrecision: String
    let resumePoint: ResumePoint
    let type: String
    let uri: String
    let restrictions: Restrictions?
    let audiobook: Audiobook

    enum CodingKeys: String, CodingKey {
        case audioPreviewURL = "audio_preview_url"
        case availableMarkets = "available_markets"
        case chapterNumber = "chapter_number"
        case description
        case htmlDescription = "html_description"
        case durationMS = "duration_ms"
        case explicit
        case externalUrls = "external_urls"
        case href
        case id
        case images
        case isPlayable = "is_playable"
        case languages
        case name
        case releaseDate = "release_date"
        case releaseDatePrecision = "release_date_precision"
        case resumePoint = "resume_point"
        case type
        case uri
        case restrictions
        case audiobook
    }
}

// MARK: - Audiobook Structure
struct Audiobook: Codable {
    let authors: [Author]
    let availableMarkets: [String]
    let copyrights: [Copyright]
    let description: String
    let htmlDescription: String
    let edition: String
    let explicit: Bool
    let externalUrls: ExternalURLs
    let href: String
    let id: String
    let images: [APIImage]
    let languages: [String]
    let mediaType: String
    let name: String
    let narrators: [Narrator]
    let publisher: String
    let type: String
    let uri: String
    let totalChapters: Int

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


// MARK: - Nested Structures
struct Author: Codable {
    let name: String
}


struct ExternalURLs: Codable {
    let spotify: String?
}


struct Narrator: Codable {
    let name: String
}





