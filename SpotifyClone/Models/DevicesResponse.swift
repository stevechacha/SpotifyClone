//
//  DevicesResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 07/01/2025.
//


// Models
struct DevicesResponse: Codable {
    let devices: [SpotifyDevice]
}



struct PlaybackState: Codable {
    let device: SpotifyDevice?
    let repeatState: String?
    let shuffleState: Bool?
    let context: SpotyfyPlayContext?
    let timestamp: Int?
    let progressMS: Int?
    let isPlaying: Bool?
    let item: Track?
    let currentlyPlayingType: String?
    let actions: Actions?
    
    enum CodingKeys: String, CodingKey {
        case device
        case repeatState = "repeat_state"
        case shuffleState = "shuffle_state"
        case context
        case timestamp
        case progressMS = "progress_ms"
        case isPlaying = "is_playing"
        case item
        case currentlyPlayingType = "currently_playing_type"
        case actions
    }
}


struct SpotifyDevice: Codable {
    let id: String?
    let isActive: Bool?
    let isPrivateSession: Bool?
    let isRestricted: Bool?
    let name: String?
    let type: String?
    let volumePercent: Int?
    let supportsVolume: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case isActive = "is_active"
        case isPrivateSession = "is_private_session"
        case isRestricted = "is_restricted"
        case name
        case type
        case volumePercent = "volume_percent"
        case supportsVolume = "supports_volume"
    }
}

struct SpotyfyPlayContext: Codable {
    let type: String?
    let href: String?
    let externalUrls: ExternalUrls?
    let uri: String?
    
    enum CodingKeys: String, CodingKey {
        case type, href
        case externalUrls = "external_urls"
        case uri
    }
}

struct Actions: Codable {
    let interruptingPlayback: Bool?
    let pausing: Bool?
    let resuming: Bool?
    let seeking: Bool?
    let skippingNext: Bool?
    let skippingPrev: Bool?
    
    enum CodingKeys: String, CodingKey {
        case interruptingPlayback = "interrupting_playback"
        case pausing
        case resuming
        case seeking
        case skippingNext = "skipping_next"
        case skippingPrev = "skipping_prev"
    }
}

