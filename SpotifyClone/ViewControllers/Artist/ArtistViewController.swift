//
//  ArtistViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 28/12/2024.
//

import UIKit

class ArtistViewController: UIViewController {
    
    private let topArtist: TopItem
    private var topTracks: [Track] = []
    private var albums: [Album] = []
    private var relatedArtists: [RelatedArtist] = []
    private var headerView: UIView!
    private var segmentedControl: UISegmentedControl!
    private var tableView: UITableView!
    
    // Loading indicator
    private var activityIndicator: UIActivityIndicatorView!

    // MARK: - Initializer
    init(topArtist: TopItem) {
        self.topArtist = topArtist
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
        nameLabel.text = topArtist.name
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
        
        // Fetch artist details for genres and followers
        ArtistApiCaller.shared.getArtistDetails(artistID: topArtist.id ?? "") { [weak self] result in
            DispatchQueue.main.async {
                self?.stopLoadingIndicator()  // Stop loading once data is fetched
            }
            
            switch result {
            case .success(let details):
                DispatchQueue.main.async {
                    let genres = details.genres?.joined(separator: ", ").capitalized ?? "Unknown Genres"
                    let followers = details.followers?.total ?? 0
                    detailsLabel.text = "Genres: \(genres)\nFollowers: \(followers)"
                    
                    if let imageUrl = details.images?.first?.url, let url = URL(string: imageUrl) {
                        artistImageView.loadImage(from: url)
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
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
    
    // MARK: - Fetch Data
    private func fetchTopTracks() {
        startLoadingIndicator() // Start loading before fetching
        ArtistApiCaller.shared.getArtistsTopTracks(for: topArtist.id ?? "") { [weak self] result in
            switch result {
            case .success(let tracksResponse):
                self?.topTracks = tracksResponse.tracks
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.stopLoadingIndicator()  // Stop loading once data is fetched
                }
            case .failure(let error):
                print("Error fetching top tracks: \(error)")
                self?.stopLoadingIndicator()  // Stop loading if there's an error
            }
        }
    }
    
    private func fetchAlbums() {
        startLoadingIndicator() // Start loading before fetching
        ArtistApiCaller.shared.getArtistAlbums(artistID: topArtist.id ?? "") { [weak self] result in
            switch result {
            case .success(let albumsResponse):
                self?.albums = albumsResponse.items
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.stopLoadingIndicator()  // Stop loading once data is fetched
                }
            case .failure(let error):
                print("Error fetching albums: \(error)")
                self?.stopLoadingIndicator()  // Stop loading if there's an error
            }
        }
    }
    
    private func fetchRelatedArtists() {
        startLoadingIndicator() // Start loading before fetching
        ArtistApiCaller.shared.getRelatedArtists(artistID: topArtist.id ?? "") { [weak self] result in
            switch result {
            case .success(let artists):
                self?.relatedArtists = artists.artists ?? []
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.stopLoadingIndicator()  // Stop loading once data is fetched
                }
            case .failure(let error):
                print("Error fetching related artists: \(error)")
                self?.stopLoadingIndicator()  // Stop loading if there's an error
            }
        }
    }
    
    // MARK: - Segmented Control Action
    @objc private func segmentChanged() {
        tableView.reloadData()
    }
}

// MARK: - UITableView Data Source & Delegate
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
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            cell.textLabel?.text = topTracks[indexPath.row].name
        case 1:
            cell.textLabel?.text = albums[indexPath.row].name
        case 2:
            cell.textLabel?.text = relatedArtists[indexPath.row].name
        default:
            break
        }
        return cell
    }
}

extension UIImageView {
    // Load image from URL (you can replace this with a third-party library like SDWebImage)
    func loadImage(from url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    self.image = UIImage(data: data)
                }
            }
        }
    }
}
