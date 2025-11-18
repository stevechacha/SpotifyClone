//
//  ArtistApi.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//

import Foundation

final class ArtistApiCaller {

    static let shared = ArtistApiCaller()

    private let apiClient: SpotifyAPIClient
    private let defaultMarket: String

    init(apiClient: SpotifyAPIClient = .shared, locale: Locale = .current) {
        self.apiClient = apiClient
        self.defaultMarket = locale.regionCode ?? "US"
    }

    func getArtistDetails(
        artistID: String,
        completion: @escaping (Result<SpotifyArtistsDetailResponse, Error>) -> Void
    ) {
        apiClient.send(SpotifyEndpoint.artistDetails(id: artistID), completion: completion)
    }

    func getSeveralArtists(
        artistIDs: [String],
        completion: @escaping (Result<SpotifyArtistsResponse, Error>) -> Void
    ) {
        guard !artistIDs.isEmpty else {
            completion(.failure(ApiError.invalidInput))
            return
        }

        apiClient.send(SpotifyEndpoint.severalArtists(ids: artistIDs), completion: completion)
    }

    func getArtistAlbums(
        artistID: String,
        completion: @escaping (Result<SpotifyArtistsAlbumsResponse, Error>) -> Void
    ) {
        apiClient.send(SpotifyEndpoint.artistAlbums(id: artistID), completion: completion)
    }

    func getArtistsTopTracks(
        for artistID: String,
        completion: @escaping (Result<SpotifyArtistsTopTracksResponse, Error>) -> Void
    ) {
        apiClient.send(
            SpotifyEndpoint.artistTopTracks(id: artistID, market: defaultMarket),
            completion: completion
        )
    }

    func getRelatedArtists(
        artistID: String,
        completion: @escaping (Result<SpotifyArtistRelatedArtistsResponse, Error>) -> Void
    ) {
        apiClient.send(SpotifyEndpoint.artistRelated(id: artistID), completion: completion)
    }

    func searchArtists(
        query: String,
        completion: @escaping (Result<[Artist], Error>) -> Void
    ) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            completion(.failure(ApiError.invalidInput))
            return
        }

        apiClient.send(SpotifyEndpoint.searchArtists(query: trimmedQuery)) { (result: Result<SpotifySearchResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.artists.items))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func searchArtistByName(
        name: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        searchArtists(query: name) { result in
            switch result {
            case .success(let artists):
                if let firstArtist = artists.first?.id {
                    completion(.success(firstArtist))
                } else {
                    completion(.failure(ApiError.apiError("Artist not found")))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
