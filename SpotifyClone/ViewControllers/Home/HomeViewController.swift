//
//  ViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 04/12/2024.
//
import UIKit
import SwiftUI

enum BrowseSectionType {
    case newReleases(viewModels: [NewReleasesCellViewModel])
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
    var newReleases: SpotifyNewReleasesAlbumsResponse?

    
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
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureCollectionView() {
        collectionView.register(NewReleaseCollectionViewCell.self, forCellWithReuseIdentifier: NewReleaseCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
    }
    
    // MARK: - Fetch Data
    private func fetchData() {
        spinner.startAnimating()
        
        let group = DispatchGroup()
        group.enter()
        
        
        // Fetching data
        AlbumApiCaller.shared.getNewReleases { result in
            defer { group.leave() }
            switch result {
            case .success(let response):
                self.newReleases = response
            case .failure(let error):
                print("Failed to fetch new releases: \(error)")
            }
        }
        
        group.notify(queue: .main) {
            self.spinner.stopAnimating()
            guard let newAlbums = self.newReleases?.albums.items else {
                print("Failed to fetch all required data.")
                return
            }
            self.configureModels(newAlbums: newAlbums)
            self.filterSections(for: 0) // Ensure filteredSections is populated
        }
    }
    
    private func configureModels(newAlbums: [Album]) {
        let viewModels = newAlbums.compactMap {
            NewReleasesCellViewModel(
                name: $0.name ?? "",
                artUrl: URL(string: $0.images?.first?.url ?? ""),
                numberOfTracks: $0.totalTracks ?? 0,
                artistName: $0.artists?.first?.name ?? "Unknown Artist"
            )
        }
        sections.append(.newReleases(viewModels: viewModels))
    }
    
    // MARK: - Filtering
    private func filterSections(for index: Int) {
        switch index {
        case 0: // All
            filteredSections = sections
        case 1: // Music
            filteredSections = sections.filter {
                switch $0 {
                case .newReleases: return true
                }
            }
        case 2: // Podcasts
            filteredSections = [] // No podcasts yet
        default:
            break
        }
        collectionView.reloadData()
    }
    
    // MARK: - Compositional Layout
    static func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            switch sectionIndex {
            case 0:
                // Grid Layout with 2 Columns
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.5),
                    heightDimension: .fractionalWidth(0.75) // Aspect ratio 2:3
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalWidth(0.75)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item]) // 2 items per row
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
                return section
                
            default:
                return nil
            }
        }
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let type = filteredSections[section]
        switch type {
        case .newReleases(let viewModels):
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
            ) as? NewReleaseCollectionViewCell else {
                return UICollectionViewCell()
            }
            let viewModel = viewModels[indexPath.item]
            cell.configure(with: viewModel)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let type = filteredSections[indexPath.section]
        switch type {
        case .newReleases(let viewModels):
            let selectedViewModel = viewModels[indexPath.item]
            
            // Create the corresponding `Album` object
            guard let selectedAlbum = newReleases?.albums.items.first(where: { album in
                album.name == selectedViewModel.name // You can use other properties to match if needed
            }) else {
                return
            }
            
            // Now create the AlbumDetailViewController and pass the selectedAlbum's id
            let albumDetailVC = AlbumDetailViewController(album: selectedAlbum)
            navigationController?.pushViewController(albumDetailVC, animated: true)
        }
    }
}






