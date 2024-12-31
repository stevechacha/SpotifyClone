//
//  ViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 04/12/2024.
//

import UIKit


import UIKit

enum BrowseSectionType {
    case newReleases(viewModels: [NewReleasesCellViewModel])
    case featuredPlaylists(viewModels: [NewReleasesCellViewModel])
    case recommendedTracks(viewModels: [NewReleasesCellViewModel])
}

class HomeViewController: UIViewController {
    // MARK: - UI Components
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["All", "Music", "Podcasts"])
        control.selectedSegmentIndex = 0
        control.backgroundColor = .black
        control.selectedSegmentTintColor = .green
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        control.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        return control
    }()
    
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
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        configureCollectionView()
        fetchData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(segmentedControl)
        view.addSubview(collectionView)
        view.addSubview(spinner)
        
        segmentedControl.addTarget(self, action: #selector(didChangeSegment), for: .valueChanged)
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureCollectionView() {
        collectionView.register(NewReleaseCollectionViewCell.self, forCellWithReuseIdentifier: NewReleaseCollectionViewCell.identifier)
        collectionView.register(FeaturedPlaylistCollectionViewCell.self, forCellWithReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier)
        collectionView.register(RecommendedCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedCollectionViewCell.identifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
    }
    
    // MARK: - Fetch Data
    private func fetchData() {
        spinner.startAnimating()
        
        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()
        
        var featuredPlaylists: FeaturedPlayListResponse?
        var newReleases: SpotifyNewReleasesAlbumsResponse?
        var recommendations: RecommendationsResponse?
        
        AlbumApiCaller.shared.getNewReleases { result in
            defer { group.leave() }
            switch result {
            case .success(let response):
                newReleases = response
            case .failure(let error):
                print("Failed to fetch new releases: \(error)")
            }
        }
        
        PlaylistApiCaller.shared.getFeaturedPlaylists { result in
            defer { group.leave() }
            switch result {
            case .success(let response):
                featuredPlaylists = response
            case .failure(let error):
                print("Failed to fetch featured playlists: \(error)")
            }
        }
        
        RecommendedApiCaller.shared.getRecommendedGenre { result in
            switch result {
            case .success(let response):
                let genres = response.genres
                var seeds = Set<String>()
                while seeds.count < 5, let random = genres.randomElement() {
                    seeds.insert(random)
                }
                
                RecommendedApiCaller.shared.getRecommedations(genres: seeds) { result in
                    defer { group.leave() }
                    switch result {
                    case .success(let response):
                        recommendations = response
                    case .failure(let error):
                        print("Failed to fetch recommendations: \(error)")
                    }
                }
            case .failure(let error):
                print("Failed to fetch genres: \(error)")
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.spinner.stopAnimating()
            guard let newAlbums = newReleases?.albums.items,
                  let playlists = featuredPlaylists?.playlists?.items,
                  let tracks = recommendations?.tracks else {
                print("Failed to fetch all required data.")
                return
            }
            self.configureModels(newAlbums: newAlbums, playlists: playlists, tracks: tracks)
            self.filterSections(for: self.segmentedControl.selectedSegmentIndex)
        }
    }
    
    private func configureModels(newAlbums: [Album], playlists: [PlaylistItem], tracks: [RecommendAudioTracks]) {
        sections.append(.newReleases(viewModels: newAlbums.compactMap {
            NewReleasesCellViewModel(
                name: $0.name ?? "",
                artUrl: URL(string: $0.images?.first?.url ?? ""),
                numberOfTracks: $0.totalTracks ?? 0,
                artistName: $0.artists?.first?.name ?? "Unknown Artist"
            )
        }))
        
        sections.append(.featuredPlaylists(viewModels: playlists.compactMap {
            NewReleasesCellViewModel(
                name: $0.name,
                artUrl: URL(string: $0.images?.first?.url ?? ""),
                numberOfTracks: 0,
                artistName: $0.owner?.displayName ?? ""
            )
        }))
        
        sections.append(.recommendedTracks(viewModels: tracks.compactMap {
            NewReleasesCellViewModel(
                name: $0.name ?? "",
                artUrl: URL(string: $0.album?.images?.first?.url ?? ""),
                numberOfTracks: $0.album?.totalTracks ?? 0,
                artistName: $0.artists?.first?.name ?? "Unknown Artist"
            )
        }))
    }
    
    // MARK: - Filtering
    private func filterSections(for index: Int) {
        switch index {
        case 0: // All
            filteredSections = sections
        case 1: // Music
            filteredSections = sections.filter {
                switch $0 {
                case .newReleases, .recommendedTracks: return true
                default: return false
                }
            }
        case 2: // Podcasts
            filteredSections = sections.filter {
                switch $0 {
                case .featuredPlaylists: return true
                default: return false
                }
            }
        default:
            break
        }
        collectionView.reloadData()
    }
    
    @objc private func didChangeSegment(_ sender: UISegmentedControl) {
        filterSections(for: sender.selectedSegmentIndex)
    }
    
    // MARK: - Compositional Layout
    static func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            switch sectionIndex {
            case 0:
                // Grid Layout for New Releases
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(180))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(200))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
                return section
                
            case 1, 2:
                // Horizontal Layout for Playlists and Recommendations
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: .absolute(180))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: .absolute(180))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPaging
                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
                return section
                
            default:
                return nil
            }
        }
    }
}

// MARK: - CollectionView Delegate & DataSource
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let type = filteredSections[section]
        switch type {
        case .newReleases(let viewModels),
             .featuredPlaylists(let viewModels),
             .recommendedTracks(let viewModels):
            return viewModels.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let type = filteredSections[indexPath.section]
        switch type {
        case .newReleases(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: NewReleaseCollectionViewCell.identifier,
                for: indexPath
            ) as? NewReleaseCollectionViewCell else { return UICollectionViewCell() }
            cell.backgroundColor = .green
            let viewModel = viewModels[indexPath.item]
            return cell
            
        case .featuredPlaylists(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier,
                for: indexPath
            ) as? FeaturedPlaylistCollectionViewCell else { return UICollectionViewCell() }
            let viewModel = viewModels[indexPath.item]
            cell.backgroundColor = .red

            return cell
            
        case .recommendedTracks(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RecommendedCollectionViewCell.identifier,
                for: indexPath
            ) as? RecommendedCollectionViewCell else { return UICollectionViewCell() }
            
            let viewModel = viewModels[indexPath.item]
            return cell
        }
    }
}






class GridCell: UICollectionViewCell {
    static let identifier = "GridCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .darkGray
        contentView.layer.cornerRadius = 8
        contentView.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String) {
        titleLabel.text = title
    }
}

class HorizontalCell: UICollectionViewCell {
    static let identifier = "HorizontalCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemGreen
        contentView.layer.cornerRadius = 8
        contentView.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String) {
        titleLabel.text = title
    }
}

