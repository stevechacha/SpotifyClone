//
//  ViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 04/12/2024.
//

import UIKit

enum BrowseSectionType {
    case newReleases
    case featuredPlaylist
    case recommendedTracks
}

class HomeViewController: UIViewController {
    
    private var shows: [UsersSavedShowsItems] = []
    
    private let collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
            return HomeViewController.createSectionLayout(section: sectionIndex)
        }
    )
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Home"
        view.backgroundColor = .systemBackground
        
        setupCollectionView()
        //        getData()
        //        getAlbum()
        //        fetchShows()
        //        getArtist()
        //        fetchArtistsDetails()
        //        getArtistsTopTracks()
        //        getArtistsRelatedArtist()
        //        getAlbums()
        //        getNewReleases()
        //        getChapters()
        //        getTracks()
        //        getAvailableGenreSeeds()
        //        getPlaylists()
        //        fetchPlaylistsAndTracks()
    }
    
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    // MARK: - CollectionView Setup
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ShowCollectionViewCell.self, forCellWithReuseIdentifier: ShowCollectionViewCell.identifier)
        view.addSubview(collectionView)
    }
    
    // MARK: - Section Layout
    private static func createSectionLayout(section: Int) -> NSCollectionLayoutSection {
        // Item
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        // Group
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(120)
            ),
            subitems: [item]
        )
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        return section
    }
    
    // MARK: - Fetch Shows
    private func fetchShows() {
        ChapterApiCaller.shared.getUserSavedShows { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.shows = response.items!
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print("Failed to fetch shows: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    
    func getData(){
        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()
        PlaylistApiCaller.shared.getFeaturedPlaylists { result in
            defer {
                group.leave()
            }
            switch result {
            case .success(let model): break
            case .failure(let error):
                return print("error Featured \(error.localizedDescription)")
            }
        }
        
        RecommendedApiCaller.shared.getAvailableGenreSeeds { result in
            switch result {
            case .success( let model):
                let genre = model.genres
                var seeds = Set<String>()
                while seeds.count < 5 {
                    if let random = genre.randomElement(){
                        seeds.insert(random)
                    }
                }
                RecommendedApiCaller.shared.getRecommedations(genres: seeds){ recommendedResult in
                    defer {
                        group.leave()
                    }
                    switch recommendedResult {
                    case .success( let model): break
                    case .failure(let error): break
                    }
                    
                }
            case .failure(let error): break
            }
        }
        
        group.notify(queue: .main){
            
        }
    }
    
    
    // MARK: - Helper Methods
    private func showLoadingIndicator(_ show: Bool) {
        // Replace with actual loading indicator implementation
        if show {
            print("Loading indicator started.")
        } else {
            print("Loading indicator stopped.")
        }
    }
    
    private func showError(_ message: String) {
        // Replace with your preferred method for showing errors (e.g., alert or toast)
        print("Error: \(message)")
    }
    
    private func updateUI(with recommendations: RecommendationsResponse) {
        // Add your code to update the UI with fetched recommendations
        print("Updating UI with recommendations: \(recommendations)")
    }
}
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ShowCollectionViewCell.identifier,
            for: indexPath
        ) as? ShowCollectionViewCell else {
            return UICollectionViewCell()
        }
        let show = shows[indexPath.row]
        cell.configure(with: show)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedShow = shows[indexPath.row]
        print("Selected show: \(String(describing: selectedShow.show.name))")
        // Navigate to a detailed view controller if needed
    }
}

