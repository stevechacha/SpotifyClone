//
//  SearchViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 04/12/2024.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter artist name"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.returnKeyType = .search
        return textField
    }()
    
    private let searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Search", for: .normal)
        return button
    }()

    
    private let resultsTableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true // Initially hidden until results are available
        return tableView
    }()
    
    private var artists: [Artist] = [] // Your `Artist` model
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // Add subviews
        view.addSubview(searchTextField)
        view.addSubview(searchButton)
        view.addSubview(resultsTableView)
        
        // Set up delegates
        searchTextField.delegate = self
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        
        // Register a cell for the table view
        resultsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // Set button action
        searchButton.addTarget(self, action: #selector(didTapSearchButton), for: .touchUpInside)
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Layout UI elements
        let padding: CGFloat = 20
        searchTextField.frame = CGRect(
            x: padding,
            y: view.safeAreaInsets.top + padding,
            width: view.frame.size.width - padding * 2,
            height: 40
        )
        searchButton.frame = CGRect(
            x: padding,
            y: searchTextField.frame.maxY + 10,
            width: view.frame.size.width - padding * 2,
            height: 40
        )
        resultsTableView.frame = CGRect(
            x: 0,
            y: searchButton.frame.maxY + 10,
            width: view.frame.size.width,
            height: view.frame.size.height - searchButton.frame.maxY - 10
        )
    }
    
    
    // MARK: - Actions
    @objc private func didTapSearchButton() {
        guard let query = searchTextField.text, !query.isEmpty else {
            print("Search query is empty")
            return
        }
        
        searchForArtist(query: query)
        fetchAllArtistData(for: query)

    }
    
   

    

    
    // MARK: - Networking
    private func searchForArtist(query: String) {
        ArtistApiCaller.shared.searchArtists(query: query) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let artists):
                    self?.artists = artists
                    self?.resultsTableView.reloadData()
                    self?.resultsTableView.isHidden = artists.isEmpty
                case .failure(let error):
                    print("Failed to fetch artists: \(error)")
                }
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let query = textField.text, !query.isEmpty {
            searchForArtist(query: query)
        }
        return true
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = artists[indexPath.row].name // Assuming your `Artist` model has a `name` property
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let artist = artists[indexPath.row]
        print("Selected artist: \(artist.name)") // Handle artist selection
    }
    
    func fetchAllArtistData(for artistName: String) {
        // Step 1: Search for the artist by name
        ArtistApiCaller.shared.searchArtist(by: artistName) { searchResult in
            switch searchResult {
            case .success(let artistID):
                print("Artist ID for \(artistName): \(artistID)")

                // Step 2: Fetch artist details
                ArtistApiCaller.shared.getArtistDetails(artistID: artistID) { detailsResult in
                    switch detailsResult {
                    case .success(let artistDetails):
                        print("Artist Details: \(artistDetails.name) - Followers: \(artistDetails.followers)")

                        // Step 3: Fetch artist's albums
                        ArtistApiCaller.shared.getArtistAlbums(artistID: artistID) { albumsResult in
                            switch albumsResult {
                            case .success(let albums):
                                print("Albums by \(artistDetails.name):")
                                for album in albums.items {
                                    print("- \(album.name) (Released: \(album.releaseDate))")
                                }

                            case .failure(let error):
                                print("Failed to fetch albums for \(artistDetails.name): \(error)")
                            }
                        }

                        // Step 4: Fetch artist's top tracks
                        ArtistApiCaller.shared.getArtistsTopTracks(for: artistID) { topTracksResult in
                            switch topTracksResult {
                            case .success(let topTracks):
                                print("Top Tracks for \(artistDetails.name):")
                                for track in topTracks.tracks {
                                    print("- \(track.name) (Album: \(track.album?.name ?? "Unknown Album"))")
                                }

                            case .failure(let error):
                                print("Failed to fetch top tracks for \(artistDetails.name): \(error)")
                            }
                        }

                        // Step 5: Fetch related artists
                        ArtistApiCaller.shared.getArtistsRelatedArtist(artistID: artistID) { relatedArtistsResult in
                            switch relatedArtistsResult {
                            case .success(let relatedArtists):
                                print("Related Artists to \(artistDetails.name):")
                                for relatedArtist in relatedArtists.artists ?? [] {
                                    print("- \(relatedArtist.name ?? "No Related Artist")")
                                }

                            case .failure(let error):
                                print("Failed to fetch related artists for \(artistDetails.name): \(error)")
                            }
                        }

                        // Step 6: Fetch recommendations based on the artist
                        ArtistApiCaller.shared.getRecommendationsArtist(genres: ["pop"], seedArtists: [artistID], seedTracks: [], completion: { recommendationsResult in
                            switch recommendationsResult {
                            case .success(let recommendations):
                                print("Recommended Tracks for \(artistDetails.name):")
                                for track in recommendations.tracks {
                                    print("- \(track.name) by \(track.artists?.map { $0.name ?? "default value" }.joined(separator: ", "))")
                                }

                            case .failure(let error):
                                print("Failed to fetch recommendations for \(artistDetails.name): \(error)")
                            }
                        })

                    case .failure(let error):
                        print("Failed to fetch artist details: \(error)")
                    }
                }

            case .failure(let error):
                print("Failed to find artist \(artistName): \(error)")
            }
        }
    }
    
    
    func fetchAllArtistDatas(for artistName: String) {
        print("Fetching data for artist: \(artistName)...")
        
        // Step 1: Search for the artist by name
        ArtistApiCaller.shared.searchArtist(by: artistName) { searchResult in
            switch searchResult {
            case .success(let artistID):
                print("Artist ID for \(artistName): \(artistID)")

                // Step 2: Fetch artist details
                ArtistApiCaller.shared.getArtistDetails(artistID: artistID) { detailsResult in
                    switch detailsResult {
                    case .success(let artistDetails):
                        print("Artist Details: \(artistDetails.name)")
                        print("Followers: \(artistDetails.followers?.total ?? 0)")
                        print("Genres: \(artistDetails.genres?.joined(separator: ", ") ?? "Unknown")")
                        print("Popularity: \(artistDetails.popularity)")

                        // Step 3: Fetch artist's albums
                        ArtistApiCaller.shared.getArtistAlbums(artistID: artistID) { albumsResult in
                            switch albumsResult {
                            case .success(let albums):
                                print("Albums by \(artistDetails.name):")
                                for album in albums.items {
                                    print("- \(album.name ?? "No Album Name") (Released: \(String(describing: album.releaseDate)))")
                                }

                                // Fetch detailed tracks for the first album as an example
                                if let firstAlbum = albums.items.first {
                                    AlbumApiCaller.shared.getAlbumTracks(albumID: firstAlbum.id!) { tracksResult in
                                        switch tracksResult {
                                        case .success(let tracks):
                                            print("Tracks from album '\(firstAlbum.name ?? "No Track Name")':")
                                            for track in tracks.items {
                                                let duration = track.durationMs.map { $0 / 1000 } ?? 0
                                                print("- \(track.name) (Duration: \(duration) seconds)")
                                            }
                                        case .failure(let error):
                                            print("Failed to fetch tracks for album \(firstAlbum.name ?? "Error fetching tracks for albumm"): \(error)")
                                        }
                                    }
                                }

                            case .failure(let error):
                                print("Failed to fetch albums for \(artistDetails.name): \(error)")
                            }
                        }

                        // Step 4: Fetch artist's top tracks
                        ArtistApiCaller.shared.getArtistsTopTracks(for: artistID) { topTracksResult in
                            switch topTracksResult {
                            case .success(let topTracks):
                                print("Top Tracks for \(artistDetails.name):")
                                for track in topTracks.tracks {
                                    print("- \(track.name) (Album: \(track.album?.name ?? "Unknown"))")
                                }

                            case .failure(let error):
                                print("Failed to fetch top tracks for \(artistDetails.name): \(error)")
                            }
                        }

                        // Step 5: Fetch related artists
                        ArtistApiCaller.shared.getArtistsRelatedArtist(artistID: artistID) { relatedArtistsResult in
                            switch relatedArtistsResult {
                            case .success(let relatedArtists):
                                print("Related Artists to \(artistDetails.name):")
                                if let artists = relatedArtists.artists {
                                    for relatedArtist in artists {
                                        print("- \(relatedArtist.name)")
                                    }
                                } else {
                                    print("No related related Artist available.")
                                }


                            case .failure(let error):
                                print("Failed to fetch related artists for \(artistDetails.name): \(error)")
                            }
                        }

                        // Step 6: Fetch recommendations based on the artist
                        let genres = (artistDetails.genres?.isEmpty ?? true) ? ["pop"] : artistDetails.genres ?? []

                        // Convert genres array to a Set<String>
                        let genresSet = Set(genres)

                        ArtistApiCaller.shared.getRecommendationsArtist(
                            genres: genresSet,
                            seedArtists: [artistID],
                            seedTracks: []
                        ) { recommendationsResult in
                            switch recommendationsResult {
                            case .success(let recommendations):
                                print("Recommended Tracks for \(artistDetails.name):")
                                for track in recommendations.tracks {
                                    let artists = track.artists?.map { $0.name }.joined(separator: ", ") ?? "Unknown"
                                    print("- \(track.name) by \(artists)")
                                }

                            case .failure(let error):
                                print("Failed to fetch recommendations for \(artistDetails.name): \(error)")
                            }
                        }

                    case .failure(let error):
                        print("Failed to fetch artist details: \(error)")
                    }
                }

            case .failure(let error):
                print("Failed to find artist \(artistName): \(error)")
            }
        }
    }


}
