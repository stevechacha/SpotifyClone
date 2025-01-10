//
//  CategoriesViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 09/01/2025.
//

import UIKit

import UIKit

class CategoriesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    private var categories = [SpotifyCategory]()
    private var collectionView: UICollectionView!
    private var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Categories"
        view.backgroundColor = .systemBackground

        // Setup Search Bar
        searchBar = UISearchBar()
        searchBar.placeholder = "What do you want to listen to?"
        searchBar.delegate = self
        navigationItem.titleView = searchBar

        // Setup Collection View Layout
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 150, height: 200)
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        // Initialize Collection View
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self

        // Add Collection View to View
        view.addSubview(collectionView)
        collectionView.frame = view.bounds

        // Fetch Categories
        SpotifyPlayer.shared.fetchCategories { [weak self] categories in
            DispatchQueue.main.async {
                self?.categories = categories
                self?.collectionView.reloadData()
            }
        }
    }

    // MARK: - UISearchBarDelegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // Navigate to SearchViewController when search bar is tapped
        let searchVC = SearchViewController()
        navigationController?.pushViewController(searchVC, animated: true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Navigate to SearchViewController when the search button is tapped
        let searchVC = SearchViewController()
        navigationController?.pushViewController(searchVC, animated: true)
        searchBar.resignFirstResponder() // Dismiss keyboard
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as! CategoryCollectionViewCell
        cell.configure(with: categories[indexPath.item])
        return cell
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = categories[indexPath.row]
        let detailsVC = CategoryDetailsViewController(categoryId: category.id)
        navigationController?.pushViewController(detailsVC, animated: true)
    }
}
