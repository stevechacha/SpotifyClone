//
//  AudioFeatures.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//


import Foundation


// MARK: - AudioFeatures
struct AudioFeatures: Codable {
    let acousticness: Double
    let analysisURL: String
    let danceability: Double
    let durationMS: Int
    let energy: Double
    let id: String
    let instrumentalness: Double
    let key: Int
    let liveness: Double
    let loudness: Double
    let mode: Int
    let speechiness: Double
    let tempo: Double
    let timeSignature: Int
    let trackHref: String
    let type: String
    let uri: String
    let valence: Double
    
    enum CodingKeys: String, CodingKey {
        case acousticness
        case analysisURL = "analysis_url"
        case danceability
        case durationMS = "duration_ms"
        case energy
        case id
        case instrumentalness
        case key
        case liveness
        case loudness
        case mode
        case speechiness
        case tempo
        case timeSignature = "time_signature"
        case trackHref = "track_href"
        case type
        case uri
        case valence
    }
}

//// MARK: - Audiobook
//struct Audiobook: Codable {
//    let authors: [Author]
//    let availableMarkets: [String]
//    let copyrights: [Copyright]
//    let description: String
//    let htmlDescription: String
//    let edition: String
//    let explicit: Bool
//    let externalUrls: ExternalURLs
//    let href: String
//    let id: String
//    let images: [APIImage]
//    let languages: [String]
//    let mediaType: String
//    let name: String
//    let narrators: [Narrator]
//    let publisher: String
//    let type: String
//    let uri: String
//    let totalChapters: Int
//    let chapters: Chapters
//
//    enum CodingKeys: String, CodingKey {
//        case authors
//        case availableMarkets = "available_markets"
//        case copyrights
//        case description
//        case htmlDescription = "html_description"
//        case edition
//        case explicit
//        case externalUrls = "external_urls"
//        case href
//        case id
//        case images
//        case languages
//        case mediaType = "media_type"
//        case name
//        case narrators
//        case publisher
//        case type
//        case uri
//        case totalChapters = "total_chapters"
//        case chapters
//    }
//}

