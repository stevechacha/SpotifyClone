//
//  ArtistViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 28/12/2024.
//

import UIKit

class ArtistViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        getArtistsTopTracks()
//        getArtistAlbums()
//        fetchArtistsDetails()
//        getArtist()
        getArtistsRelatedArtist()

        // Do any additional setup after loading the view.
    }
    
    let artistNames = ["Adele","Diamond"] // Add more names as needed
    
    func getArtistsTopTracks() {
        for artistName in artistNames {
            // Step 1: Search for the artist by name
            ArtistApiCaller.shared.searchArtist(by: artistName) { result in
                switch result {
                case .success(let artistID):
                    print("Artist ID for \(artistName): \(artistID)")
                    
                    // Step 2: Fetch the artist's top tracks
                    ArtistApiCaller.shared.getArtistsTopTracks(for: artistID, market: "US") { result in
                        switch result {
                        case .success(let topTracksResponse):
                            print("Top Tracks for \(artistName):")
                            for track in topTracksResponse.tracks {
                                print("Track Name: \(track.name)")
                                print("Album Name: \(String(describing: track.album?.name))")
                                if let popularity = track.album?.popularity {
                                    print("Popularity: \(popularity)")
                                } else {
                                    print("Popularity: No data available")
                                }
                                print("-----------")
                            }
                        case .failure(let error):
                            print("Error fetching top tracks for \(artistName): \(error)")
                        }
                    }
                case .failure(let error):
                    print("Error fetching ID for \(artistName): \(error)")
                }
            }
        }
    }
    
    func getArtistAlbums(){
        ArtistApiCaller.shared.getArtistAlbums(artistID: "06HL4z0CvFAxyc27GXpf02") { result in
            switch result {
            case .success(let albums):
                for album in albums.items {
                    print("Album: \(album.name), ID: \(album.id)")
                }
            case .failure(let error):
                print("Error fetching albums: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchArtistsDetails() {
        for artistName in artistNames {
            ArtistApiCaller.shared.searchArtist(by: artistName) { result in
                switch result {
                case .success(let artistID):
                    print("Artist ID for \(artistName): \(artistID)")
                    ArtistApiCaller.shared.getArtistDetails(artistID: artistID) { result in
                        switch result {
                        case .success(let artistDetails):
                            print("Artist Name: \(artistDetails.name)")
                            print("Genres: \(artistDetails.genres?.joined(separator: ", "))")
                            print("Followers: \(artistDetails.followers?.total)")
                        case .failure(let error):
                            print("Error fetching details for \(artistName): \(error)")
                        }
                    }
                case .failure(let error):
                    print("Error fetching ID for \(artistName): \(error)")
                }
            }
        }
    }
    
    func getArtist(){
       
        ArtistApiCaller.shared.searchArtists(query: "Taylor Swift") { result in
            switch result {
            case .success(let artists):
                let artistIDs = artists.map { $0.id }
                print("Artist IDs: \(artistIDs)")
                
                // Use these IDs to fetch albums or additional details
                ArtistApiCaller.shared.getSeveralArtists(artistIDs: artistIDs) { result in
                    switch result {
                    case .success(let response):
                        print("Artists: \(response.artists)")
                    case .failure(let error):
                        print("Error fetching several artists: \(error)")
                    }
                }
                
            case .failure(let error):
                print("Error searching for artists: \(error)")
            }
        }
    }
        
    func getArtistsRelatedArtist(){
        for artistName in artistNames {
            ArtistApiCaller.shared.searchArtistByName(artistName: artistName) { result in
                switch result {
                case .success(let artistID):
                    print("Artist ID: \(artistID)")
                    
                    // Now, fetch albums using the artist ID
                    ArtistApiCaller.shared.fetchAlbumsOfArtist(artistID: artistID) { albumResult in
                        switch albumResult {
                        case .success(let albums):
                            for album in albums.artists ?? [] {
                                print("Album: \(album.name)")
                                
                                // Fetch details of the first album
                                AlbumApiCaller.shared.getAlbumDetails(albumID: album.id) { detailResult in
                                    switch detailResult {
                                    case .success(let albumDetail):
                                        print("Album Details: \(albumDetail.name)")
                                    case .failure(let error):
                                        print("Error fetching album details: \(error.localizedDescription)")
                                    }
                                }
                            }
                        case .failure(let error):
                            print("Error fetching albums: \(error.localizedDescription)")
                        }
                    }
                    
                case .failure(let error):
                    print("Error searching for artist: \(error.localizedDescription)")
                }
            }
        }
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
