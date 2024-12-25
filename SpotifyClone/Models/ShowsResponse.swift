//
//  ShowsResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//
import Foundation

//Get Several Shows
//@GET(/shows)
//curl --request GET \
//  --url 'https://api.spotify.com/v1/shows?ids=5CfCWKI5pZ28U0uOzXkDHe%2C5as3aKmN2k11yfDDDSrvaZ' \
//  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'

// MARK: - ShowsResponse
struct ShowsResponse: Codable {
    let shows: [Show]
}




// MARK: - Show
struct Show: Codable {
    let availableMarkets: [String]
    let copyrights: [Copyright]
    let description: String
    let htmlDescription: String
    let explicit: Bool
    let externalURLs: ExternalURLs
    let href: String
    let id: String
    let images: [APIImage]
    let isExternallyHosted: Bool
    let languages: [String]
    let mediaType: String
    let name: String
    let publisher: String
    let type: String
    let uri: String
    let totalEpisodes: Int

    enum CodingKeys: String, CodingKey {
        case availableMarkets = "available_markets"
        case copyrights
        case description
        case htmlDescription = "html_description"
        case explicit
        case externalURLs = "external_urls"
        case href
        case id
        case images
        case isExternallyHosted = "is_externally_hosted"
        case languages
        case mediaType = "media_type"
        case name
        case publisher
        case type
        case uri
        case totalEpisodes = "total_episodes"
    }
}


