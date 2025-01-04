//
//  GenreGridViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 04/01/2025.
//


import UIKit


class GenreGridViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private var collectionView: UICollectionView!
    private var genres: [String] = [] // Array to store unique genres
    private var artistsByGenre: [String: [TopItem]] = [:] // Dictionary to map genres to artists
    private var searchBar: UISearchBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupSearchBar()
        setupCollectionView()
        fetchData()
        fetchGenres()
    }
    
    
    private func setupSearchBar() {
        searchBar = UISearchBar()
        searchBar.placeholder = "What do you want to listen to?"
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            searchBar.heightAnchor.constraint(equalToConstant: 50) // Ensure the height is defined
        ])
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (view.frame.size.width / 2) - 15, height: 90)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(GenreCell.self, forCellWithReuseIdentifier: "GenreCell")
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10), // Start below the search bar
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    
    // MARK: - Fetch Genres
    private func fetchGenres() {
        print("Fetching user top items...")
        
        // Fetch top artists and categorize them by genre
        UserApiCaller.shared.getUserTopItems(type: "artists") { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    print("Fetched items count: \(items.count)") // Log number of artists
                    self?.processArtistsByGenre(artists: items)
                case .failure(let error):
                    print("Failed to fetch top items: \(error)")
                }
            }
        }
    }
    
    private func fetchData() {
        // Populate genres from artistsByGenre
        genres = Array(artistsByGenre.keys)
        collectionView.reloadData()
    }
    
    // Process the artists and categorize them by genre
    private func processArtistsByGenre(artists: [TopItem]) {
        artistsByGenre.removeAll()
        
        for artist in artists {
            guard let genres = artist.genres else { continue }
            for genre in genres {
                if artistsByGenre[genre] != nil {
                    artistsByGenre[genre]?.append(artist)
                } else {
                    artistsByGenre[genre] = [artist]
                }
            }
        }
        
        genres = Array(artistsByGenre.keys) // Populate the genres array
        print("Genres found: \(genres)") // Log genres for debugging
        collectionView.reloadData()
    }
    
    private let colors: [UIColor] = [
        .systemPink, .systemBlue, .systemGreen, .systemPurple,
        .systemOrange, .systemTeal, .systemYellow, .systemRed,
        .systemIndigo, .systemBrown, .cyan, .magenta
    ]
    
    
    // MARK: - Collection View Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Number of genres: \(genres.count)") // Log the number of genres
        return genres.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GenreCell", for: indexPath) as! GenreCell
        let genre = genres[indexPath.item]
        cell.configure(with: genre, artistCount: artistsByGenre[genre]?.count ?? 0)
        
        // Assign a color from the array based on the index
        let color = colors[indexPath.item % colors.count]
        cell.backgroundColor = color
        
        return cell
    }
    
    private func randomColor() -> UIColor {
        return UIColor(
            red: CGFloat.random(in: 0...1),
            green: CGFloat.random(in: 0...1),
            blue: CGFloat.random(in: 0...1),
            alpha: 1.0
        )
    }
    
    
    // MARK: - Handle Genre Selection
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedGenre = genres[indexPath.item]
        print("Selected genre: \(selectedGenre)") // Log selected genre
        
        let artists = artistsByGenre[selectedGenre] ?? []
        let artistListVC = ArtistsByGenreViewController()
        artistListVC.genre = selectedGenre
        artistListVC.artists = artists
        navigationController?.pushViewController(artistListVC, animated: true)
    }
    
}

extension GenreGridViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        // Navigate to HomeSearchViewController
        let homeSearchVC = HomeSearchViewController()
        navigationController?.pushViewController(homeSearchVC, animated: true)
        return false // Prevents the keyboard from appearing
    }
}


