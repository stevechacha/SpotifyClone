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
    private let collectionView: UICollectionView = {
        let layout = UIHelper.createLayout()
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
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

//        // Fetch Top Tracks
//        group.enter()
//        UserApiCaller.shared.getUserTopItems(type: "tracks") { [weak self] result in
//            defer { group.leave() }
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let response):
//                    self?.topTracks = response
//                case .failure(let error):
//                    self?.pressSpotyfyAlertThread(
//                        title: "Top User Tracks Error",
//                        message: error.localizedDescription,
//                        buttuonTitle: "OK"
//                    )
//                }
//            }
//        }

        group.notify(queue: .main) {
            self.activityIndicator.stopAnimating()
            self.collectionView.isHidden = false
            self.configureModels()
            self.configureRecently()
            self.filterSections(for: 0)
        }
    }
    
   
    private func configureRecently() {
        var recentPlaylistViewModels: [RecentPlaylistCellViewModel] = []
        
        for item in recentPlaylist {
            guard let track = item.track else { continue }
            guard let name = track.name, let objectType = track.type else { continue }
            
            let contextId: String?
            switch objectType {
            case "album":
                contextId = track.album?.id
            case "playlist", "show":
                contextId = item.context?.uri
            case "artist":
                contextId = track.artists?.first?.id
            default:
                contextId = nil
            }
            
            let viewModel = RecentPlaylistCellViewModel(
                name: name,
                artUrl: URL(string: track.album?.images?.first?.url ?? ""),
                numberOfTracks: 1,
                artistName: track.artists?.first?.name ?? "Unknown Artist",
                objectType: objectType,
                contextId: contextId
            )
            
            recentPlaylistViewModels.append(viewModel)
        }
        
        // Add to your sections
        sections.append(.recentPlaylist(viewModels: recentPlaylistViewModels))
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
            
        case .albumsByArtistsYouFollow(viewModels: let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AlbumsByArtistYouFollowCollectionViewCell.identifier,
                for: indexPath
            ) as? AlbumsByArtistYouFollowCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: viewModels[indexPath.item])
            return cell
        case .yourFavouriteArtist(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: YourFavouriteArtistsCollectionViewCell.identifier,
                for: indexPath
            ) as? YourFavouriteArtistsCollectionViewCell else {
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

}








