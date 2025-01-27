//
//  LibraryViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 04/12/2024.
//

import UIKit


enum SavedItemType {
    case album(Album)
    case playlist(PlaylistItem)
    case podcast(UsersSavedShowsItems)
    case episode(UserSavedEpisode)
}

class LibraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    private var savedItems: [SavedItemType] = [] // Store all saved items
    private var filteredItems: [SavedItemType] = [] // Store filtered items
    private var isLoading = false // Track loading state
    var fetchedAlbums: [Album] = []
    var fetchedPlaylists: [PlaylistItem] = []
    var fetchedPodcasts: [UsersSavedShowsItems] = []
    var fetchedEpisodes: [UserSavedEpisode] = []
    
    public var selectionHandler: ((PlaylistItem)->Void)?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SavedAlbumTableViewCell.self, forCellReuseIdentifier: SavedAlbumTableViewCell.identifier)
        tableView.register(SavedPlaylistTableViewCell.self, forCellReuseIdentifier: SavedPlaylistTableViewCell.identifier)
        tableView.register(SavedPodcastTableViewCell.self, forCellReuseIdentifier: SavedPodcastTableViewCell.identifier)
        tableView.register(SavedEpisodeTableViewCell.self, forCellReuseIdentifier: SavedEpisodeTableViewCell.identifier)
        return tableView
    }()
    
    private let loadingSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["All", "Albums", "Playlists", "Podcasts", "Episodes"])
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()
    
   
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Your Library"
        view.backgroundColor = .systemBackground
        setupUI()
        fetchSavedItems()
        
        if selectionHandler != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        }
        
    }
    
    @objc func didTapClose(){
        dismiss(animated: true,completion: nil)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        view.addSubview(loadingSpinner)
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Segmented Control Constraints
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // TableView Constraints
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor), // Use safeAreaLayoutGuide

    
            
            // Loading Spinner Constraints
            loadingSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapAction))
    }

    
    // MARK: - Loading Spinner
    private func showLoadingSpinner() {
        loadingSpinner.startAnimating()
        isLoading = true
    }
    
    private func hideLoadingSpinner() {
        loadingSpinner.stopAnimating()
        isLoading = false
    }
    

    // MARK: - Data Fetching
    private func fetchSavedItems() {
        showLoadingSpinner()
        
        let group = DispatchGroup()
        
        
        // Fetch Albums
        group.enter()
        AlbumApiCaller.shared.getUserSavedAlbums { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.fetchedAlbums = response.items.compactMap { $0.album }
                case .failure(let error):
                    print("Failed to fetch albums: \(error.localizedDescription)")
                }
                group.leave()
            }
        }
        
        // Fetch Playlists
        group.enter()
        PlaylistApiCaller.shared.getCurrentUsersPlaylist { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.fetchedPlaylists = response.items ?? []
                case .failure(let error):
                    print("Failed to fetch playlists: \(error.localizedDescription)")
                }
                group.leave()
            }
        }
        
        // Fetch Podcasts
        group.enter()
        ChapterApiCaller.shared.getUserSavedPodCasts { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.fetchedPodcasts = response.items ?? []
                case .failure(let error):
                    print("Failed to fetch podcasts: \(error.localizedDescription)")
                }
                group.leave()
            }
        }
        
        // Fetch Episodes
        group.enter()
        ChapterApiCaller.shared.getUserSavedEpisodes { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.fetchedEpisodes = response.items ?? []
                case .failure(let error):
                    print("Failed to fetch episodes: \(error.localizedDescription)")
                }
                group.leave()
            }
        }
        
        // Combine and Handle Results
        group.notify(queue: .main) {
            self.hideLoadingSpinner()
            self.savedItems = [
                self.fetchedAlbums.map { SavedItemType.album($0) },
                self.fetchedPlaylists.map { SavedItemType.playlist($0) },
                self.fetchedPodcasts.map { SavedItemType.podcast($0) },
                self.fetchedEpisodes.map { SavedItemType.episode($0) }
            ].flatMap { $0 }
            
            self.filteredItems = self.savedItems // Default to showing all items
            
            if self.savedItems.isEmpty {
                self.showError(message: "No saved items found.")
            }
            
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Segmented Control Handler
    @objc private func segmentChanged() {
        switch segmentedControl.selectedSegmentIndex {
        case 1: // Albums
            filteredItems = savedItems.filter { if case .album = $0 { return true } else { return false } }
        case 2: // Playlists
            filteredItems = savedItems.filter { if case .playlist = $0 { return true } else { return false } }
        case 3: // Podcasts
            filteredItems = savedItems.filter { if case .podcast = $0 { return true } else { return false } }
        case 4: // Episodes
            filteredItems = savedItems.filter { if case .episode = $0 { return true } else { return false } }
        default: // All
            filteredItems = savedItems
        }
        tableView.reloadData()
    }
    
    @objc func didTapAction() {
        let customActionSheet = CustomActionSheetViewController()
        customActionSheet.modalPresentationStyle = .overFullScreen

        // Set the action handler with a completion handler
        customActionSheet.actionHandler = { [weak self] action in
            // Dismiss the action sheet first
            self?.dismiss(animated: true, completion: {
                // After dismissing, handle the action
                self?.handleActionSelection(action: action)
            })
        }

        // Present the custom action sheet
        present(customActionSheet, animated: true, completion: nil)
    }
    
    private func handleActionSelection(action: String) {
        switch action {
        case "Create Playlist":
            // Navigate to Create Playlist screen
            let createPlaylistVC = CreatePlaylistViewController()  // Assuming this is the view controller to create playlists
            createPlaylistVC.modalPresentationStyle = .fullScreen // Adjust the presentation style as needed
            present(createPlaylistVC, animated: true, completion: nil)
        case "Blend":
            // Handle Blend action (not implemented here)
            print("Navigate to Blend View Controller")
        default:
            break
        }
    }





    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }


    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = filteredItems[indexPath.row]
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
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = filteredItems[indexPath.row]
        
        switch item {
        case .album(let album):
            if let albumID = album.id {
                let detailVC = AlbumDetailViewController(albumID: albumID)
                navigationController?.pushViewController(detailVC, animated: true)
            }
           
        case .playlist(let playlist):
            guard selectionHandler == nil else {
                selectionHandler?(playlist)
                dismiss(animated: true,completion: nil)
                return
            }
            if let selectedPlaylistID = playlist.id {
                let playerListVC = PlayListViewController(playlistID: selectedPlaylistID)
                navigationController?.pushViewController(playerListVC, animated: true)
            }
           
        case .podcast(let podcast):
            let detailVC = PodcastDetailViewController(podcast: podcast)
            navigationController?.pushViewController(detailVC, animated: true)
        case .episode(let episode):
            if let episodeID = episode.episode?.id {
                let episodeDetailVC = EpisodeDetailViewController(episodeID: episodeID)
                navigationController?.pushViewController(episodeDetailVC, animated: true)
            }
           
        }
    }
}


