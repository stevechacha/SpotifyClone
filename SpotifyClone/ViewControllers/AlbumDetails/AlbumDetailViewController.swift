//
//  AlbumDetailViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 29/12/2024.
//


import UIKit
import SDWebImage

import UIKit
import SDWebImage

class AlbumDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
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
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
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
        tableView.register(AlbumDetailTableViewCell.self, forCellReuseIdentifier: AlbumDetailTableViewCell.identifier)
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.title = "Album Details"
        setupUI()
        fetchAlbumDetails()
        fetchTracks()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
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
        
        NSLayoutConstraint.activate([
            albumImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            albumImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            albumImageView.widthAnchor.constraint(equalToConstant: 150),
            albumImageView.heightAnchor.constraint(equalToConstant: 150),
            
            albumNameLabel.topAnchor.constraint(equalTo: albumImageView.bottomAnchor, constant: 8),
            albumNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            albumNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            artistLabel.topAnchor.constraint(equalTo: albumNameLabel.bottomAnchor, constant: 4),
            artistLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            artistLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            releaseDateLabel.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 4),
            releaseDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            releaseDateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: releaseDateLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Fetch Album Details
    private func fetchAlbumDetails() {
        AlbumApiCaller.shared.getAlbumDetails(albumID: albumID) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let album):
                    self.albumNameLabel.text = album.name ?? "Unknown Album"
                    self.artistLabel.text = album.artists?.map { $0.name ?? "Unknown Artist" }.joined(separator: ", ") ?? "Unknown Artist"
                    self.releaseDateLabel.text = "Released: \(album.releaseDate ?? "Unknown Date")"
                    if let imageUrlString = album.images?.first?.url, let imageUrl = URL(string: imageUrlString) {
                        self.albumImageView.sd_setImage(with: imageUrl, completed: nil)
                    }
                case .failure(let error):
                    print("Error fetching album details: \(error)")
                    self.albumNameLabel.text = "Failed to Load Album"
                }
            }
        }
    }
    
    // MARK: - Fetch Tracks
    private func fetchTracks() {
        loadingIndicator.startAnimating()
        tableView.isHidden = true
        emptyStateLabel.isHidden = true
        
        AlbumApiCaller.shared.getAllAlbumTracks(albumID: albumID) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.loadingIndicator.stopAnimating()
                switch result {
                case .success(let tracks):
                    self.tracks = tracks
                    self.tableView.isHidden = tracks.isEmpty
                    self.emptyStateLabel.isHidden = !tracks.isEmpty
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
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: AlbumDetailTableViewCell.identifier,
            for: indexPath
        ) as? AlbumDetailTableViewCell else {
            return UITableViewCell()
        }
        
        let track = tracks[indexPath.row]
        cell.configure(with: track)
        return cell
    }
}
