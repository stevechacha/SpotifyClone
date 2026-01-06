//
//  AppConfiguration.swift
//  SpotifyClone
//
//  Created for code improvements
//

import Foundation

/// Centralized configuration for the application
enum AppConfiguration {
    /// Spotify API configuration
    enum Spotify {
        static let baseURL = "https://api.spotify.com/v1"
        static let authURL = "https://accounts.spotify.com"
        static var tokenURL: String {
            return "\(authURL)/api/token"
        }
        
        static var clientID: String {
            guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
                  let plist = NSDictionary(contentsOfFile: path) as? [String: Any],
                  let id = plist["SpotifyClientID"] as? String, !id.isEmpty else {
                fatalError("SpotifyClientID not found in Config.plist")
            }
            return id
        }
        
        static var clientSecret: String {
            guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
                  let plist = NSDictionary(contentsOfFile: path) as? [String: Any],
                  let secret = plist["SpotifyClientSecret"] as? String, !secret.isEmpty else {
                fatalError("SpotifyClientSecret not found in Config.plist")
            }
            return secret
        }
        
        static var redirectURI: String {
            guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
                  let plist = NSDictionary(contentsOfFile: path) as? [String: Any],
                  let uri = plist["SpotifyRedirectURI"] as? String else {
                return "http://localhost:3000/callback"
            }
            return uri
        }
    }
    
    /// UserDefaults keys
    enum UserDefaultsKeys {
        static let accessToken = "access_token"
        static let refreshToken = "refresh_token"
        static let expirationDate = "expiration_date"
    }
    
    /// Cache configuration
    enum Cache {
        static let maxMemorySize = 50 * 1024 * 1024 // 50MB
        static let maxDiskSize = 200 * 1024 * 1024 // 200MB
        static let expirationInterval: TimeInterval = 3600 // 1 hour
    }
    
    /// Network configuration
    enum Network {
        static let timeoutInterval: TimeInterval = 30
        static let maxRetries = 3
        static let retryBaseDelay: TimeInterval = 1.0
    }
}

