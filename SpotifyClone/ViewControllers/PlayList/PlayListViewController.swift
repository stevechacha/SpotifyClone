//
//  PlayerListViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 04/12/2024.
//

import UIKit

class PlayListViewController: UIViewController {

    var playlistID: String
    var playlists : SpotifyPlaylist?
    var playlistItemResponse: [PlaylistItemsResponse] = []
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .gray
        return indicator
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = createCompositionalLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    init(playlistID: String) {
        self.playlistID = playlistID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Loading..."
        view.backgroundColor = .systemBackground
        
        setupCollectionView()
        setupLoadingIndicator()
        fetchPlaylistTracks()
        getPlaylistDetails()
        addLongTapGestures()
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        
        collectionView.register(
            PlayListTrackCollectionViewCell.self,
            forCellWithReuseIdentifier: PlayListTrackCollectionViewCell.identifier
        )
       
        collectionView.register(
            PlaylistHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier
        )
        
        let gestures = UILongPressGestureRecognizer(
            target: self,
            action: #selector(didLongPress(_:))
        )
        collectionView.addGestureRecognizer(gestures)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
         
        let touchPoint = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: touchPoint) else { return }
         
         let trackToDelete = playlistItemResponse[indexPath.row]
         
         let actionSheet = UIAlertController(
            title: trackToDelete.track?.name,
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
                             strongSelf.playlistItemResponse.remove(at: indexPath.row)
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
    
    @objc func didAddLongPresss(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        let touchPoint = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: touchPoint) else { return }
        
        let trackToAdd = playlistItemResponse[indexPath.row]
        
        let actionSheet = UIAlertController(
            title: trackToAdd.track?.name,
            message: "Would you like to remove this from Playlist?",
            preferredStyle: .actionSheet
        )
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { [weak self] _ in
            DispatchQueue.main.async {
                guard let track = trackToAdd.track else { return }
                guard let strongSelf = self else { return }
                PlaylistApiCaller.shared.addTracksToPlayList(track: track, playlistID: strongSelf.playlistID){ success in
                    if success {
                        
                    } else {
                        print("errror")
                    }
                }
            }
        }))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    
    @objc func didAddLongPress(_ gesture: UILongPressGestureRecognizer) {
         guard gesture.state == .began else { return }
         
        let touchPoint = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: touchPoint) else { return }
         
         let trackToAdd = playlistItemResponse[indexPath.row]
         
         let actionSheet = UIAlertController(
            title: trackToAdd.track?.name,
             message: "Would you like to Add this from Playlist?",
             preferredStyle: .actionSheet
         )
         
         actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
         actionSheet.addAction(UIAlertAction(title: "Add to Playlist", style: .destructive, handler: { [weak self] _ in
             DispatchQueue.main.async {
                 let vc = LibraryViewController()
                 vc.selectionHandler = { playlist in
                     guard let track = trackToAdd.track, let playlistID = playlist.id else { return }
                     PlaylistApiCaller.shared.addTracksToPlayList(track: track, playlistID: playlistID){ success in
                         if success {
                             
                         } else {
                             print("errror")
                         }
                         
                     }
                     
                 }
                 vc.title = "Select Playlist"
                 self?.present(UINavigationController(rootViewController: vc),animated: true,completion: nil)
             }
            
         }))
         
         present(actionSheet, animated: true, completion: nil)
     }
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            
                // Track List Section
                let item = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .absolute(60)
                    )
                )
                item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 2, bottom: 1, trailing: 2)
                
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .absolute(60)
                    ),
                    subitems: [item]
                )
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [
                    NSCollectionLayoutBoundarySupplementaryItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .fractionalHeight(0.55)
                        ),
                        elementKind: UICollectionView.elementKindSectionHeader,
                        alignment: .top
                    )
                ]
                return section
        }
    }
    
    func getPlaylistDetails(){
        loadingIndicator.startAnimating()
        PlaylistApiCaller.shared.getPlaylistDetails(playlistID: playlistID){ [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.title = response.name
                    self?.playlists = response
                    self?.collectionView.reloadData()
                case .failure(let failure):
                    print(failure)
                }
            }
            
        }
    }
    
    private func addLongTapGestures(){
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didAddLongPress(_:)))
        collectionView.isUserInteractionEnabled = true
        collectionView.addGestureRecognizer(gesture)
        
    }
    
    
    func fetchPlaylistTracks() {
        loadingIndicator.startAnimating()
        PlaylistApiCaller.shared.getPlaylistTracks(playlistID: playlistID) { [weak self] result in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                switch result {
                case .success(let playlist):
                    self?.playlistItemResponse = playlist.items ?? []
                        self?.playlistItemResponse = playlist.items ?? []
                        self?.collectionView.reloadData()
                case .failure(let error):
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
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension PlayListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  playlistItemResponse.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PlayListTrackCollectionViewCell.identifier,
            for: indexPath
        ) as? PlayListTrackCollectionViewCell else {
            return UICollectionViewCell()
        }
        // Configure with track data
        cell.configure(with: playlistItemResponse[indexPath.row])
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier,
            for: indexPath
        ) as? PlaylistHeaderCollectionReusableView,
              kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let playlistHeaderViewModel = PlaylistHeaderViewModel(
            playlistName: playlists?.name ?? "",
            artUrl: URL(string: playlists?.images?.first?.url ?? ""),
            ownerName: playlists?.owner?.displayName ?? "",
            description: playlists?.description ?? "",
            playlistDuration: "",
            ownerArtUrl: URL(string: playlists?.images?.first?.url ?? ""),
            userId: ""
        )
        header.configure( with: playlistHeaderViewModel)
        header.delegate = self
        
        return header
    }
    
    
    

}


extension PlayListViewController: PlaylistHeaderCollectionReusableViewDelegate {
    func didTapDownloadButton(_ header: PlaylistHeaderCollectionReusableView) {
        // Click Download
    
    }
    
    func didTapAddButton(_ header: PlaylistHeaderCollectionReusableView) {
        // click Add Button
    }
    
    func didTapOptionsButton(_ header: PlaylistHeaderCollectionReusableView) {
        // adddOptionButton
    
    }
    
    func didTapPlayButton(_ header: PlaylistHeaderCollectionReusableView) {
        // playButton
    }
    

    
    func didTapAddToPlaylistButton(_ header: PlaylistHeaderCollectionReusableView) {
        // Present the LibraryViewController to choose a playlist
        let addPlaylistVC = AddPlaylistViewController(playlistID: playlistID)  // Pass the playlistID
        addPlaylistVC.selectionHandler = { [weak self] selectedPlaylist in
            guard let self = self else { return }
            
            print(selectedPlaylist.id)
            

            guard (self.playlistItemResponse.first?.track) != nil else {
                self.showAlert(title: "Error", message: "No tracks to add.")
                return
            }

            // Loop over tracks to add them to the selected playlist
            for track in self.playlistItemResponse.compactMap({ $0.track }) {
                PlaylistApiCaller.shared.addTracksToPlayList(track: track, playlistID: playlistID) { success in
                    if success {
                        print("\(track.name ?? "Track") added successfully to \(selectedPlaylist.name ?? "playlist").")
                    } else {
                        print("Failed to add \(track.name ?? "track").")
                    }
                }
            }

            self.showAlert(title: "Added", message: "Tracks added to \(selectedPlaylist.name ?? "Playlist").")
        }

        addPlaylistVC.title = "Select Playlist"
        present(UINavigationController(rootViewController: addPlaylistVC), animated: true, completion: nil)
    }
    
   

   
}








