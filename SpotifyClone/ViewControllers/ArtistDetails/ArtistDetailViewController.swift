//
//  ArtistDetailViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 03/01/2025.
//

import UIKit

//class ArtistDetailViewController: UIViewController, UITableViewDataSource, UICollectionViewDataSource {
//
//    private let artistID: String
//
//    // MARK: - UI Components
//    private let scrollView = UIScrollView()
//    private let contentView = UIStackView()
//
//    private let artistNameLabel = UILabel()
//    private let artistImageView = UIImageView()
//    private let topTracksLabel = UILabel()
//    private let albumsLabel = UILabel()
//    private let relatedArtistsLabel = UILabel()
//
//    private let topTracksTableView = UITableView()
//    private let albumsTableView = UITableView()
//    private let relatedArtistsCollectionView: UICollectionView
//
//    private var topTracks: [Track] = []
//    private var albums: [Album] = []
//    private var relatedArtists: [RelatedArtist] = []
//    
//    private var artistName: String = "Artist" {
//           didSet {
//               self.title = artistName
//           }
//       }
//
//
//    // MARK: - Initializer
//    init(artistID: String) {
//        self.artistID = artistID
//
//        // Configure the collection view layout for related artists
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        layout.itemSize = CGSize(width: 100, height: 120)
//        layout.minimumLineSpacing = 10
//        self.relatedArtistsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//        title = "Artist Details"
//
//        setupUI()
//        fetchArtistDetails()
//    }
//
//    // MARK: - Setup UI
//    private func setupUI() {
//        // Configure labels
//        artistNameLabel.font = .systemFont(ofSize: 24, weight: .bold)
//        artistNameLabel.textAlignment = .center
//        artistNameLabel.numberOfLines = 0
//
//        artistImageView.contentMode = .scaleAspectFit
//        artistImageView.layer.cornerRadius = 10
//        artistImageView.clipsToBounds = true
//
//        topTracksLabel.text = "Top Tracks"
//        topTracksLabel.font = .systemFont(ofSize: 20, weight: .bold)
//
//        albumsLabel.text = "Albums"
//        albumsLabel.font = .systemFont(ofSize: 20, weight: .bold)
//
//        relatedArtistsLabel.text = "Related Artists"
//        relatedArtistsLabel.font = .systemFont(ofSize: 20, weight: .bold)
//
//        topTracksTableView.dataSource = self
//        albumsTableView.dataSource = self
//        relatedArtistsCollectionView.dataSource = self
//
//        topTracksTableView.register(UITableViewCell.self, forCellReuseIdentifier: "TrackCell")
//        albumsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "AlbumCell")
//        relatedArtistsCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ArtistCell")
//
//        // Configure stack view
//        contentView.axis = .vertical
//        contentView.spacing = 20
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//
//        // Add components to stack view
//        contentView.addArrangedSubview(artistImageView)
//        contentView.addArrangedSubview(artistNameLabel)
//
//        contentView.addArrangedSubview(topTracksLabel)
//        contentView.addArrangedSubview(topTracksTableView)
//        contentView.addArrangedSubview(albumsLabel)
//        contentView.addArrangedSubview(albumsTableView)
//        contentView.addArrangedSubview(relatedArtistsLabel)
//        contentView.addArrangedSubview(relatedArtistsCollectionView)
//
//        // Configure scroll view
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(scrollView)
//        scrollView.addSubview(contentView)
//
//        NSLayoutConstraint.activate([
//            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//
//            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
//            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
//
//            artistImageView.heightAnchor.constraint(equalToConstant: 200),
//            topTracksTableView.heightAnchor.constraint(equalToConstant: 200),
//            albumsTableView.heightAnchor.constraint(equalToConstant: 200),
//            relatedArtistsCollectionView.heightAnchor.constraint(equalToConstant: 120)
//        ])
//    }
//
//    // MARK: - Fetch Artist Details
//    private func fetchArtistDetails() {
//        let dispatchGroup = DispatchGroup()
//
//        // Fetch Artist Details
//        dispatchGroup.enter()
//        ArtistApiCaller.shared.getArtistDetails(artistID: artistID) { [weak self] result in
//            defer { dispatchGroup.leave() }
//            switch result {
//            case .success(let artistDetails):
//                DispatchQueue.main.async {
//                    self?.artistNameLabel.text = artistDetails.name
//                    self?.title = artistDetails.name // Set the title to the artist's name
//                    if let imageUrl = artistDetails.images?.first?.url {
//                        self?.artistImageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(systemName: "person.crop.circle"))
//                    }
//                }
//            case .failure(let error):
//                print("Failed to fetch artist details: \(error)")
//            }
//        }
//
//        // Fetch Top Tracks
//        dispatchGroup.enter()
//        ArtistApiCaller.shared.getArtistsTopTracks(for: artistID) { [weak self] result in
//            defer { dispatchGroup.leave() }
//            switch result {
//            case .success(let topTracksResponse):
//                DispatchQueue.main.async {
//                    self?.topTracks = topTracksResponse.tracks
//                    self?.updateUI()
//                }
//            case .failure(let error):
//                print("Failed to fetch top tracks: \(error)")
//            }
//        }
//
//        // Fetch Albums
//        dispatchGroup.enter()
//        ArtistApiCaller.shared.getArtistAlbums(artistID: artistID) { [weak self] result in
//            defer { dispatchGroup.leave() }
//            switch result {
//            case .success(let albumsResponse):
//                DispatchQueue.main.async {
//                    self?.albums = albumsResponse.items
//                    self?.updateUI()
//                }
//            case .failure(let error):
//                print("Failed to fetch albums: \(error)")
//            }
//        }
//
//        // Fetch Related Artists
//        dispatchGroup.enter()
//        ArtistApiCaller.shared.getRelatedArtists(artistID: artistID) { [weak self] result in
//            defer { dispatchGroup.leave() }
//            switch result {
//            case .success(let relatedArtistsResponse):
//                DispatchQueue.main.async {
//                    self?.relatedArtists = relatedArtistsResponse.artists ?? []
//                    self?.updateUI()
//                }
//            case .failure(let error):
//                print("Failed to fetch related artists: \(error)")
//            }
//        }
//
//        dispatchGroup.notify(queue: .main) {
//            print("All artist data loaded")
//        }
//    }
//
//
//    // MARK: - Update UI
//    private func updateUI() {
//        topTracksTableView.isHidden = topTracks.isEmpty
//        topTracksLabel.isHidden = topTracks.isEmpty
//
//        albumsTableView.isHidden = albums.isEmpty
//        albumsLabel.isHidden = albums.isEmpty
//
//        relatedArtistsCollectionView.isHidden = relatedArtists.isEmpty
//        relatedArtistsLabel.isHidden = relatedArtists.isEmpty
//
//        topTracksTableView.reloadData()
//        albumsTableView.reloadData()
//        relatedArtistsCollectionView.reloadData()
//    }
//
//    // MARK: - Helper Methods
//    private func loadImage(from url: String, completion: @escaping (UIImage?) -> Void) {
//        guard let imageURL = URL(string: url) else { return }
//        DispatchQueue.global().async {
//            if let data = try? Data(contentsOf: imageURL), let image = UIImage(data: data) {
//                DispatchQueue.main.async {
//                    completion(image)
//                }
//            } else {
//                completion(nil)
//            }
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if tableView == topTracksTableView {
//            return topTracks.count
//        } else if tableView == albumsTableView {
//            return albums.count
//        }
//        return 0
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if tableView == topTracksTableView {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath)
//            let track = topTracks[indexPath.row]
//            
//            // Configure the cell
//            cell.textLabel?.text = track.name
//            cell.imageView?.contentMode = .scaleAspectFit
//            
//            // Use SDWebImage to load the track's album image
//            if let imageUrl = track.album?.images?.first?.url, let url = URL(string: imageUrl) {
//                cell.imageView?.sd_setImage(with: url, placeholderImage: UIImage(systemName: "music.note"))
//            }
//            return cell
//        } else if tableView == albumsTableView {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath)
//            let album = albums[indexPath.row]
//            
//            // Configure the cell
//            cell.textLabel?.text = album.name
//            cell.imageView?.contentMode = .scaleAspectFit
//            
//            // Use SDWebImage to load the album's image
//            if let imageUrl = album.images?.first?.url, let url = URL(string: imageUrl) {
//                cell.imageView?.sd_setImage(with: url, placeholderImage: UIImage(systemName: "photo"))
//            }
//            return cell
//        }
//        return UITableViewCell()
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return relatedArtists.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArtistCell", for: indexPath)
//        let artist = relatedArtists[indexPath.row]
//
//        // Clear existing content
//        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
//
//        // Add an image view
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFit
//        imageView.sd_setImage(with: URL(string: artist.images?.first?.url ?? ""), placeholderImage: UIImage(systemName: "person.crop.circle"))
//
//        // Add padding
//        let container = UIView()
//        container.addSubview(imageView)
//        container.translatesAutoresizingMaskIntoConstraints = false
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            imageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
//            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
//            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
//            imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
//        ])
//
//        // Add the label
//        let label = UILabel()
//        label.text = artist.name
//        label.font = .systemFont(ofSize: 12)
//        label.textAlignment = .center
//
//        // Stack the image and label vertically
//        let stackView = UIStackView(arrangedSubviews: [container, label])
//        stackView.axis = .vertical
//        stackView.spacing = 8
//        stackView.alignment = .center
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//
//        cell.contentView.addSubview(stackView)
//        NSLayoutConstraint.activate([
//            stackView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
//            stackView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 8),
//            stackView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -8),
//            stackView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8),
//        ])
//
//        return cell
//    }
//
//    
//}
