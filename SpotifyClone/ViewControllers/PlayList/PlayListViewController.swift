//
//  PlayerListViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 04/12/2024.
//

import UIKit


class PlayListViewController: UIViewController {
    
    var playlistID: String
    var tracks: [PlaylistItemsResponse] = [] // To store the fetched tracks
    var playlistTitle: String? // To store the playlist title
    
    
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .gray
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
    
    private let playlistNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.numberOfLines = 2
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
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    

    
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { _, _ -> NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
            )
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 2, bottom: 1, trailing: 2)
            
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(60)
                ),
                subitem: item,
                count: 1
            )
            
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [
                NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(100)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
            ]
            
            return section
        })
    )
    
   
    
    // Initialize with a playlist
    init(playlistID: String) {
        self.playlistID = playlistID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Playlist"
        view.backgroundColor = .systemBackground
        
        // Add collectionView
        view.addSubview(collectionView)
        collectionView.register(
            PlayListTrackCollectionViewCell.self,
            forCellWithReuseIdentifier: PlayListTrackCollectionViewCell.identifier
        )
        collectionView.register(
            PlaylistHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier
        )
        
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Add tableView
        setupTableView()
        fetchPlaylistTracks()
        setupLoadingIndicator()
        
        let gestures = UILongPressGestureRecognizer(
            target: self,
            action: #selector(didLongPress(_:))
        )
        tableView.addGestureRecognizer(gestures)
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            PlayListTrackTableViewCell.self,
            forCellReuseIdentifier: PlayListTrackTableViewCell.identifier
        )
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        let touchPoint = gesture.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: touchPoint) else { return }
        
        let trackToDelete = tracks[indexPath.row]
        
        let actionSheet = UIAlertController(
            title: "Remove",
            message: "Would you like to remove this from Playlist?",
            preferredStyle: .actionSheet
        )
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { [weak self] _ in
            guard let strongSelf = self else { return }
            PlaylistApiCaller.shared.removeTracksToPlayList(track: trackToDelete.track!, playlistID: strongSelf.playlistID) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let success):
                        if success {
                            strongSelf.tracks.remove(at: indexPath.row)
                            strongSelf.fetchPlaylistTracks()
                        } else {
                            strongSelf.showAlert(title: "Error", message: "Failed to remove track.")
                        }
                    case .failure(let error):
                        strongSelf.showAlert(title: "Error", message: error.localizedDescription)
                    }
                }
            }
        }))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
   
    
    func fetchPlaylistTracks() {
        loadingIndicator.startAnimating()
        PlaylistApiCaller.shared.getPlaylistTracks(playlistID: playlistID) { [weak self] result in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
            }
            switch result {
            case .success(let tracksResponse):
                self?.tracks = tracksResponse.items ?? []
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension PlayListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { tracks.count }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let trackItem = tracks[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PlayListTrackCollectionViewCell.identifier,
            for: indexPath
        ) as? PlayListTrackCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: trackItem)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier,
                for: indexPath
              ) as? PlaylistHeaderCollectionReusableView else {
            return UICollectionReusableView()
        }
        header.configure(
            with: playlistTitle ?? "Playlist",
            creator: "",
            duration: ""
        )
        return header
    }
}



extension PlayListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let trackItem = tracks[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlayListTrackTableViewCell.identifier, for: indexPath) as? PlayListTrackTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: trackItem)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTrack = tracks[indexPath.row]
        playTrack(selectedTrack)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func playTrack(_ trackItem: PlaylistItemsResponse) {
        guard let trackURI = trackItem.track?.uri else {
            print("Track URI is missing")
            return
        }
        
        SpotifyPlayer.shared.setVolume(level: 100) { result in
            switch result {
            case .success:
                print("Volume set successfully!")
                SpotifyPlayer.shared.playTrack(uri: trackURI) { result in
                    switch result {
                    case .success:
                        print("Now playing: \(trackItem.track?.name ?? "")")
                    case .failure(let error):
                        print("Error starting playback: \(error)")
                    }
                }
            case .failure(let error):
                print("Error setting volume: \(error)")
            }
        }
    }
}



class PlaylistHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "PlaylistHeaderCollectionReusableView"
    
    // MARK: - UI Components
    
    // UI Components
    private let playlistImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private let creatorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    private let gridStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let headerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Configure the grid stack with image views
        setupGridStack()
        
        // Add subviews
        headerStack.addArrangedSubview(gridStack)
        headerStack.addArrangedSubview(titleLabel)
        headerStack.addArrangedSubview(creatorLabel)
        headerStack.addArrangedSubview(durationLabel)
        
        addSubview(headerStack)
        
        // Layout Constraints
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupGridStack() {
        for _ in 0..<2 { // Two rows
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 4
            rowStack.distribution = .fillEqually
            
            for _ in 0..<2 { // Two columns per row
                let imageView = UIImageView()
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.image = UIImage(named: "placeholder") // Replace with actual image
                rowStack.addArrangedSubview(imageView)
            }
            
            gridStack.addArrangedSubview(rowStack)
        }
    }
    
    private func setupConstraints() {
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            headerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            headerStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configure Method
    
    public func configure(with title: String, creator: String, duration: String) {
        titleLabel.text = title
        creatorLabel.text = creator
        durationLabel.text = duration
    }
}



struct PlaylistHeaderViewModel {
    let name: String
    let ownerName: String
    let description: String
    let artUrl: URL?
    let duration: String
    
    init(name: String, artUrl: URL?, ownerName: String, description: String, duration: String) {
        self.name = name
        self.artUrl = artUrl
        self.ownerName = ownerName
        self.duration = duration
        self.description = description
    }
}


