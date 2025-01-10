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
    
    // Custom initializer
    init(categoryId: String) {
        self.categoryId = categoryId
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
        title = "Category Playlists"
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
        SpotifyPlayer.shared.getCategoryDetails(for: categoryId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let playlists):
                self.playlists = playlists.items ?? []
                print(playlists)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                print("Failed to fetch category details: \(error.localizedDescription)")
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
