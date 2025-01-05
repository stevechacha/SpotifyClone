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
    case savedAlbums(viewModels: [AlbumCellViewModel])
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
        collectionView.register(AlbumCollectionViewCell.self, forCellWithReuseIdentifier: AlbumCollectionViewCell.identifier)
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
        AlbumApiCaller.shared.getSavedAlbums { [weak self] result in
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
        
        
        // Saved Albums
        let savedAlbumViewModels = newReleases.map {
            AlbumCellViewModel(
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
        let trackViewModels = topTracks.map {
            let imageUrl = URL(string: $0.images?.first?.url ?? "")
            print("Track: \($0.name), Image URL: \(imageUrl?.absoluteString ?? "nil")")
            return TopTrackCellViewModel(
                name: $0.name,
                artUrl: imageUrl
            )
        }
        sections.append(.topTracks(viewModels: trackViewModels))
    }
    
    // MARK: - Filtering
    private func filterSections(for index: Int) {
        filteredSections = sections // Show all sections for now
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
    
    func collectionView(_ collectionView: UICollectionView,viewForSupplementaryElementOfKind kind: String,at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
        
        let section = filteredSections[indexPath.section]
        let headerTitle: String
        switch section {
        case .playlists: headerTitle = "Playlists"
        case .newReleases: headerTitle = "New Releases"
        case .topArtists: headerTitle = "Top Artists"
        case .topTracks: headerTitle = "Top Tracks"
        case .savedAlbums: headerTitle = "Saved Albums"
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
                withReuseIdentifier: AlbumCollectionViewCell.identifier,
                for: indexPath
            ) as? AlbumCollectionViewCell else {
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
            
        case .topTracks:
            let selectedTrack = topTracks[indexPath.row]
            
        case .savedAlbums:
            let selectedAlbum = savedAlbums[indexPath.row]
            let detailVC = AlbumDetailViewController(album: selectedAlbum)
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    

    
}







