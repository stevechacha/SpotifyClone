//
//  AlbumDetailViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 29/12/2024.
//


import UIKit

class AlbumDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let album: Album
    private var tracks: [Track] = []
    
    private let albumImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TrackCell")
        return tableView
    }()
    
    init(album: Album) {
        self.album = album
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = album.name ?? "Album Details"
        
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
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Layout UI elements
        albumImageView.frame = CGRect(x: (view.frame.width - 150) / 2, y: 100, width: 150, height: 150)
        albumNameLabel.frame = CGRect(x: 20, y: albumImageView.frame.maxY + 10, width: view.frame.width - 40, height: 50)
        artistLabel.frame = CGRect(x: 20, y: albumNameLabel.frame.maxY + 5, width: view.frame.width - 40, height: 20)
        releaseDateLabel.frame = CGRect(x: 20, y: artistLabel.frame.maxY + 5, width: view.frame.width - 40, height: 20)
        tableView.frame = CGRect(x: 0, y: releaseDateLabel.frame.maxY + 10, width: view.frame.width, height: view.frame.height - releaseDateLabel.frame.maxY - 10)
        
        // Configure UI elements
        albumNameLabel.text = album.name ?? "Unknown Album"
        artistLabel.text = album.artists?.map { $0.name }.joined(separator: ", ") ?? "Unknown Artist"
        releaseDateLabel.text = "Released: \(album.releaseDate ?? "Unknown Date")"
        
        if let imageUrlString = album.images?.first?.url, let imageUrl = URL(string: imageUrlString) {
            loadImage(from: imageUrl)
        }
    }
    
    private func fetchTracks() {
        guard let albumID = album.id else {
            print("Album ID is missing.")
            return
        }
        
        AlbumApiCaller.shared.getAlbumTracks(albumID: albumID) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let tracksResponse):
                    self?.tracks = tracksResponse.items
                    self?.tableView.reloadData()
                case .failure(let error):
                    print("Failed to fetch tracks: \(error)")
                }
            }
        }
    }
    
    private func loadImage(from url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.albumImageView.image = image
                }
            }
        }
    }
    
    // MARK: - TableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath)
        let track = tracks[indexPath.row]
        let durationMinutes = track.durationMs! / 1000 / 60
        let durationSeconds = (track.durationMs! / 1000) % 60
        
        cell.textLabel?.text = "\(track.name) (\(durationMinutes):\(String(format: "%02d", durationSeconds)))"
        cell.textLabel?.numberOfLines = 2
        return cell
    }
}
