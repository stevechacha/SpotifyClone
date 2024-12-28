//
//  EpisodesResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//


import Foundation


// MARK: - EpisodesResponse
struct EpisodesResponse: Codable {
    let href: String?
    let limit: Int?
    let next: String?
    let offset: Int?
    let previous: String?
    let total: Int?
    let episodes: [Episode]?

    enum CodingKeys: String, CodingKey {
        case href, limit, next, offset, previous, total
        case episodes = "items"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode the other properties
        self.href = try container.decodeIfPresent(String.self, forKey: .href)
        self.limit = try container.decodeIfPresent(Int.self, forKey: .limit)
        self.next = try container.decodeIfPresent(String.self, forKey: .next)
        self.offset = try container.decodeIfPresent(Int.self, forKey: .offset)
        self.previous = try container.decodeIfPresent(String.self, forKey: .previous)
        self.total = try container.decodeIfPresent(Int.self, forKey: .total)

        // Safely decode `items`, filtering out null values
        self.episodes = try container.decodeIfPresent([Episode?].self, forKey: .episodes)?.compactMap { $0 } ?? []
    }
}

// MARK: - Episode
struct Episode: Codable {
    let audioPreviewURL: String?
    let description: String?
    let htmlDescription: String?
    let durationMs: Int?
    let explicit: Bool?
    let externalURLs: ExternalURLs?
    let href: String?
    let id: String?
    let images: [APIImage]?
    let isExternallyHosted: Bool?
    let isPlayable: Bool?
    let language: String?
    let languages: [String]?
    let name: String?
    let releaseDate: String?
    let releaseDatePrecision: String?
    let resumePoint: ResumePoint?
    let type: String?
    let uri: String?
    let restrictions: Restrictions?
    let show: Show?


    enum CodingKeys: String, CodingKey {
        case audioPreviewURL = "audio_preview_url"
        case description
        case htmlDescription = "html_description"
        case durationMs = "duration_ms"
        case explicit
        case externalURLs = "external_urls"
        case href, id, images
        case isExternallyHosted = "is_externally_hosted"
        case isPlayable = "is_playable"
        case language, languages, name
        case releaseDate = "release_date"
        case releaseDatePrecision = "release_date_precision"
        case resumePoint = "resume_point"
        case type, uri, restrictions,show
    }
}


