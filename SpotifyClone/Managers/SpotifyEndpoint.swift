//
//  SpotifyEndpoint.swift
//  SpotifyClone
//
//  Created by stephen chacha on 30/12/2024.
//

import Foundation

enum SpotifyEndpoint: Endpoint {
    case artistDetails(id: String)
    case artistAlbums(id: String)
    case artistTopTracks(id: String, market: String)
    case artistRelated(id: String)
    case severalArtists(ids: [String])
    case searchArtists(query: String, limit: Int = 10)

    var path: String {
        switch self {
        case .artistDetails(let id):
            return "artists/\(id)"
        case .artistAlbums(let id):
            return "artists/\(id)/albums"
        case .artistTopTracks(let id, _):
            return "artists/\(id)/top-tracks"
        case .artistRelated(let id):
            return "artists/\(id)/related-artists"
        case .severalArtists:
            return "artists"
        case .searchArtists:
            return "search"
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .artistTopTracks(_, let market):
            return [URLQueryItem(name: "market", value: market)]
        case .severalArtists(let ids):
            return [URLQueryItem(name: "ids", value: ids.joined(separator: ","))]
        case .searchArtists(let query, let limit):
            return [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "type", value: "artist"),
                URLQueryItem(name: "limit", value: "\(limit)")
            ]
        default:
            return nil
        }
    }
}
