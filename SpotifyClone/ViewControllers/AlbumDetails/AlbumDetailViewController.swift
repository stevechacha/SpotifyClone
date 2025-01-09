//
//  AlbumDetailViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 29/12/2024.
//


import UIKit
import SDWebImage

class AlbumDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
//    private var album: Album
    private var albumID: String
    private var tracks: [Track] = []
    
    
   
    // UI Components
    private let albumImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    // Loading Indicator
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // Empty State Label
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No tracks available"
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.isHidden = true
        return label
    }()

    
    private let albumNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private let artistLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.textColor = .tertiaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(AlbumTrackTableViewCell.self, forCellReuseIdentifier: AlbumTrackTableViewCell.identifier)
        return tableView
    }()
    
    // MARK: - Init
    init(albumID: String) {
        self.albumID = albumID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    var titles : String

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        
        AlbumApiCaller.shared.getAllAlbumTracks(albumID: albumID) { result in
            switch result {
            case .success(let success):
                self.title = success.first?.name
            case .failure(let failure):
                print(failure)
            }
        }
//        title = album.name ?? "Album Details"
        
        setupUI()
        fetchTracks()
    }
    
    private func setupUI() {
        // Add UI elements to the view
        view.addSubview(albumImageView)
        view.addSubview(albumNameLabel)
        view.addSubview(artistLabel)
        view.addSubview(releaseDateLabel)
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyStateLabel)

        tableView.dataSource = self
        tableView.delegate = self

        // Enable Auto Layout
        albumImageView.translatesAutoresizingMaskIntoConstraints = false
        albumNameLabel.translatesAutoresizingMaskIntoConstraints = false
        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        releaseDateLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false

        // Add Auto Layout constraints
        NSLayoutConstraint.activate([
            // Album Image View
            albumImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            albumImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            albumImageView.widthAnchor.constraint(equalToConstant: 150),
            albumImageView.heightAnchor.constraint(equalToConstant: 150),

            // Album Name Label
            albumNameLabel.topAnchor.constraint(equalTo: albumImageView.bottomAnchor, constant: 8),
            albumNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            albumNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // Artist Label
            artistLabel.topAnchor.constraint(equalTo: albumNameLabel.bottomAnchor, constant: 4),
            artistLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            artistLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // Release Date Label
            releaseDateLabel.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 4),
            releaseDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            releaseDateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // TableView
            tableView.topAnchor.constraint(equalTo: releaseDateLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            // Loading Indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            // Empty State Label
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        AlbumApiCaller.shared.getAlbumDetails(albumID: albumID) { results in
            switch results {
            case .success(let album):
                // Configure UI elements
                self.albumNameLabel.text = album.name ?? "Unknown Album"
                self.artistLabel.text = album.artists?.map { $0.name ?? "" }.joined(separator: ", ") ?? "Unknown Artist"
                self.releaseDateLabel.text = "Released: \(album.releaseDate ?? "Unknown Date")"
                // Load album image using SDWebImage
                if let imageUrlString = album.images?.first?.url, let imageUrl = URL(string: imageUrlString) {
                    self.albumImageView.sd_setImage(with: imageUrl, completed: nil)
                }
            case .failure(let failure):
                print(failure)
            }
            
        }

//        // Configure UI elements
//        albumNameLabel.text = album.name ?? "Unknown Album"
//        artistLabel.text = album.artists?.map { $0.name ?? "" }.joined(separator: ", ") ?? "Unknown Artist"
//        releaseDateLabel.text = "Released: \(album.releaseDate ?? "Unknown Date")"
//
//        // Load album image using SDWebImage
//        if let imageUrlString = album.images?.first?.url, let imageUrl = URL(string: imageUrlString) {
//            albumImageView.sd_setImage(with: imageUrl, completed: nil)
//        }
    }

    
    private func fetchTracks() {
//        guard let albumID = album.id else {
//            print("Album ID is missing.")
//            return
//        }
//        
        // Show loading indicator and hide tableView
        loadingIndicator.startAnimating()
        tableView.isHidden = true
        emptyStateLabel.isHidden = true

        // Clear old tracks before fetching new ones
        self.tracks.removeAll()
        self.tableView.reloadData()
        
        AlbumApiCaller.shared.getAllAlbumTracks(albumID: albumID) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                // Stop loading indicator
                self.loadingIndicator.stopAnimating()
                
                switch result {
                case .success(let tracksResponse):
                    self.tracks = tracksResponse
                    self.tableView.isHidden = self.tracks.isEmpty
                    self.emptyStateLabel.isHidden = !self.tracks.isEmpty
                    self.tableView.reloadData()

                case .failure(let error):
                    print("Failed to fetch tracks: \(error)")
                    self.tracks = []
                    self.tableView.isHidden = true
                    self.emptyStateLabel.isHidden = false
                }
            }
        }
    }

    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AlbumTrackTableViewCell.identifier, for: indexPath) as? AlbumTrackTableViewCell else {
            return UITableViewCell()
        }
        
        let track = tracks[indexPath.row]
        cell.configure(with: track)
        return cell
    }
}
