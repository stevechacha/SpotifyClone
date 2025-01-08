//
//  DataCache.swift
//  SpotifyClone
//
//  Created by stephen chacha on 07/01/2025.
//

import Foundation

class DataCache {
    static let shared = DataCache()
    private let cache = NSCache<NSString, NSArray>()

    private init() {}

    func getCachedTracks(for albumID: String) -> [Track]? {
        return cache.object(forKey: albumID as NSString) as? [Track]
    }

    func saveTracks(_ tracks: [Track], for albumID: String) {
        cache.setObject(tracks as NSArray, forKey: albumID as NSString)
    }
}
