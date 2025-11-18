//
//  Endpoint.swift
//  SpotifyClone
//
//  Created by ChatGPT on 18/11/2025.
//

import Foundation

protocol Endpoint {
    /// Relative path appended to the Spotify base URL
    var path: String { get }

    /// HTTP method for the request
    var method: AuthManager.HTTPMethod { get }

    /// Optional query items
    var queryItems: [URLQueryItem]? { get }
}

extension Endpoint {
    var method: AuthManager.HTTPMethod { .GET }
    var queryItems: [URLQueryItem]? { nil }
}
