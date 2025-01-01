//
//  LibraryViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 04/12/2024.
//

import UIKit

//import UIKit
//
//class LibraryViewController: UIViewController {
//    let tableView = UITableView()
//    let segmentedControl = UISegmentedControl(items: ["Playlists", "Podcasts", "Albums"])
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        setupNavigationBar()
//        setupSegmentedControl()
//        setupTableView()
//    }
//    
//    private func setupNavigationBar() {
//        title = "Your Library"
//        navigationController?.navigationBar.prefersLargeTitles = true
//    }
//    
//    private func setupSegmentedControl() {
//        segmentedControl.selectedSegmentIndex = 0
//        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
//        view.addSubview(segmentedControl)
//        
//        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
//            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
//        ])
//    }
//    
//    private func setupTableView() {
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.register(LibraryCell.self, forCellReuseIdentifier: LibraryCell.identifier)
//        view.addSubview(tableView)
//        
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 10),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//    }
//    
//    @objc private func segmentChanged() {
//        // Handle filtering logic
//        tableView.reloadData()
//    }
//}
//
//extension LibraryViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 10 // Replace with actual data count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: LibraryCell.identifier, for: indexPath) as? LibraryCell else {
//            return UITableViewCell()
//        }
//        // Configure cell
//        cell.configure(with: "Item \(indexPath.row)", subtitle: "Subtitle \(indexPath.row)", image: UIImage(systemName: "music.note"))
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        // Handle row selection
//    }
//}
//
//
//class LibraryCell: UITableViewCell {
//    static let identifier = "LibraryCell"
//    
//    private let itemImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
//        imageView.layer.cornerRadius = 8
//        return imageView
//    }()
//    
//    private let titleLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
//        return label
//    }()
//    
//    private let subtitleLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
//        label.textColor = .gray
//        return label
//    }()
//    
//    private let chevronImageView: UIImageView = {
//        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
//        imageView.tintColor = .gray
//        return imageView
//    }()
//    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        
//        contentView.addSubview(itemImageView)
//        contentView.addSubview(titleLabel)
//        contentView.addSubview(subtitleLabel)
//        contentView.addSubview(chevronImageView)
//        
//        itemImageView.translatesAutoresizingMaskIntoConstraints = false
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
//        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            itemImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
//            itemImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            itemImageView.widthAnchor.constraint(equalToConstant: 50),
//            itemImageView.heightAnchor.constraint(equalToConstant: 50),
//            
//            titleLabel.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: 10),
//            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
//            titleLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -10),
//            
//            subtitleLabel.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: 10),
//            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
//            subtitleLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -10),
//            
//            chevronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
//            chevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
//        ])
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func configure(with title: String, subtitle: String, image: UIImage?) {
//        titleLabel.text = title
//        subtitleLabel.text = subtitle
//        itemImageView.image = image
//    }
//}


enum SavedItemType {
    case album(Album)
    case playlist(PlaylistItem)
    case podcast(UsersSavedShowsItems) // Assuming you have a `PodcastItem` model
    case episode(UserSavedEpisode) // Add case for saved episodes
}


class LibraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
        title = "Your Library"
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
        ChapterApiCaller.shared.getUserSavedPodCasts { [weak self] result in
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

