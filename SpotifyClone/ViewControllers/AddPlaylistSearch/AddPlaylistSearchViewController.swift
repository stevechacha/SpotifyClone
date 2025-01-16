//
//  AddPlaylistSearchViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 15/01/2025.
//

import UIKit


class AddPlaylistSearchViewController: UIViewController {

    // MARK: - Properties
    private let searchBarContainer = UIView() // Container for better styling of the search bar
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private var searchResults: [SearchResult] = [] // Unified structure to hold all results
    private var isLoading = false
    private var searchWorkItem: DispatchWorkItem? // To handle delayed searches

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search"
        setupUI()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground

        // Configure Search Bar Container
        searchBarContainer.backgroundColor = .systemBackground
        searchBarContainer.layer.shadowColor = UIColor.black.cgColor
        searchBarContainer.layer.shadowOpacity = 0.1
        searchBarContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        searchBarContainer.layer.shadowRadius = 4
        searchBarContainer.layer.cornerRadius = 8
        view.addSubview(searchBarContainer)
        searchBarContainer.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            searchBarContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            searchBarContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBarContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchBarContainer.heightAnchor.constraint(equalToConstant: 50)
        ])

        // Configure Search Bar
        searchBar.placeholder = "Search albums, artists, tracks, playlists..."
        searchBar.delegate = self
        searchBarContainer.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: searchBarContainer.topAnchor),
            searchBar.bottomAnchor.constraint(equalTo: searchBarContainer.bottomAnchor),
            searchBar.leadingAnchor.constraint(equalTo: searchBarContainer.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: searchBarContainer.trailingAnchor)
        ])

        // Configure Table View
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AddPlaylistSearchTableViewCell.self, forCellReuseIdentifier: AddPlaylistSearchTableViewCell.identifier)
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBarContainer.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // MARK: - Search Functionality
    func search(query: String) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty, !isLoading else { return }
        isLoading = true

        SearchApi.shared.performSearch(query: query) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                switch result {
                case .success(let response):
                    self.processSearchResults(response)
                case .failure(let error):
                    print("Search failed with error: \(error.localizedDescription)")
                }
            }
        }
    }

    private func processSearchResults(_ response: SearchResponses) {
        searchResults = []

        if let tracks = response.tracks?.items {
            searchResults.append(contentsOf: tracks.map { .track($0) })
        }
        if let artists = response.artists?.items {
            searchResults.append(contentsOf: artists.map { .artist($0) })
        }
        if let albums = response.albums?.items {
            searchResults.append(contentsOf: albums.map { .album($0) })
        }
        if let playlists = response.playlists?.items {
            searchResults.append(contentsOf: playlists.map { .playlist($0) })
        }
        if let audiobooks = response.audiobooks?.items {
            searchResults.append(contentsOf: audiobooks.map { .audiobook($0) })
        }
        if let shows = response.shows?.items {
            searchResults.append(contentsOf: shows.map { .show($0) })
        }
        if let episodes = response.episodes?.items {
            searchResults.append(contentsOf: episodes.map { .episode($0) })
        }
        if let chapters = response.chapters?.items {
            searchResults.append(contentsOf: chapters.map { .chapter($0) })
        }

        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension AddPlaylistSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = searchResults[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: AddPlaylistSearchTableViewCell.identifier,
            for: indexPath
        ) as? AddPlaylistSearchTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: result)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let result = searchResults[indexPath.row]

        switch result {
        case .artist(let artist):
            if let artistID = artist.id {
                let vc = ArtistViewController(artistID: artistID)
                navigationController?.pushViewController(vc, animated: true)
            }
           
        case .album(let album):
            let vc = AlbumDetailViewController(albumID: album.id ?? "")
            navigationController?.pushViewController(vc, animated: true)
        case .playlist(let playlist):
            let vc = PlayListViewController(playlistID: playlist.id ?? "")
            navigationController?.pushViewController(vc, animated: true)
        case .track(let track):
            if let trackID = track.id {
                let vc = TrackDetailViewController(trackID: trackID)
                navigationController?.pushViewController(vc, animated: true)
            }
        case .audiobook(let audiobook):
            let vc = AudiobookDetailViewController(audiobook: audiobook)
            navigationController?.pushViewController(vc, animated: true)
        case .show(let show):
            let vc = ShowDetailViewController(showID: show.id ?? "")
            navigationController?.pushViewController(vc, animated: true)
        case .episode(let episode):
            if let episodeID = episode.id {
                let vc = EpisodeDetailViewController(episodeID: episodeID)
                navigationController?.pushViewController(vc, animated: true)
            }
        case .chapter(let chapter):
            let vc = ChapterDetailViewController(chapter: chapter)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - UISearchBarDelegate
extension AddPlaylistSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.search(query: searchText)
        }
        searchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else { return }
        search(query: query)
        searchBar.resignFirstResponder()
    }
}
