//
//  SpotifyEndpoint.swift
//  SpotifyClone
//
//  Created by stephen chacha on 30/12/2024.
//


//enum SpotifyEndpoint {
//    case artistDetails(String)
//    case artistAlbums(String)
//    case relatedArtists(String)
//    case searchArtists(String)
//    case topTracks(String, String)
//
//    var urlString: String {
//        switch self {
//        case .artistDetails(let id): return "\(Constants.artistBaseUrl)/\(id)"
//        case .artistAlbums(let id): return "\(Constants.artistBaseUrl)/\(id)/albums"
//        case .relatedArtists(let id): return "\(Constants.artistBaseUrl)/\(id)/related-artists"
//        case .searchArtists(let query): return "\(Constants.baseAPURL)/search?q=\(query)&type=artist&limit=10"
//        case .topTracks(let id, let market): return "\(Constants.artistBaseUrl)/\(id)/top-tracks?market=\(market)"
//        }
//    }
//}
