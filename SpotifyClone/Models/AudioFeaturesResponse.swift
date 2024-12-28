//
//  AudioFeaturesResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//

import Foundation


// MARK: - AudioFeaturesResponse
struct AudioFeaturesResponse: Codable {
    let audioFeatures: [AudioFeatures]
    
    enum CodingKeys: String, CodingKey {
        case audioFeatures = "audio_features"
    }
}
