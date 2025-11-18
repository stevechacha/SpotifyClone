//
//  CategoryDetailsViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 10/01/2025.
//


import UIKit
import SDWebImage

class CategoryDetailsViewController: UIViewController {
    
    private var playlists: [PlaylistItem] = []
    private let categoryId: String
    private let categoryName: String?
    
    // Custom initializer
    init(categoryId: String, categoryName: String? = nil) {
        self.categoryId = categoryId
        self.categoryName = categoryName
        super.init(nibName: nil, bundle: nil)
    }
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width / 2 - 24, height: 200)
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CategoryPlaylistCollectionViewCell.self, forCellWithReuseIdentifier: CategoryPlaylistCollectionViewCell.identifier)
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = categoryName ?? "Category Playlists"
        view.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        fetchCategoryDetails()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    private func fetchCategoryDetails() {
        print("Fetching playlists for category ID: \(categoryId), name: \(categoryName ?? "unknown")")
        SpotifyPlayer.shared.getCategoryDetails(for: categoryId, categoryName: categoryName) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.playlists = response.playlists.items ?? []
                DispatchQueue.main.async {
                    if self.playlists.isEmpty {
                        self.showEmptyStateView(with: "No playlists available for this category", in: self.view)
                    } else {
                        self.collectionView.reloadData()
                    }
                }
            case .failure(let error):
                print("Failed to fetch category details for \(self.categoryName ?? self.categoryId): \(error.localizedDescription)")
                DispatchQueue.main.async {
                    if let apiError = error as? ApiError,
                       case .invalidResponse(let statusCode) = apiError,
                       statusCode == 404 {
                        self.showEmptyStateView(with: "This category doesn't have playlists available", in: self.view)
                    } else {
                        self.showEmptyStateView(with: "Unable to load playlists. Please try again later.", in: self.view)
                    }
                }
            }
        }
    }
}

extension CategoryDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryPlaylistCollectionViewCell.identifier, for: indexPath) as? CategoryPlaylistCollectionViewCell else {
            return UICollectionViewCell()
        }
        let playlist = playlists[indexPath.row]
        cell.configure(with: playlist)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let playlist = playlists[indexPath.row]
        print("Selected playlist: \(playlist.name)")
        // Navigate to playlist details (if needed)
    }
}
