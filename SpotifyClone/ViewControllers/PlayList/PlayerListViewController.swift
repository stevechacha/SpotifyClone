//
//  PlayerListViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 04/12/2024.
//

import UIKit

class PlayerListViewController: UIViewController {

    var playlist: PlaylistItem
    var tracks: [PlaylistItemsResponse] = [] // To store the fetched tracks

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    // Initialize with a playlist
    init(playlist: PlaylistItem) {
        self.playlist = playlist
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = playlist.name
        view.backgroundColor = .systemBackground
        
        // Setup table view
        setupTableView()

        // Fetch tracks for this playlist
        fetchPlaylistTracks()
        getUserPlaylists()
    }

    // Setup TableView for displaying tracks
    func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func fetchPlaylistTracks() {
        PlaylistApiCaller.shared.getPlaylistTracks(playlistID: playlist.id) { [weak self] result in
            switch result {
            case .success(let tracksResponse):
                self?.tracks = tracksResponse.items
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Failed to fetch tracks: \(error)")
            }
        }
    }
    
    func getUserPlaylists(){
        var userID: String = ""
        var playlistID: String = playlist.id

        PlaylistApiCaller.shared.getCurrentUsersPlaylist { result in
            switch result {
            case .success(let playlistsResponse):
                guard let playlists = playlistsResponse.items else {
                    print("No playlists found!")
                    return
                }
                
                for playlist in playlists {
                    print("Playlist ID: \(playlist.id), Playlist Name: \(playlist.name)")
                }
            case .failure(let error):
                print("Error fetching playlists: \(error)")
            }
        }
        
        UserApiCaller.shared.getCurrentUserProfile { result in
            switch result {
            case .success(let profile):
                userID = profile.id
                print("Fetched User ID: \(userID)")
                
                PlaylistApiCaller.shared.getCurrentUsersPlaylist { result in
                    switch result {
                    case .success(let response):
                        if let firstPlaylist = response.items?.first {
                            playlistID = firstPlaylist.id
                            print("Fetched Playlist ID: \(playlistID)")
                            
                            // Now you can pass these to fetchAllPlaylistDetails
                            PlaylistApiCaller.shared.fetchAllPlaylistDetails(playlistID: playlistID, userID: userID) { result in
                                switch result {
                                case .success(let details):
                                    print("All playlist details: \(details)")
                                case .failure(let error):
                                    print("Error: \(error)")
                                }
                            }
                        }
                    case .failure(let error):
                        print("Error fetching playlists: \(error)")
                    }
                }
            case .failure(let error):
                print("Error fetching user profile: \(error)")
            }
        }


    }
    
    
    func getPlaylists(){
        PlaylistApiCaller.shared.getCurrentUsersPlaylist { result in
            switch result {
            case .success(let playlistsResponse):
                // Access the playlists array
                let playlists = playlistsResponse.items

                // Example: Print all playlist IDs
                for playlist in playlists! {
                    print("Playlist Name: \(playlist.name), Playlist ID: \(playlist.id)")
                }

                // Example: Access the first playlist ID
                if let firstPlaylistID = playlists?.first?.id {
                    print("First Playlist ID: \(firstPlaylistID)")
                }
            case .failure(let error):
                print("Failed to fetch playlists: \(error)")
            }
        }
        
    }
    
    func fetchPlaylistsAndTracks() {

        PlaylistApiCaller.shared.getCurrentUsersPlaylist { result in
            switch result {
            case .success(let playlistsResponse):
                for playlist in playlistsResponse.items ?? [] {
                    print("Playlist Name: \(playlist.name)")
                    
                    // Fetch tracks for each playlist
                    PlaylistApiCaller.shared.getPlaylistTracks(playlistID: playlist.id) { tracksResult in
                        switch tracksResult {
                        case .success(let tracksResponse):
                            for trackItem in tracksResponse.items {
                                print("Track: \(trackItem.track.name) by \(trackItem.track.artists?.map { $0.name }.joined(separator: ", ") ?? "Unknown Track name")")
                            }
                        case .failure(let error):
                            print("Failed to fetch tracks: \(error)")
                        }
                    }
                }
            case .failure(let error):
                print("Failed to fetch playlists: \(error)")
            }
        }
    }
}

extension PlayerListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let track = tracks[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "TrackCell")
        cell.textLabel?.text = track.track.name
        cell.detailTextLabel?.text = track.track.artists?.map { $0.name }.joined(separator: ", ")
        return cell
    }
}

