//
//  ArtistViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 28/12/2024.
//

import UIKit

class ArtistViewController: UIViewController {
    
    private let topArtistID: String
    private var topTracks: [Track] = []
    private var albums: [Album] = []
    private var relatedArtists: [RelatedArtist] = []
    private var headerView: UIView!
    private var segmentedControl: UISegmentedControl!
    private var tableView: UITableView!
    private var artistName: String = "Artist" {
           didSet {
               self.title = artistName
           }
       }

    
    // Loading indicator
    private var activityIndicator: UIActivityIndicatorView!

    // MARK: - Initializer
    init(topArtistID: String) {
        self.topArtistID = topArtistID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupHeaderView()
        setupSegmentedControl()
        setupTableView()
        setupLoadingIndicator()
        
        fetchTopTracks()
        fetchAlbums()
        fetchRelatedArtists()
    }
    
    // MARK: - Setup UI
    private func setupHeaderView() {
        headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        // Artist Image
        let artistImageView = UIImageView()
        artistImageView.contentMode = .scaleAspectFill
        artistImageView.clipsToBounds = true
        artistImageView.layer.cornerRadius = 10
        artistImageView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(artistImageView)
        
        // Artist Name
        let nameLabel = UILabel()
        nameLabel.font = .boldSystemFont(ofSize: 24)
        nameLabel.text = "Loading..."
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(nameLabel)
        
        // Artist Genres and Followers
        let detailsLabel = UILabel()
        detailsLabel.font = .systemFont(ofSize: 16)
        detailsLabel.numberOfLines = 2
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(detailsLabel)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 120),
            
            artistImageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 10),
            artistImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10),
            artistImageView.widthAnchor.constraint(equalToConstant: 100),
            artistImageView.heightAnchor.constraint(equalToConstant: 100),
            
            nameLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: artistImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -10),
            
            detailsLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            detailsLabel.leadingAnchor.constraint(equalTo: artistImageView.trailingAnchor, constant: 10),
            detailsLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -10)
        ])
        
        // Fetch artist details for genres, followers, and name
        ArtistApiCaller.shared.getArtistDetails(artistID: topArtistID) { [weak self] result in
            DispatchQueue.main.async {
                self?.stopLoadingIndicator()  // Stop loading once data is fetched
            }
            
            switch result {
            case .success(let details):
                DispatchQueue.main.async {
                    nameLabel.text = details.name // Set artist name here
                    let genres = details.genres?.joined(separator: ", ").capitalized ?? "Unknown Genres"
                    let followers = details.followers?.total ?? 0
                    detailsLabel.text = "Genres: \(genres)\nFollowers: \(followers)"
                    
                    if let imageUrl = details.images?.first?.url, let url = URL(string: imageUrl) {
                        artistImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "person"))
                    }
                }
            case .failure(let error):
                print("Error fetching artist details: \(error)")
            }
        }
    }


    
    private func setupSegmentedControl() {
        segmentedControl = UISegmentedControl(items: ["Top Tracks", "Albums", "Related Artists"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 10),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            segmentedControl.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupTableView() {
        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

        ])
    }
    
    // MARK: - Setup Loading Indicator
    private func setupLoadingIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    // MARK: - Show/Hide Loading Indicator
    private func startLoadingIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
    }
    
    private func stopLoadingIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
    }
    
    //MARK: - Fetch Artist Details
        private func fetchArtistDetails() {
            ArtistApiCaller.shared.getArtistDetails(artistID: topArtistID) { [weak self] result in
                switch result {
                case .success(let details):
                    DispatchQueue.main.async {
                        self?.artistName = details.name
                    }
                case .failure(let error):
                    print("Error fetching artist details: \(error)")
                }
            }
        }

        // MARK: - Fetch Data
        private func fetchTopTracks() {
            ArtistApiCaller.shared.getArtistsTopTracks(for: topArtistID) { [weak self] result in
                switch result {
                case .success(let tracksResponse):
                    self?.topTracks = tracksResponse.tracks
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                        self?.stopLoadingIndicator()  // Stop loading once data is fetched

                    }
                case .failure(let error):
                    print("Error fetching top tracks: \(error)")
                }
            }
        }

        private func fetchAlbums() {
            ArtistApiCaller.shared.getArtistAlbums(artistID: topArtistID) { [weak self] result in
                switch result {
                case .success(let albumsResponse):
                    self?.albums = albumsResponse.items
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                        self?.stopLoadingIndicator()  // Stop loading once data is fetched

                    }
                case .failure(let error):
                    print("Error fetching albums: \(error)")
                }
            }
        }

        private func fetchRelatedArtists() {
            ArtistApiCaller.shared.getRelatedArtists(artistID: topArtistID) { [weak self] result in
                switch result {
                case .success(let artists):
                    self?.relatedArtists = artists.artists ?? []
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                        self?.stopLoadingIndicator()  // Stop loading once data is fetched

                    }
                case .failure(let error):
                    print("Error fetching related artists: \(error)")
                }
            }
        }

    // MARK: - Segmented Control Action
    @objc private func segmentChanged() {
        tableView.reloadData()
    }
}

// MARK: - TableView Data Source & Delegate
extension ArtistViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentedControl.selectedSegmentIndex {
        case 0: return topTracks.count
        case 1: return albums.count
        case 2: return relatedArtists.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // Clear the cell
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        // Image View
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(imageView)
        
        // Label
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(label)
        
        // Stack View Layout
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10),
            imageView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 50),
            imageView.heightAnchor.constraint(equalToConstant: 50),
            
            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -10),
            label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
        ])
        
        switch segmentedControl.selectedSegmentIndex {
        case 0: // Top Tracks
            label.text = topTracks[indexPath.row].name
            if let imageUrl = topTracks[indexPath.row].album?.images?.first?.url {
                imageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(systemName: "photo"))
            }
        case 1: // Albums
            label.text = albums[indexPath.row].name
            if let imageUrl = albums[indexPath.row].images?.first?.url {
                imageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(systemName: "photo"))
            }
        case 2: // Related Artists
            label.text = relatedArtists[indexPath.row].name
            if let imageUrl = relatedArtists[indexPath.row].images?.first?.url {
                imageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(systemName: "photo"))
            }
        default:
            break
        }
        
        return cell
    }
    
    // Add space between rows by increasing row height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50 // Adjust this value to increase or decrease the space between rows
    }
}
