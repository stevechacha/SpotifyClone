//
//  ViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 04/12/2024.
//
import UIKit
import SwiftUI

enum BrowseSectionType {
    case yourFavouriteArtist(viewModels: [YourFavouriteArtistCellViewModel])
    case playlists(viewModels: [PlaylistCellViewModel])
    case newReleases(viewModels: [NewReleasesCellViewModel])
    case recentPlaylist(viewModels: [RecentPlaylistCellViewModel])
    case savedAlbums(viewModels: [SavedAlbumCellViewModel])
    case topArtists(viewModels: [TopArtistCellViewModel])
    case topTracks(viewModels: [TopTrackCellViewModel])
    case albumsByArtistsYouFollow(viewModels: [AlbumsByArtistYouFollowCellViewModel])
}

class HomeViewController: UIViewController {
    // MARK: - UI Components
    
    private lazy var collectionView: UICollectionView = {
        let layout = UIHelper.createLayout(sections: self.sections)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return cv
    }()

    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    
    private var sections = [BrowseSectionType]()
    private var filteredSections = [BrowseSectionType]()
    
    var playlists: [PlaylistItem] = []
    var newReleases: [Album] = []
    var savedAlbums: [Album] = []
    var albumsByArtistsYouFollow: [Album] = []
    var topArtists: [TopItem] = []
    var topTracks: [TopItem] = []
    var yourFavouriteArtist: [FollowedArtist] = []
    var recentPlaylist: [RecentlyPlayedItem] = []
    
    
    
    // MARK: - Initializer
    init(sections: [BrowseSectionType]) {
        self.sections = sections
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        configureCollectionView()
        fetchData()
    }
    
    
    
    
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
        ])
    }
    
    
    private func configureCollectionView() {
        collectionView.register(PlaylistCollectionViewCell.self, forCellWithReuseIdentifier: PlaylistCollectionViewCell.identifier)
        collectionView.register(RecentCollectionViewCell.self, forCellWithReuseIdentifier: RecentCollectionViewCell.identifier)
        collectionView.register(AlbumsByArtistYouFollowCollectionViewCell.self, forCellWithReuseIdentifier: AlbumsByArtistYouFollowCollectionViewCell.identifier)
        collectionView.register(YourFavouriteArtistsCollectionViewCell.self, forCellWithReuseIdentifier: YourFavouriteArtistsCollectionViewCell.identifier)
        collectionView.register(SavedAlbumCollectionViewCell.self, forCellWithReuseIdentifier: SavedAlbumCollectionViewCell.identifier)
        collectionView.register(NewReleaseCollectionViewCell.self, forCellWithReuseIdentifier: NewReleaseCollectionViewCell.identifier)
        collectionView.register(TopArtistCollectionViewCell.self, forCellWithReuseIdentifier: TopArtistCollectionViewCell.identifier)
        collectionView.register(TopTrackCollectionViewCell.self, forCellWithReuseIdentifier: TopTrackCollectionViewCell.identifier)
        collectionView.register(SectionHeaderView.self,forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,withReuseIdentifier: SectionHeaderView.identifier
        )
        
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
    }
    
    private func fetchData() {
        activityIndicator.startAnimating()
        collectionView.isHidden = true
        
        let group = DispatchGroup()
        
        // Fetch Recently Played
        group.enter()
        SpotifyPlayer.shared.getRecentlyPlayed { [weak self] result in
            defer { group.leave() }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.recentPlaylist = response.items ?? []
                case .failure(let error):
                    self?.pressSpotyfyAlertThread(
                        title: "Recent Played",
                        message: error.localizedDescription,
                        buttuonTitle: "OK"
                    )
                }
            }
        }
        
        // Fetch Followed Artists and their albums
        group.enter()
        UserApiCaller.shared.getFollowedArtists { [weak self] result in
            defer { group.leave() }
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.yourFavouriteArtist = response
                    if let artistID = response.first?.id {
                        ArtistApiCaller.shared.getArtistAlbums(artistID: artistID) { [weak self] result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success(let album):
                                    self?.albumsByArtistsYouFollow = album.items
                                case .failure(let error):
                                    self?.pressSpotyfyAlertThread(
                                        title: "Albums For Followed Artist",
                                        message: error.localizedDescription,
                                        buttuonTitle: "OK"
                                    )
                                }
                            }
                        }
                    }
                case .failure(let error):
                    self.pressSpotyfyAlertThread(
                        title: "Bad Staff",
                        message: error.localizedDescription,
                        buttuonTitle: "OK"
                    )
                }
            }
        }
        
        // Fetch Playlists
        group.enter()
        PlaylistApiCaller.shared.getCurrentUsersPlaylist { [weak self] result in
            defer { group.leave() }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.playlists = response.items ?? []
                case .failure(let error):
                    self?.pressSpotyfyAlertThread(
                        title: "Playlist",
                        message: error.localizedDescription,
                        buttuonTitle: "OK"
                    )
                }
            }
        }
        
        // Fetch New Releases
        group.enter()
        AlbumApiCaller.shared.getNewReleases { [weak self] result in
            defer { group.leave() }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.newReleases = response.albums.items
                case .failure(let error):
                    self?.pressSpotyfyAlertThread(
                        title: "Fetch new releases",
                        message: error.localizedDescription,
                        buttuonTitle: "OK"
                    )
                }
            }
        }
        
        // Fetch Top Artists
        group.enter()
        UserApiCaller.shared.getUserTopItems(type: "artists") { [weak self] result in
            defer { group.leave() }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.topArtists = response
                case .failure(let error):
                    self?.pressSpotyfyAlertThread(
                        title: "Top Artist Error",
                        message: error.localizedDescription,
                        buttuonTitle: "OK"
                    )
                }
            }
        }
        
        group.notify(queue: .main) {
            self.activityIndicator.stopAnimating()
            self.collectionView.isHidden = false
            // Configure recently played first so it appears at the top
            self.configureRecently()
            self.configureModels()
            // Filter sections after all sections are added
            self.filterSections(for: 0)
            // Update layout to reflect all sections
            self.updateCollectionViewLayout()
            // Reload collection view to display all sections
            self.collectionView.reloadData()
            print("Final setup complete - sections: \(self.sections.count), filteredSections: \(self.filteredSections.count)")
        }
    }
    
    
    private func configureRecently() {
        print("Configuring Recently Played - \(recentPlaylist.count) items")
        
        // Dictionary to group items by their context
        var groupedItems: [String: (items: [RecentlyPlayedItem], contextType: String, name: String, imageUrl: String?, artistName: String, contextId: String?)] = [:]
        
        // Dictionary to store playlist IDs we need to fetch names for
        var playlistIdsToFetch: Set<String> = []
        
        guard !recentPlaylist.isEmpty else {
            print("No recently played items to display")
            return
        }
        
        for item in recentPlaylist {
            guard let track = item.track else { continue }
            
            // Determine the grouping key and metadata based on context
            let groupKey: String
            var contextType: String
            var displayName: String
            var imageUrl: String?
            var artistName: String
            var contextId: String?
            
            // Check if there's a context (album, playlist, artist, etc.)
            if let context = item.context, let contextUri = context.uri {
                contextType = context.type ?? "unknown"
                
                switch contextType {
                case "album":
                    // Group by album ID (more reliable than URI)
                    groupKey = track.album?.id ?? contextUri
                    displayName = track.album?.name ?? track.name ?? "Unknown Album"
                    imageUrl = track.album?.images?.first?.url
                    artistName = track.artists?.first?.name ?? "Unknown Artist"
                    contextId = track.album?.id
                    
                case "playlist":
                    // Group by playlist URI (tracks from same playlist)
                    groupKey = contextUri
                    // Extract playlist ID from URI (spotify:playlist:ID)
                    let playlistId = contextUri.components(separatedBy: ":").last ?? ""
                    contextId = playlistId
                    
                    // Check if we already have this playlist in our groups
                    if let existingGroup = groupedItems[groupKey] {
                        // Use existing group's name (already fetched or placeholder)
                        displayName = existingGroup.name
                        imageUrl = existingGroup.imageUrl ?? track.album?.images?.first?.url
                        artistName = existingGroup.artistName
                    } else {
                        // New playlist - use placeholder for now, will fetch name later
                        displayName = "Playlist" // Placeholder, will be updated
                        imageUrl = track.album?.images?.first?.url
                        artistName = "Various Artists"
                        playlistIdsToFetch.insert(playlistId)
                    }
                    
                case "artist":
                    // Group by artist
                    groupKey = track.artists?.first?.id ?? contextUri
                    displayName = track.artists?.first?.name ?? "Unknown Artist"
                    imageUrl = track.artists?.first?.images?.first?.url
                    artistName = ""
                    contextId = track.artists?.first?.id
                    
                default:
                    // Fallback to album grouping
                    contextType = "album"
                    groupKey = track.album?.id ?? track.id ?? UUID().uuidString
                    displayName = track.album?.name ?? track.name ?? "Unknown"
                    imageUrl = track.album?.images?.first?.url
                    artistName = track.artists?.first?.name ?? "Unknown Artist"
                    contextId = track.album?.id
                }
            } else {
                // No context - always try to group by album first
                if let albumId = track.album?.id, !albumId.isEmpty {
                    // Group by album ID
                    contextType = "album"
                    groupKey = albumId
                    displayName = track.album?.name ?? "Unknown Album"
                    imageUrl = track.album?.images?.first?.url
                    artistName = track.artists?.first?.name ?? "Unknown Artist"
                    contextId = albumId
                } else if let artistId = track.artists?.first?.id, !artistId.isEmpty {
                    // Fallback to artist grouping if no album
                    contextType = "artist"
                    groupKey = artistId
                    displayName = track.artists?.first?.name ?? "Unknown Artist"
                    imageUrl = track.artists?.first?.images?.first?.url
                    artistName = ""
                    contextId = artistId
                } else {
                    // Last resort - group by track ID (will show individually)
                    contextType = "track"
                    groupKey = track.id ?? UUID().uuidString
                    displayName = track.name ?? "Unknown Track"
                    imageUrl = track.album?.images?.first?.url
                    artistName = track.artists?.first?.name ?? "Unknown Artist"
                    contextId = track.id
                }
            }
            
            // Add to group or create new group
            if var existingGroup = groupedItems[groupKey] {
                // Add item to existing group, but keep the original group metadata
                existingGroup.items.append(item)
                groupedItems[groupKey] = existingGroup
            } else {
                // Create new group with this item's metadata
                groupedItems[groupKey] = (
                    items: [item],
                    contextType: contextType,
                    name: displayName,
                    imageUrl: imageUrl,
                    artistName: artistName,
                    contextId: contextId
                )
            }
        }
        
        print("Grouped \(recentPlaylist.count) items into \(groupedItems.count) groups")
        
        // Fetch playlist names for playlists we encountered
        if !playlistIdsToFetch.isEmpty {
            class PlaylistData {
                var names: [String: String] = [:]
                var images: [String: String] = [:]
                let queue = DispatchQueue(label: "com.spotifyclone.playlistdata")
            }
            
            let playlistData = PlaylistData()
            let dispatchGroup = DispatchGroup()
            
            for playlistId in playlistIdsToFetch {
                dispatchGroup.enter()
                PlaylistApiCaller.shared.getPlaylistDetails(playlistID: playlistId) { result in
                    defer { dispatchGroup.leave() }
                    switch result {
                    case .success(let playlist):
                        playlistData.queue.async {
                            playlistData.names[playlistId] = playlist.name
                            playlistData.images[playlistId] = playlist.images?.first?.url
                        }
                    case .failure:
                        // Keep placeholder name if fetch fails
                        break
                    }
                }
            }
            
            // Wait for all playlist fetches to complete (on background queue to avoid blocking UI)
            dispatchGroup.notify(queue: .global(qos: .userInitiated)) { [weak self, groupedItems, playlistData] in
                guard let self = self else { return }
                
                // Read the final state of dictionaries
                playlistData.queue.sync {
                    // Create a mutable copy to update
                    var updatedGroupedItems = groupedItems
                    
                    // Update grouped items with fetched playlist names
                    for (key, var group) in updatedGroupedItems {
                        if group.contextType == "playlist", let playlistId = group.contextId {
                            if let fetchedName = playlistData.names[playlistId] {
                                group.name = fetchedName
                            }
                            if let fetchedImage = playlistData.images[playlistId], group.imageUrl == nil {
                                group.imageUrl = fetchedImage
                            }
                            updatedGroupedItems[key] = group
                        }
                    }
                    
                    // Rebuild view models with updated names
                    self.buildRecentlyPlayedViewModels(from: updatedGroupedItems, updateUI: true)
                }
            }
            
            // For now, continue with placeholder names (will update when fetch completes)
        }
        
        // Build view models from grouped items (synchronously for initial load)
        buildRecentlyPlayedViewModels(from: groupedItems, updateUI: true)
    }
    
    private func buildRecentlyPlayedViewModels(from groupedItems: [String: (items: [RecentlyPlayedItem], contextType: String, name: String, imageUrl: String?, artistName: String, contextId: String?)], updateUI: Bool = false) {
        var recentPlaylistViewModels: [RecentPlaylistCellViewModel] = []
        
        for (_, group) in groupedItems {
            let viewModel = RecentPlaylistCellViewModel(
                name: group.name,
                artUrl: URL(string: group.imageUrl ?? ""),
                numberOfTracks: group.items.count,
                artistName: group.artistName,
                objectType: group.contextType,
                contextId: group.contextId
            )
            recentPlaylistViewModels.append(viewModel)
        }
        
        // Sort by most recent (use the most recent playedAt time from each group)
        recentPlaylistViewModels.sort { vm1, vm2 in
            // Find the groups by matching contextId
            let group1 = groupedItems.values.first { group in
                group.contextId == vm1.contextId && group.name == vm1.name
            }
            let group2 = groupedItems.values.first { group in
                group.contextId == vm2.contextId && group.name == vm2.name
            }
            
            // Get the most recent playedAt from each group
            let mostRecent1 = group1?.items.compactMap { $0.playedAt }.max() ?? ""
            let mostRecent2 = group2?.items.compactMap { $0.playedAt }.max() ?? ""
            
            return mostRecent1 > mostRecent2 // Most recent first
        }
        
        // Update or add the section
        let updateSection = {
            // Remove existing recentPlaylist section if it exists
            self.sections.removeAll { section in
                if case .recentPlaylist = section {
                    return true
                }
                return false
            }
            // Add updated section at the beginning (top of the list)
            if !recentPlaylistViewModels.isEmpty {
                self.sections.insert(.recentPlaylist(viewModels: recentPlaylistViewModels), at: 0)
                print("Added Recently Played section at top with \(recentPlaylistViewModels.count) items")
            } else {
                print("Recently Played section is empty - no items to display")
            }
            // Reload collection view if requested
            if updateUI {
                // Only update sections here - filterSections() will be called after all sections are configured
                // For async updates (after playlist names are fetched), we need to update filteredSections
                if self.sections.count > 1 {
                    // This is an async update after initial setup - update filteredSections and layout
                    self.filterSections(for: 0)
                    self.updateCollectionViewLayout()
                }
                self.collectionView.reloadData()
                print("Updated sections - sections now has \(self.sections.count) items, filteredSections has \(self.filteredSections.count) items")
            }
        }
        
        if Thread.isMainThread {
            updateSection()
        } else {
            DispatchQueue.main.async {
                updateSection()
            }
        }
    }
    
    // MARK: - Layout Update
    private func updateCollectionViewLayout() {
        let newLayout = UIHelper.createLayout(sections: self.filteredSections)
        collectionView.setCollectionViewLayout(newLayout, animated: false)
    }
    
    
    // MARK: - Data Configuration
    private func configureModels() {
        // Playlists
        let playlistViewModels = playlists.map {
            PlaylistCellViewModel(
                name: $0.name ?? "",
                artUrl: URL(string: $0.images?.first?.url ?? "")
            )
        }
        sections.append(.playlists(viewModels: playlistViewModels))
        
        // New Releases
        let newReleaseViewModels = newReleases.map {
            NewReleasesCellViewModel(
                name: $0.name ?? "",
                artUrl: URL(string: $0.images?.first?.url ?? ""),
                numberOfTracks: $0.totalTracks ?? 0,
                artistName: $0.artists?.first?.name ?? ""
            )
        }
        sections.append(.newReleases(viewModels: newReleaseViewModels))
        
        
        // AlbumsByArtisYouFollow
        let albumsByArtisYouFollowViewModels = albumsByArtistsYouFollow.map {
            AlbumsByArtistYouFollowCellViewModel(
                name: $0.name ?? "",
                artUrl: URL(string: $0.images?.first?.url ?? ""),
                numberOfTracks: $0.totalTracks ?? 0,
                artistName: $0.artists?.first?.name ?? ""
            )
        }
        sections.append(.albumsByArtistsYouFollow(viewModels: albumsByArtisYouFollowViewModels))
        
        
        
        // New Releases
        let yourFavouriteArtistViewModels = yourFavouriteArtist.map {
            YourFavouriteArtistCellViewModel(
                name: $0.name ?? "",
                artUrl: URL(string: $0.images?.first?.url ?? ""),
                numberOfTracks: $0.popularity ?? 0,
                artistName: $0.type?.description.capitalized ?? ""
            )
        }
        sections.append(.yourFavouriteArtist(viewModels: yourFavouriteArtistViewModels))
        
        
        // Saved Albums
        let savedAlbumViewModels = savedAlbums.map {
            SavedAlbumCellViewModel(
                name: $0.name ?? "",
                artUrl: URL(string: $0.images?.first?.url ?? ""),
                numberOfTracks: $0.totalTracks ?? 0,
                artistName: $0.artists?.first?.name ?? ""
            )
        }
        sections.append(.savedAlbums(viewModels: savedAlbumViewModels))
        
        
        
        // Top Artists
        let artistViewModels = topArtists.map {
            TopArtistCellViewModel(
                name: $0.name,
                type: $0.type ?? "",
                imageUrl: URL(string: $0.images?.first?.url ?? "")
            )
        }
        sections.append(.topArtists(viewModels: artistViewModels))
        
        // Top Tracks
        let trackViewModels = topTracks.map { track -> TopTrackCellViewModel in
            let imageUrl = URL(string: track.images?.first?.url ?? "")
            let trackID = track.id ?? ""
            
            var viewModel = TopTrackCellViewModel(
                id: track.id ?? "",
                name: track.name,
                artUrl: imageUrl
            )
            
            // Fetch additional data from API
            TrackApiCaller.shared.getTrack(trackID: trackID) { [weak self] result in
                switch result {
                case .success(let response):
                    if let newImageUrlString = response.album?.images?.first?.url, let newImageUrl = URL(string: newImageUrlString) {
                        viewModel.artUrl = newImageUrl
                        DispatchQueue.main.async {
                            self?.reloadUIForTrack(trackID: trackID)
                        }
                    }
                case .failure(let error):
                    self?.pressSpotyfyAlertThread(title: "Bad Staff", message: error.localizedDescription ,buttuonTitle: "OK")
                    print("Failed to fetch track data for \(track.name): \(error.localizedDescription)")
                }
            }
            
            return viewModel
        }
        
        sections.append(.topTracks(viewModels: trackViewModels))
        
    }
    
    private func reloadUIForTrack(trackID: String) {
        guard let sectionIndex = sections.firstIndex(where: {
            if case .topTracks = $0 { return true }
            return false
        }),
              case .topTracks(let viewModels) = sections[sectionIndex],
              let index = viewModels.firstIndex(where: { $0.id == trackID }) else {
            return
        }
        
        let indexPath = IndexPath(item: index, section: sectionIndex)
        collectionView.reloadItems(at: [indexPath])
    }
    
    
    // MARK: - Filtering
    private func filterSections(for index: Int) {
        filteredSections = sections.filter {
            switch $0 {
            case .yourFavouriteArtist(let viewModels): return !viewModels.isEmpty
            case .playlists(let viewModels): return !viewModels.isEmpty
            case .newReleases(let viewModels): return !viewModels.isEmpty
            case .topArtists(let viewModels): return !viewModels.isEmpty
            case .topTracks(let viewModels): return !viewModels.isEmpty
            case .savedAlbums(let viewModels): return !viewModels.isEmpty
            case .recentPlaylist(let viewModels): return !viewModels.isEmpty
            case .albumsByArtistsYouFollow(let viewModels): return !viewModels.isEmpty
            }
        }
        collectionView.reloadData()
    }
    
    
    
    
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
        
        let section = filteredSections[indexPath.section]
        let headerTitle: String
        switch section {
        case .yourFavouriteArtist: headerTitle = "Your favourite artists"
        case .playlists: headerTitle = "Playlists"
        case .newReleases: headerTitle = "New Releases"
        case .topArtists: headerTitle = "Top Artists"
        case .topTracks: headerTitle = "Top Tracks"
        case .savedAlbums: headerTitle = "Saved Albums"
        case .recentPlaylist: headerTitle = "Recently Played"
        case .albumsByArtistsYouFollow : headerTitle = "Albums by artists you follow"
            
        }
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.identifier,
            for: indexPath
        ) as? SectionHeaderView else {
            return UICollectionReusableView()
        }
        
        header.configure(with: headerTitle)
        return header
    }

    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let type = filteredSections[section]
        switch type {
        case .yourFavouriteArtist(viewModels: let viewModels): return viewModels.count
        case .playlists(let viewModels): return viewModels.count
        case .newReleases(let viewModels): return viewModels.count
        case .topArtists(let viewModels): return viewModels.count
        case .topTracks(let viewModels): return viewModels.count
        case .savedAlbums(viewModels: let viewModels): return viewModels.count
        case .recentPlaylist(viewModels: let viewModels): return viewModels.count
        case .albumsByArtistsYouFollow(viewModels: let viewModels): return viewModels.count
           
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let type = filteredSections[indexPath.section]
        switch type {
        case .playlists(let viewModels):
            
            return dequeueConfiguredCell(
                collectionView: collectionView,
                indexPath: indexPath,
                cellType: PlaylistCollectionViewCell.self,
                identifier: PlaylistCollectionViewCell.identifier,
                viewModel: viewModels[indexPath.item]
            ) { cell, viewModel in
                cell.configure(with: viewModel)
            }
            
        case .newReleases(let viewModels):
            return dequeueConfiguredCell(
                collectionView: collectionView,
                indexPath: indexPath,
                cellType: NewReleaseCollectionViewCell.self,
                identifier: NewReleaseCollectionViewCell.identifier,
                viewModel: viewModels[indexPath.item]
            ) { cell, viewModel in
                cell.configure(with: viewModel)
            }
            
        case .topArtists(let viewModels):
            return dequeueConfiguredCell(
                collectionView: collectionView,
                indexPath: indexPath,
                cellType: TopArtistCollectionViewCell.self,
                identifier: TopArtistCollectionViewCell.identifier,
                viewModel: viewModels[indexPath.item]
            ) { cell, viewModel in
                cell.configure(with: viewModel)
            }
        
            
        case .topTracks(let viewModels):
            return dequeueConfiguredCell(
                collectionView: collectionView,
                indexPath: indexPath,
                cellType: TopTrackCollectionViewCell.self,
                identifier: TopTrackCollectionViewCell.identifier,
                viewModel: viewModels[indexPath.item]
            ) { cell, viewModel in
                cell.configure(with: viewModel)
            }
     
        case .savedAlbums(let viewModels):
            return dequeueConfiguredCell(
                collectionView: collectionView,
                indexPath: indexPath,
                cellType: SavedAlbumCollectionViewCell.self,
                identifier: SavedAlbumCollectionViewCell.identifier,
                viewModel: viewModels[indexPath.item]
            ) { cell, viewModel in
                cell.configure(with: viewModel)
            }
           
        case .recentPlaylist(let viewModels):
            return dequeueConfiguredCell(
                collectionView: collectionView,
                indexPath: indexPath,
                cellType: RecentCollectionViewCell.self,
                identifier: RecentCollectionViewCell.identifier,
                viewModel: viewModels[indexPath.item]
            ) { cell, viewModel in
                cell.configure(with: viewModel)
            }
            
        case .albumsByArtistsYouFollow(viewModels: let viewModels):
            return dequeueConfiguredCell(
                collectionView: collectionView,
                indexPath: indexPath,
                cellType: AlbumsByArtistYouFollowCollectionViewCell.self,
                identifier: AlbumsByArtistYouFollowCollectionViewCell.identifier,
                viewModel: viewModels[indexPath.item]
            ) { cell, viewModel in
                cell.configure(with: viewModel)
            }
            
        case .yourFavouriteArtist(let viewModels):
            return dequeueConfiguredCell(
                collectionView: collectionView,
                indexPath: indexPath,
                cellType: YourFavouriteArtistsCollectionViewCell.self,
                identifier: YourFavouriteArtistsCollectionViewCell.identifier,
                viewModel: viewModels[indexPath.item]
            ) { cell, viewModel in
                cell.configure(with: viewModel)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = filteredSections[indexPath.section]
        
        switch section {
        case .playlists:
            let selectedPlaylist = playlists[indexPath.row]
            if let selectedPlaylistID = selectedPlaylist.id {
                let playerListVC = PlayListViewController(playlistID: selectedPlaylistID)
                playerListVC.title = selectedPlaylist.name
                navigationController?.pushViewController(playerListVC, animated: true)
            }
            
            
        case .newReleases:
            let selectedNewRelease = newReleases[indexPath.row]
            if let selectedNewReleaseAlbumID = selectedNewRelease.id {
                let detailVC = AlbumDetailViewController(albumID: selectedNewReleaseAlbumID)
                navigationController?.pushViewController(detailVC, animated: true)
            }
            
            
        case .topArtists:
            let selectedArtist = topArtists[indexPath.row]
            if let selectedArtistID = selectedArtist.id {
                let topArtistVc = ArtistViewController(artistID: selectedArtistID)
                topArtistVc.title = selectedArtist.name
                navigationController?.pushViewController(topArtistVc, animated: true)
            }
            
            
        case .topTracks:
            let selectedTracks = topTracks[indexPath.row]
            if let selectedTracksID = selectedTracks.id {
                let trackDetailVC = TrackDetailViewController(trackID: selectedTracksID)
                trackDetailVC.title = selectedTracks.name
                navigationController?.pushViewController(trackDetailVC, animated: true)
            }
            
        case .savedAlbums:
            let selectedSavedAlbum = savedAlbums[indexPath.row]
            if let selectedSavedAlbumID = selectedSavedAlbum.id {
                let detailVC = AlbumDetailViewController(albumID: selectedSavedAlbumID)
                navigationController?.pushViewController(detailVC, animated: true)
            }
            
            
        case .yourFavouriteArtist:
            let selectedYourFavouriteArtist = yourFavouriteArtist[indexPath.row]
            if let selectedYOurFavouriteArtistID = selectedYourFavouriteArtist.id {
                let detailVC = ArtistViewController(artistID: selectedYOurFavouriteArtistID)
                navigationController?.pushViewController(detailVC, animated: true)
            }
            
            
            
        case .albumsByArtistsYouFollow:
            let selectedAlbumByArtist = albumsByArtistsYouFollow[indexPath.row]
            if let selectedAlbumByArtistID = selectedAlbumByArtist.id {
                let detailVC = AlbumDetailViewController(albumID: selectedAlbumByArtistID)
                navigationController?.pushViewController(detailVC, animated: true)
                
            }
            
        case .recentPlaylist(let viewModels):
                let selectedViewModel = viewModels[indexPath.row]
    
                guard let contextId = selectedViewModel.contextId else {
                    self.pressSpotyfyAlertThread(
                        title: "Error",
                        message: "Unable to determine the context for this track",
                        buttuonTitle: "OK"
                    )
                    return
                }
                
                switch selectedViewModel.objectType {
                case "album":
                    navigateToAlbum(with: contextId)
                case "playlist":
                    navigateToPlaylist(with: contextId)
                case "show":
                    navigateToShow(with: contextId)
                case "artist":
                    navigateToArtist(with: contextId)
                default:
                    self.pressSpotyfyAlertThread(
                        title: "Error",
                        message: "Unknown content type",
                        buttuonTitle: "OK"
                    )
                }
            default:
                break
            }
            
        }
    
    private func navigateToAlbum(with albumId: String) {
        print("Navigate to Album with ID: \(albumId)")
        // Push album detail view controller
    }

    private func navigateToPlaylist(with playlistUri: String) {
        print("Navigate to Playlist with URI: \(playlistUri)")
        // Push playlist detail view controller
    }

    private func navigateToShow(with showUri: String) {
        print("Navigate to Show with URI: \(showUri)")
        // Push show detail view controller
    }

    private func navigateToArtist(with artistId: String) {
        print("Navigate to Artist with ID: \(artistId)")
        // Push artist detail view controller
    }
    
    func navigateToDestination(for contextType: String, with identifier: String) {
        switch contextType {
        case "playlist":
            let playlistDetailVC = PlayListViewController(playlistID: identifier)
            playlistDetailVC.playlistID = identifier
            navigationController?.pushViewController(playlistDetailVC, animated: true)

        case "album":
            let albumDetailVC = AlbumDetailViewController(albumID: identifier)
            albumDetailVC.title = identifier
            navigationController?.pushViewController(albumDetailVC, animated: true)

        case "show":
            let showDetailVC = ShowDetailViewController(showID: identifier)
            showDetailVC.title = identifier
            navigationController?.pushViewController(showDetailVC, animated: true)

        case "artist":
            let artistDetailVC = ArtistViewController(artistID: identifier)
            artistDetailVC.title = identifier
            navigationController?.pushViewController(artistDetailVC, animated: true)

        default:
            print("Unknown context type")
        }
    }

        
    private func navigateToAlbumDetail(with album: Album) {
        if let albumID = album.id {
            let albumDetailVC = AlbumDetailViewController(albumID: albumID)
            navigationController?.pushViewController(albumDetailVC, animated: true)
        }
    }

    private func navigateToPlaylistDetail(with playlistID: String) {
        let playlistDetailVC = PlayListViewController(playlistID: playlistID)
        navigationController?.pushViewController(playlistDetailVC, animated: true)
    }

    private func navigateToTrackDetail(with trackID: String) {
        let trackDetailVC = TrackDetailViewController(trackID: trackID)
        navigationController?.pushViewController(trackDetailVC, animated: true)
    }
    
    private func navigateToShowDetail(with showID: String){
        let showDetailVC = ShowDetailViewController(showID: showID)
        navigationController?.pushViewController(showDetailVC, animated: true)
    }
    
    private func navigateToArtistDetail(with artistID: String){
        let artistDetailVC = ArtistViewController(artistID: artistID)
        navigationController?.pushViewController(artistDetailVC, animated: true)
    }

    
    func dequeueConfiguredCell<T: UICollectionViewCell, VM>(
        collectionView: UICollectionView,
        indexPath: IndexPath,
        cellType: T.Type,
        identifier: String,
        viewModel: VM,
        configure: (T, VM) -> Void
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: identifier,
            for: indexPath
        ) as? T else {
            return UICollectionViewCell()
        }
        configure(cell, viewModel)
        return cell
    }

}








