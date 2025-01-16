//
//  AddPlaylistViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 14/01/2025.
//

import UIKit

class AddPlaylistViewController: UIViewController {
    
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private var isLoading = false
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    private var searchWokItem: DispatchWorkItem?
    private var recentlyPlayed = [RecentlyPlayedItem]()
    public var  selectionHandler: ((SpotifyPlaylist) -> Void)?
    private var playlist: SpotifyPlaylist?
    
    
    
    var playlistIDs: String?
    
    init(playlistID: String?) {
        self.playlistIDs = playlistID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "\(playlistIDs ?? "")"
        
        setupUI()
        fetchData()
        
        
        if selectionHandler != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .close,
                target: self, action: #selector(didTapClose)
            )
        }
        
    }
    
    @objc func didTapClose(){
        dismiss(animated: true,completion: nil)
    }
    
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        setupSearch()
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.center = view.center
        loadingIndicator.startAnimating()
          
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AddPlaylistTableViewCell.self, forCellReuseIdentifier: AddPlaylistTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        setupConstraints()
    }
    func setupSearch(){
        
        searchBar.placeholder = "Search"
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func fetchData() {
        SpotifyPlayer.shared.getRecentlyPlayed { [weak self] result in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()  // Stop the indicator once data is fetched
                switch result {
                case .success(let response):
                    self?.recentlyPlayed = response.items ?? []
                    self?.tableView.reloadData()
                case .failure(let failure):
                    print("Recently Error\(failure)")
                }
            }
        }
    }
}


extension AddPlaylistViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentlyPlayed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = recentlyPlayed[indexPath.row]

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: AddPlaylistTableViewCell.identifier,
            for: indexPath
        ) as? AddPlaylistTableViewCell else {
            return UITableViewCell()
        }
        
        let viewModel = AddPlaylistCellViewModel(
            trackName: result.track?.name ?? "",
            trackArtist: result.track?.artists?.first?.name ?? "",
            trackArtUrl: URL(string: result.track?.album?.images?.first?.url ?? "")
        )
        
        cell.configureCell(with: viewModel)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedPlaylist = playlist else { return}
        selectionHandler?(selectedPlaylist)
        dismiss(animated: true, completion: nil)
    }

    
}

extension AddPlaylistViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        let addPlaylistSearch = AddPlaylistSearchViewController()
        navigationController?.pushViewController(addPlaylistSearch, animated: true)
        return false
    }
}


extension AddPlaylistViewController: AddPlaylistTableViewCellDelegate {
    func didTapAddButton(on cell: AddPlaylistTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("IndexPath not found for cell")
            return
        }
        
        let tracks = recentlyPlayed[indexPath.row].track
        print("Add button tapped for track: \(tracks?.name ?? "Unknown")")
        
        guard let track = tracks else {
            print("Track is nil")
            return
        }
        guard let newPlaylistID = playlistIDs else { return }
     
        
        PlaylistApiCaller.shared.addTracksToPlayList(track: track, playlistID: newPlaylistID) { success in
            DispatchQueue.main.async {
                if success {
                    print("Successfully added \(track.name ?? "unknown") to playlist with ID: \(newPlaylistID)")
                    self.showAlert(title: "Success", message: "Track added to the playlist.")
                } else {
                    print("Failed to add track to playlist to \(newPlaylistID)")
                    self.showAlert(title: "Error", message: "Failed to add track to playlist.")
                }
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}

