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
