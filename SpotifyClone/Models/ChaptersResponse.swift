//
//  ChaptersResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//

import Foundation




// MARK: - Main Structure for Chapters
struct ChaptersResponse: Codable {
    let chapters: [Chapter]
}


// MARK: - Chapter Structure
struct Chapter: Codable {
    let audioPreviewURL: String
    let availableMarkets: [String]
    let chapterNumber: Int
    let description: String
    let htmlDescription: String
    let durationMS: Int
    let explicit: Bool
    let externalUrls: ExternalURLs
    let href: String
    let id: String
    let images: [APIImage]
    let isPlayable: Bool
    let languages: [String]
    let name: String
    let releaseDate: String
    let releaseDatePrecision: String
    let resumePoint: ResumePoint
    let type: String
    let uri: String
    let restrictions: Restrictions?
    let audiobook: Audiobook
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





