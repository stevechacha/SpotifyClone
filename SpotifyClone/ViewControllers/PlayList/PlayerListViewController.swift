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
    
    private let loadingIndicator: UIActivityIndicatorView = {
            let indicator = UIActivityIndicatorView(style: .large)
            indicator.translatesAutoresizingMaskIntoConstraints = false
            indicator.color = .gray
            return indicator
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
        getPlaybackState()
        
        // Setup loading indicator
        setupLoadingIndicator()
    }
    
    func setupLoadingIndicator() {
           view.addSubview(loadingIndicator)
           NSLayoutConstraint.activate([
               loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
               loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
           ])
       }
    
    func getPlaybackState(){
        SpotifyPlayer.shared.getPlaybackState { result in
            switch result {
            case .success(let playbackState):
                if let device = playbackState.device, device.isActive ?? false {
                    print("Active device: \(device.name ?? "Unknow Device Name") at volume \(device.volumePercent ?? 0 )%")
                } else {
                    print("No active device found.")
                }
                
                if let track = playbackState.item {
                    print("Now Playing: \(track.name ?? "Unknown Tracks") by \(track.artists?.first?.name ?? "Unknown Artist")")
                } else {
                    print("No track is currently playing.")
                }
                
            case .failure(let error):
                print("Failed to get playback state: \(error)")
            }
        }
    }

    // Setup TableView for displaying tracks
    func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PlayListTrackTableViewCell.self, forCellReuseIdentifier: PlayListTrackTableViewCell.identifier)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func fetchPlaylistTracks() {
        loadingIndicator.startAnimating()
        PlaylistApiCaller.shared.getPlaylistTracks(playlistID: playlist.id ?? "No Id") { [weak self] result in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
            }
            switch result {
            case .success(let tracksResponse):
                self?.tracks = tracksResponse.items ?? []
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Failed to fetch tracks: \(error)")
            }
        }
    }
}

extension PlayerListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let trackItem = tracks[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlayListTrackTableViewCell.identifier, for: indexPath) as? PlayListTrackTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: trackItem)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTrack = tracks[indexPath.row]
        playTrack(selectedTrack)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func playTrack(_ trackItem: PlaylistItemsResponse) {
        guard let trackURI = trackItem.track?.uri else {
            print("Track URI is missing")
            return
        }
        
        SpotifyPlayer.shared.getAvailableDevices { result in
            switch result {
            case .success(let devices):
                print(devices)
                if let activeDevice = devices.first(where: { $0.isActive ?? false}) {
                    SpotifyPlayer.shared.playTracks(uri: trackURI, deviceID: activeDevice.id) { result in
                        switch result {
                        case .success:
                            print("Now playing: \(trackItem.track?.name ?? "")")
                        case .failure(let error):
                            print("Failed to play track: \(error)")
                        }
                    }
                } else {
                    print("No active device found.")
                }
            case .failure(let error):
                print("Failed to retrieve devices: \(error)")
            }
        }

        
//
//        SpotifyPlayer.shared.setVolume(level: 50) { result in
//            switch result {
//            case .success:
//                print("Volume set successfully!")
//                SpotifyPlayer.shared.playTrack(uri: trackURI) { result in
//                    switch result {
//                    case .success:
//                        print("Now playing: \(trackItem.track?.name ?? "")")
//                    case .failure(let error):
//                        print("Error starting playback: \(error)")
//                    }
//                }
//            case .failure(let error):
//                print("Error setting volume: \(error)")
//            }
//        }
        
      



//        // Example: Use Spotify SDK or API to start playback
//        SpotifyPlayer.shared.playTrack(uri: trackURI) { result in
//            switch result {
//            case .success:
//                print("Now playing: \(trackItem.track?.name)")
//            case .failure(let error):
//                print("Failed to play track: \(error)")
//            }
//        }
    }
}
