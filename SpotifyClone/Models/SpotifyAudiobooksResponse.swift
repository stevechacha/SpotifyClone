//
//  SpotifyAudiobooksResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 03/01/2025.
//


import Foundation

// MARK: - SpotifyAudiobooksResponse
struct SpotifyAudiobooksResponse: Codable {
    let audiobooks: [Audiobook]
}





// MARK: - Chapters
struct Chapters: Codable {
    let href: String
    let limit: Int
    let next: String?
    let offset: Int
    let previous: String?
    let total: Int
    let items: [Chapter]
}

