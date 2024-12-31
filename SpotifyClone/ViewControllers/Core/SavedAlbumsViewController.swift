//
//  SavedAlbumsViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 29/12/2024.
//


import UIKit

enum SavedItemTypea {
    case album(Album)
    case playlist(PlaylistItem)
    case podcast(UsersSavedShowsItems) // Assuming you have a `PodcastItem` model
    case episode(UserSavedEpisode) // Add case for saved episodes
}


class SavedItemsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var savedItems: [SavedItemType] = [] // Store all saved items (albums, playlists, podcasts, episodes)
    private var isLoading = false // Track loading state
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SavedAlbumTableViewCell.self, forCellReuseIdentifier: SavedAlbumTableViewCell.identifier)
        tableView.register(SavedPlaylistTableViewCell.self, forCellReuseIdentifier: SavedPlaylistTableViewCell.identifier)
        tableView.register(SavedPodcastTableViewCell.self, forCellReuseIdentifier: SavedPodcastTableViewCell.identifier)
        tableView.register(SavedEpisodeTableViewCell.self, forCellReuseIdentifier: SavedEpisodeTableViewCell.identifier) // Register cell for episodes
        return tableView
    }()
    
    private let loadingSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Saved Items"
        view.backgroundColor = .systemBackground
        setupTableView()
        setupLoadingSpinner()
        fetchSavedItems()
    }

    // Setup Table View
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // Setup Loading Spinner
    private func setupLoadingSpinner() {
        view.addSubview(loadingSpinner)
        NSLayoutConstraint.activate([
            loadingSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // Show Loading Spinner
    private func showLoadingSpinner() {
        loadingSpinner.startAnimating()
        isLoading = true
    }
    
    // Hide Loading Spinner
    private func hideLoadingSpinner() {
        loadingSpinner.stopAnimating()
        isLoading = false
    }

    // Show Error Alert
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func fetchSavedItems() {
        showLoadingSpinner()
        
        let group = DispatchGroup()
        
        var fetchedAlbums: [Album] = []
        var fetchedPlaylists: [PlaylistItem] = []
        var fetchedPodcasts: [UsersSavedShowsItems] = [] // Replace `PodcastItem` with your podcast model
        var fetchedEpisodes: [UserSavedEpisode] = [] // Add a new array for episodes
        
        // Fetch Saved Albums
        group.enter()
        AlbumApiCaller.shared.getSavedAlbums { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    fetchedAlbums = response.items.compactMap { $0.album }
                case .failure(let error):
                    print("Failed to fetch saved albums: \(error.localizedDescription)")
                }
                group.leave()
            }
        }

        // Fetch Saved Playlists
        group.enter()
        PlaylistApiCaller.shared.getCurrentUsersPlaylist { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    fetchedPlaylists = response.items ?? []
                case .failure(let error):
                    print("Failed to fetch saved playlists: \(error.localizedDescription)")
                }
                group.leave()
            }
        }

        // Fetch Saved Podcasts
        group.enter()
        ChapterApiCaller.shared.getUserSavedShows { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    fetchedPodcasts = response.items ?? []
                case .failure(let error):
                    print("Failed to fetch saved podcasts: \(error.localizedDescription)")
                }
                group.leave()
            }
        }
        
        // Fetch Saved Episodes
        group.enter()
        ChapterApiCaller.shared.getUserSavedEpisodes { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    fetchedEpisodes = response.items ?? []
                case .failure(let error):
                    print("Failed to fetch saved episodes: \(error.localizedDescription)")
                }
                group.leave()
            }
        }

        // Notify when all fetches are done
        group.notify(queue: .main) {
            self.hideLoadingSpinner()
            
            self.savedItems = [
                fetchedAlbums.map { SavedItemType.album($0) },
                fetchedPlaylists.map { SavedItemType.playlist($0) },
                fetchedPodcasts.map { SavedItemType.podcast($0) },
                fetchedEpisodes.map { SavedItemType.episode($0) } // Add episodes to savedItems
            ].flatMap { $0 }
            
            if self.savedItems.isEmpty {
                self.showError(message: "No saved items found.")
            }
            
            self.tableView.reloadData()
        }
    }

    // MARK: - TableView DataSource & Delegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = savedItems[indexPath.row]
        switch item {
        case .album(let album):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SavedAlbumTableViewCell.identifier, for: indexPath) as? SavedAlbumTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: album)
            return cell
        case .playlist(let playlist):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SavedPlaylistTableViewCell.identifier, for: indexPath) as? SavedPlaylistTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: playlist)
            return cell
        case .podcast(let podcast):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SavedPodcastTableViewCell.identifier, for: indexPath) as? SavedPodcastTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: podcast)
            return cell
        case .episode(let episode):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SavedEpisodeTableViewCell.identifier, for: indexPath) as? SavedEpisodeTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: episode)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = savedItems[indexPath.row]
        
        switch item {
        case .album(let album):
            let detailVC = AlbumDetailViewController(album: album)
            navigationController?.pushViewController(detailVC, animated: true)
        case .playlist(let playlist):
            let playerListVC = PlayerListViewController(playlist: playlist)
            navigationController?.pushViewController(playerListVC, animated: true)
        case .podcast(let podcast):
            let detailVC = PodcastDetailViewController(podcast: podcast)
            navigationController?.pushViewController(detailVC, animated: true)
        case .episode(let episode):
            let episodeDetailVC = EpisodeDetailViewController(episode: episode) // Assuming you have an episode detail view controller
            navigationController?.pushViewController(episodeDetailVC, animated: true)
        }
    }
}




