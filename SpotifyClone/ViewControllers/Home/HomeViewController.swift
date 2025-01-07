//
//  ViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 04/12/2024.
//
import UIKit
import SwiftUI

enum BrowseSectionType {
    case playlists(viewModels: [PlaylistCellViewModel])
    case newReleases(viewModels: [NewReleasesCellViewModel])
    case followedArtistAlbums(viewModels: [FollowedArtistAlbumCellViewModel])
    case recentPlaylist(viewModels: [RecentPlaylistCellViewModel])
    case savedAlbums(viewModels: [SavedAlbumCellViewModel])
    case topArtists(viewModels: [TopArtistCellViewModel])
    case topTracks(viewModels: [TopTrackCellViewModel])
}

class HomeViewController: UIViewController {
    // MARK: - UI Components
    private let collectionView: UICollectionView = {
        let layout = HomeViewController.createLayout()
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private var sections = [BrowseSectionType]()
    private var filteredSections = [BrowseSectionType]()
    var playlists: [PlaylistItem] = []
    var newReleases: [Album] = []
    var savedAlbums: [Album] = []
    var topArtists: [TopItem] = []
    var topTracks: [TopItem] = []
    var followedArtistAlbums: [FollowedArtist] = []
    var recentPlaylist: [RecentlyPlayedItem] = []
    
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        configureCollectionView()
        fetchData()
    }
    
    func getRecentlyPlayed(){
        UserApiCaller.shared.getFollowedArtists { result in
            switch result {
            case .success(let response):
                print("response Followed Played \(response.count)")
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(spinner)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        spinner.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    
    private func configureCollectionView() {
        collectionView.register(PlaylistCollectionViewCell.self, forCellWithReuseIdentifier: PlaylistCollectionViewCell.identifier)
        collectionView.register(RecentCollectionViewCell.self, forCellWithReuseIdentifier: RecentCollectionViewCell.identifier)
        collectionView.register(FollowedArtistAlbumCollectionViewCell.self, forCellWithReuseIdentifier: FollowedArtistAlbumCollectionViewCell.identifier)
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
    
    // MARK: - API Calls
    private func fetchData() {
        spinner.startAnimating()
        collectionView.isHidden = true // Hide collection view while loading
        
        let group = DispatchGroup()
        
        group.enter()
        UserApiCaller.shared.getFollowedArtists { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.followedArtistAlbums = response
                    print("response Followed Artist \(response.count)")
                case .failure(let failure):
                    print(failure)
                }
                group.leave()
            }
           
        }
        
        group.enter()
        PlaylistApiCaller.shared.getRecentlyPlayed{ [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.recentPlaylist = response.items
                    print("response Recent Played \(response.items.count)")
                case .failure(let failure):
                    print(failure)
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
                    self?.playlists = response.items ?? []
                case .failure(let error):
                    print("Error Fetching User Playlist: \(error)")
                }
                group.leave()
            }
        }
        
        // Fetch New Releases
        group.enter()
        AlbumApiCaller.shared.getNewReleases { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.newReleases = response.albums.items
                case .failure(let error):
                    print("Failed to fetch new releases: \(error)")
                }
                group.leave()
            }
        }
        
        group.enter()
        AlbumApiCaller.shared.getUserSavedAlbums { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.savedAlbums = response.items.compactMap { $0.album }
                case .failure(let error):
                    print("Failed to fetch saved albums: \(error.localizedDescription)")
                }
                group.leave()
            }
        }
        
        // Fetch Top Artists
        group.enter()
        UserApiCaller.shared.getUserTopItems(type: "artists") { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.topArtists = response
                case .failure(let error):
                    print("Top Artist Error: \(error)")
                }
                group.leave()
            }
        }
        
        // Fetch Top Tracks
        group.enter()
        UserApiCaller.shared.getUserTopItems(type: "tracks") { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.topTracks = response
                    print("API Response: \(response)")
                    for track in response {
                        print("Track Name: \(track.name), Image URL: \(track.images?.first?.url ?? "nil")")
                    }
                case .failure(let error):
                    print("Top Tracks Error: \(error)")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.spinner.stopAnimating()
            self.collectionView.isHidden = false
            self.configureModels()
            self.filterSections(for: 0)
        }
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
        
        var recentPlaylistViewModels: [RecentPlaylistCellViewModel] = []
        var albumTracksDict: [String: [RecentPlaylistCellViewModel]] = [:]
        var playlistTracksDict: [String: [RecentPlaylistCellViewModel]] = [:]
        
        for item in recentPlaylist {
            guard let objectType = item.track.type else { continue }
            
            let viewModel = RecentPlaylistCellViewModel(
                name: item.track.name ?? "Unknown Track",
                artUrl: URL(string: item.track.album?.images?.first?.url ?? ""),
                numberOfTracks: 1,
                artistName: item.track.artists?.first?.name ?? "",
                objectType: item.track.artists?.first?.type ?? ""
            )
            
            // Group based on the source (album or playlist)
            if objectType == "album", let albumName = item.track.album?.name {
                albumTracksDict[albumName, default: []].append(viewModel)
            } else if objectType == "playlist", let playlistName = item.context?.type {
                playlistTracksDict[playlistName, default: []].append(viewModel)
            } else {
                // Standalone tracks or other types
                recentPlaylistViewModels.append(viewModel)
            }
        }
        
        // Combine album tracks into a single virtual album entry
        for (albumName, tracks) in albumTracksDict {
            let albumViewModel = RecentPlaylistCellViewModel(
                name: albumName,
                artUrl: tracks.first?.artUrl, // Use the first track's album art
                numberOfTracks: tracks.count,
                artistName: tracks.first?.artistName ?? "",
                objectType: tracks.first?.objectType ?? "" // Replace with logic to deduce the main artist
            )
            recentPlaylistViewModels.append(albumViewModel)
        }
        
        // Combine playlist tracks into their respective playlist entries
        for (playlistName, tracks) in playlistTracksDict {
            let playlistViewModel = RecentPlaylistCellViewModel(
                name: playlistName,
                artUrl: tracks.first?.artUrl, // Use the first track's playlist art
                numberOfTracks: tracks.count,
                artistName: tracks.first?.artistName ?? "",
                objectType: tracks.first?.objectType ?? "" // Replace with logic to deduce the main artist
            )
            recentPlaylistViewModels.append(playlistViewModel)
        }
        
        // Add the final view models to the section
        sections.append(.recentPlaylist(viewModels: recentPlaylistViewModels))
        
        // New Releases
        let follwedArtistAlbumsViewModels = followedArtistAlbums.map {
            FollowedArtistAlbumCellViewModel(
                name: $0.name,
               artUrl: URL(string: $0.images?.first?.url ?? ""),
               numberOfTracks: $0.popularity ?? 0,
               artistName: $0.genres?.joined(separator: "") ?? ""
           )
       }
        sections.append(.followedArtistAlbums(viewModels: follwedArtistAlbumsViewModels))
        
        
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
            print("Track: \(track.name), Image URL: \(imageUrl?.absoluteString ?? "nil")")
            
            let trackID = track.id ?? ""
            
            // Initialize the ViewModel with the available data
            var viewModel = TopTrackCellViewModel(
                id: track.id ?? "",
                name: track.name,
                artUrl: imageUrl
            )
            
            // Fetch additional data from API
            TrackApiCaller.shared.getTrack(trackID: trackID) { [weak self] result in
                switch result {
                case .success(let success):
                    // Assuming `success` contains the image URL
                    if let newImageUrlString = success.album?.images?.first?.url, let newImageUrl = URL(string: newImageUrlString) {
                        print("Updated Image URL for Track \(track.name): \(newImageUrlString)")
                        viewModel.artUrl = newImageUrl
                        
                        // Reload the UI for the specific track
                        DispatchQueue.main.async {
                            self?.reloadUIForTrack(trackID: trackID)
                        }
                    }
                case .failure(let error):
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
            case .playlists(let viewModels): return !viewModels.isEmpty
            case .newReleases(let viewModels): return !viewModels.isEmpty
            case .topArtists(let viewModels): return !viewModels.isEmpty
            case .topTracks(let viewModels): return !viewModels.isEmpty
            case .savedAlbums(let viewModels): return !viewModels.isEmpty
            case .recentPlaylist(let viewModels): return !viewModels.isEmpty
            case .followedArtistAlbums(let viewModels): return !viewModels.isEmpty
            }
        }
        collectionView.reloadData()
    }

    
    
    
    
    // MARK: - Compositional Layout
    static func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            // Define the item and group size (same as before)
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.3),
                heightDimension: .fractionalWidth(0.45)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(0.45)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
            
            // Add a header to the section
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(44)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]
            
            return section
        }
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
        case .playlists: headerTitle = ""
        case .newReleases: headerTitle = "New Releases"
        case .topArtists: headerTitle = "Top Artists"
        case .topTracks: headerTitle = "Top Tracks"
        case .savedAlbums: headerTitle = "Saved Albums"
        case .recentPlaylist: headerTitle = "Recently Played"
        case .followedArtistAlbums: headerTitle = "Albums for followed Artist"
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
        case .playlists(let viewModels): return viewModels.count
        case .newReleases(let viewModels): return viewModels.count
        case .topArtists(let viewModels): return viewModels.count
        case .topTracks(let viewModels): return viewModels.count
        case .savedAlbums(viewModels: let viewModels): return viewModels.count
        case .recentPlaylist(viewModels: let viewModels): return viewModels.count
        case .followedArtistAlbums(viewModels: let viewModels): return viewModels.count

            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let type = filteredSections[indexPath.section]
        switch type {
        case .playlists(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PlaylistCollectionViewCell.identifier,
                for: indexPath
            ) as? PlaylistCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: viewModels[indexPath.item])
            return cell
            
        case .newReleases(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: NewReleaseCollectionViewCell.identifier,
                for: indexPath
            ) as? NewReleaseCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: viewModels[indexPath.item])
            return cell
            
        case .topArtists(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TopArtistCollectionViewCell.identifier,
                for: indexPath
            ) as? TopArtistCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: viewModels[indexPath.item])
            return cell
            
        case .topTracks(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TopTrackCollectionViewCell.identifier,
                for: indexPath
            ) as? TopTrackCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: viewModels[indexPath.item])
            return cell
        case .savedAlbums(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SavedAlbumCollectionViewCell.identifier,
                for: indexPath
            ) as? SavedAlbumCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: viewModels[indexPath.item])
            return cell
        case .recentPlaylist(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RecentCollectionViewCell.identifier,
                for: indexPath
            ) as? RecentCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: viewModels[indexPath.item])
            return cell
        case .followedArtistAlbums(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FollowedArtistAlbumCollectionViewCell.identifier,
                for: indexPath
            ) as? FollowedArtistAlbumCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: viewModels[indexPath.item])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = filteredSections[indexPath.section]
        
        switch section {
        case .playlists:
            let selectedPlaylist = playlists[indexPath.row]
            let playerListVC = PlayerListViewController(playlist: selectedPlaylist)
            playerListVC.title = selectedPlaylist.name
            navigationController?.pushViewController(playerListVC, animated: true)
            
        case .newReleases:
            let selectedNewRelease = newReleases[indexPath.row]
            let detailVC = AlbumDetailViewController(album: selectedNewRelease)
            navigationController?.pushViewController(detailVC, animated: true)
            
        case .topArtists:
            let selectedArtist = topArtists[indexPath.row]
            let topArtistVc = ArtistViewController(topArtist: selectedArtist)
            topArtistVc.title = selectedArtist.name
            navigationController?.pushViewController(topArtistVc, animated: true)
            
        case .topTracks:
            let selectedTrack = topTracks[indexPath.row]
            
        case .savedAlbums:
            let selectedAlbum = savedAlbums[indexPath.row]
            let detailVC = AlbumDetailViewController(album: selectedAlbum)
            navigationController?.pushViewController(detailVC, animated: true)
       
        case .recentPlaylist:
            let recentPlaylist = recentPlaylist[indexPath.row]
            
        case .followedArtistAlbums:
            let selectedAlbum = followedArtistAlbums[indexPath.row]
        }
    }
}







