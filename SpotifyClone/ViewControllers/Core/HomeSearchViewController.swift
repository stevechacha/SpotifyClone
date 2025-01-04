//
//  HomeSearchViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 03/01/2025.
//


import UIKit

class HomeSearchViewController: UIViewController {
    
    // MARK: - Properties
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private var searchResults: [SearchResult] = [] // Unified structure to hold all results
    private var isLoading = false
    private var searchWorkItem: DispatchWorkItem? // To handle delayed searches
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Configure Search Bar
        searchBar.placeholder = "Search albums, artists, tracks, playlists..."
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        // Configure Table View
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: SearchResultTableViewCell.identifier)

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
        // Flatten results into a unified structure
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
extension HomeSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = searchResults[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.identifier, for: indexPath) as? SearchResultTableViewCell else {
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
            let vc = ArtistDetailViewController(artist: artist)
            navigationController?.pushViewController(vc, animated: true)
            
        case .album(let album):
            let vc = AlbumDetailViewController(album: album)
            navigationController?.pushViewController(vc, animated: true)
            
        case .playlist(let playlist):
            let vc = PlaylistDetailViewController(playlist: playlist)
            navigationController?.pushViewController(vc, animated: true)
            
        case .track(let track):
            let vc = TrackDetailViewController(track: track)
            navigationController?.pushViewController(vc, animated: true)
            
        case .audiobook(let audiobook):
            let vc = AudiobookDetailViewController(audiobook: audiobook)
            navigationController?.pushViewController(vc, animated: true)
            
        case .show(let show):
            let vc = ShowDetailViewController(show: show)
            navigationController?.pushViewController(vc, animated: true)
            
        case .episode(let episode):
            let vc = EpisodeDetailViewController(episode: episode)
            navigationController?.pushViewController(vc, animated: true)
            
        case .chapter(let chapter):
            let vc = ChapterDetailViewController(chapter: chapter)
            navigationController?.pushViewController(vc, animated: true)
        }
    }

}

// MARK: - UISearchBarDelegate
extension HomeSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Cancel any previous search work item to avoid race conditions
        searchWorkItem?.cancel()
        
        // Create a new search work item
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.search(query: searchText)
        }
        
        searchWorkItem = workItem
        
        // Delay search by 0.5 seconds to avoid excessive API calls
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else { return }
        search(query: query)
        searchBar.resignFirstResponder()
    }
}

// MARK: - Models & Services
enum SearchResult {
    case track(Track)
    case artist(Artist)
    case album(Album)
    case playlist(PlaylistItem)
    case audiobook(Audiobook)
    case show(Show)
    case episode(Episode)
    case chapter(Chapter)
}

