//
//  AlbumViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 24/12/2024.
//

import UIKit
import SDWebImage

class AlbumViewController : UIViewController {
//    private let album: Album
//    
//    init(album: Album) {
//        self.album = album
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        
//        fetchAlbumsAndTracks()
//          getNewReleasesAlbums()
        fetchAndProcessAlbums()
        
        

    }
    
    func fetchAndProcessAlbums() {
        AlbumApiCaller.shared.fetchAlbumIDs { result in
            switch result {
            case .success(let albumIDs):
                print("Fetched Album IDs: \(albumIDs)")
                self.fetchAlbumDataForMultipleAlbums(albumIDs: albumIDs)
            case .failure(let error):
                print("Failed to fetch album IDs: \(error)")
            }
        }
    }

    
   
    
    func fetchAlbumDataForMultipleAlbumsInParallel(albumIDs: [String]) {
        let dispatchGroup = DispatchGroup()

        for albumID in albumIDs {
            dispatchGroup.enter() // Enter the group for each album
            
            print("Fetching data for album ID: \(albumID)...")

            // Step 1: Fetch album details
            AlbumApiCaller.shared.getAlbumDetails(albumID: albumID) { albumResult in
                switch albumResult {
                case .success(let album):
                    print("Album Name: \(album.name ?? "No Album Name")")
                    print("Release Date: \(album.releaseDate ?? "Unknown")")
                    print("Total Tracks: \(album.totalTracks ?? 0 )")

                    // Step 2: Fetch tracks for the album
                    AlbumApiCaller.shared.getAllAlbumTracks(albumID: album.id!) { tracksResult in
                        switch tracksResult {
                        case .success(let tracks):
                            print("Tracks for album \(album.name ?? "No Album Name"):")
                            for track in tracks {
                                print("- \(track.name ?? "Unknown Track Name") (Duration: \(track.durationMs! / 1000) seconds)")
                            }
                        case .failure(let error):
                            print("Failed to fetch tracks for album \(album.name ?? "Unkown Album"): \(error)")
                        }
                    }

                    // Step 3: Fetch recommendations based on album details
//                    self.fetchAlbumRecommendations(albumID: album.id!) // Fetch recommendations for each album

                case .failure(let error):
                    print("Failed to fetch album details for ID \(albumID): \(error)")
                }
                
                dispatchGroup.leave() // Leave the group when the album request finishes
            }
        }

        // Wait for all album requests to finish
        dispatchGroup.notify(queue: .main) {
            print("All album data has been fetched.")
        }
    }
    
    func fetchAlbumDataForMultipleAlbums(albumIDs: [String]) {
        for albumID in albumIDs {
            print("Fetching data for album ID: \(albumID)...")

            // Step 1: Fetch album details
            AlbumApiCaller.shared.getAlbumDetails(albumID: albumID) { albumResult in
                switch albumResult {
                case .success(let album):
                    print("Album Name: \(album.name ?? "Unknown Album name")")
                    print("Release Date: \(album.releaseDate ?? "Unknown")")
                    print("Total Tracks: \(album.totalTracks ?? 0)")

                    // Step 2: Fetch tracks for the album
                    AlbumApiCaller.shared.getAllAlbumTracks(albumID: album.id!) { tracksResult in
                        switch tracksResult {
                        case .success(let tracks):
                            print("Tracks for album \(album.name ?? "Unknow Album"):")
                            for track in tracks {
                                print("- \(track.name ?? "Unknown Track") (Duration: \(track.durationMs! / 1000) seconds)")
                                TrackApiCaller.shared.getTrack(trackID: track.id ?? ""){ results in
                                    switch results {
                                    case .success(let track):
                                        print("TrackApiCaller - \(track.name ?? "Unknown Track") (Duration: \(track.durationMs! / 1000) seconds)")
                                    case .failure(let error):
                                        print(error)
                                    }
                                    
                                }

                            }
                        case .failure(let error):
                            print("Failed to fetch tracks for album \(album.name ?? "Unkown Album"): \(error)")
                        }
                    }

                    // Step 3: Fetch recommendations based on album details
//                    self.fetchAlbumRecommendations(albumID: album.id!) // Fetch recommendations for each album

                case .failure(let error):
                    print("Failed to fetch album details for ID \(albumID): \(error)")
                }
            }
        }
    }
    
    func fetchAlbumsAndTracks() {
        // Fetch albums saved by the user
        AlbumApiCaller.shared.getUserSavedAlbums { result in
            switch result {
            case .success(let savedAlbumsResponse):
                guard !savedAlbumsResponse.items.isEmpty else {
                    print("No albums found in the user's library.")
                    return
                }
                
                for albumItem in savedAlbumsResponse.items {
                    guard let album = albumItem.album else {
                        print("Album information is missing for an item.")
                        continue
                    }
                    
                    print("Album Name: \(album.name ?? "Unknown Album")")
                    
                    guard let albumID = album.id else {
                        print("Album ID is missing for album: \(album.name ?? "Unknown Album").")
                        
                        self.fetchAlbumRecommendations(albumID: album.id ?? "Nil")
                        continue
                    }
                    
                    self.fetchAlbumRecommendations(albumID: album.id ?? "")

                    
                    // Fetch tracks for the album
                    AlbumApiCaller.shared.getAllAlbumTracks(albumID: albumID) { tracksResult in
                        switch tracksResult {
                        case .success(let tracksResponse):
                            if tracksResponse.isEmpty {
                                print("No tracks found for album \(album.name ?? "Unknown Album").")
                            } else {
                                for trackItem in tracksResponse {
                                    let trackName = trackItem.name
                                    let artists = trackItem.artists?.map { $0.name ?? "" }.joined(separator: ", ") ?? "Unknown Artist"
                                    print("Track: \(trackName ?? "Unknown Track Name") by \(artists)")
                                }
                            }
                        case .failure(let error):
                            print("Failed to fetch tracks for album \(album.name ?? "Unknown Album"): \(error.localizedDescription)")
                        }
                    }
                }
            case .failure(let error):
                print("Failed to fetch saved albums: \(error.localizedDescription)")
            }
        }
    }
    

    func fetchAlbumRecommendations(albumID: String) {
        print("Fetching recommendations based on album ID: \(albumID)...")

        // Step 1: Fetch album details to get genres
        AlbumApiCaller.shared.getAlbumDetails(albumID: albumID) { albumResult in
            switch albumResult {
            case .success(let album):
                print("Album Name: \(album.name ?? "")")
                print("Genres: \(album.genres?.joined(separator: ", ") ?? "Unknown")")

                // Convert genres array to Set<String>
                let genresSet = Set(album.genres ?? ["pop"])

                // Step 2: Fetch recommendations based on genres and album ID
//                AlbumApiCaller.shared.getRecommendationsForAlbum(
//                    genres: genresSet,
//                    seedAlbums: [albumID],  // Use album ID as seed
//                    seedTracks: []          // Optionally, you can add seed tracks here
//                ) { recommendationsResult in
//                    switch recommendationsResult {
//                    case .success(let recommendations):
//                        print("Recommended Albums based on \(album.name):")
//                        for recommendedAlbum in recommendations.tracks {
//                            print("- \(recommendedAlbum.name) (Released: \(recommendedAlbum.album?.releaseDate))")
//                        }
//                    case .failure(let error):
//                        print("Failed to fetch recommendations for album \(album.name): \(error)")
//                    }
//                }

            case .failure(let error):
                print("Failed to fetch album details for ID \(albumID): \(error)")
            }
        }
    }


   
    
    func getNewReleasesAlbums(){
        AlbumApiCaller.shared.getNewReleases { result in
            switch result {
            case .success(let newReleases):
                print("New Releases:")
                for album in newReleases.albums.items {
                    
                    print("Album Name: \(album.name ?? "Unknow Album")")
                    print("Artist(s): \(album.artists?.map { $0.name ?? "" }.joined(separator: ", ") ?? "Unkown Artist")")
                    print("Release Date: \(album.releaseDate ?? "Unkown Released Date")")
                    if let imageUrl = album.images?.first?.url {
                        print("Album Cover URL: \(imageUrl)")
                    }
                }
            case .failure(let error):
                print("Failed to fetch new releases: \(error.localizedDescription)")
            }
        }

    }
    
    func getAlbumsDetails(){
        let albumIDs = "382ObEPsp2rxGrnsizN5TX"
        AlbumApiCaller.shared.getAlbumDetails(albumID: albumIDs) { result in
            switch result {
            case .success(let albumsResponse):
                print("Successfully fetched albums: \(albumsResponse)")
            case .failure(let error):
                print("Failed to fetch albums: \(error.localizedDescription)")
            }
        }

    }
    
    func getAlbums(){
        ArtistApiCaller.shared.searchArtists(query: "Taylor Swift") { result in
            switch result {
            case .success(let artists):
                let artistIDs = artists.map { $0.id } 
                print("Artist IDs: \(artistIDs)")
                AlbumApiCaller.shared.getSeveralAlbums(albumIDs: artistIDs) { result in
                    switch result {
                    case .success(let albumsResponse):
                        print("Fetched Albums:")
                        for album in albumsResponse.albums ?? [] {
                            print("Album Name: \(album.name ?? "Unknown Album")")
                            print("Artists: \(album.artists?.map { $0.name ?? "" }.joined(separator: ", ") ?? "Unknow Artist")")
                            print("Release Date: \(album.releaseDate ?? "Unknown Release Date")")
                            if let imageUrl = album.images?.first?.url {
                                print("Album Cover URL: \(imageUrl)")
                            }
                            print("Total Tracks: \(album.totalTracks ?? 0 )")
                            print("---")
                        }
                    case .failure(let error):
                        print("Failed to fetch albums: \(error.localizedDescription)")
                    }
                }
                
            case .failure(let error):
                print("Failed to fetch albums: \(error.localizedDescription)")
            }
        }
    
    }
}
