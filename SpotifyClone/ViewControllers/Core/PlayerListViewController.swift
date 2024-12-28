//
//  PlayerListViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 04/12/2024.
//

import UIKit

class PlayerListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUserPlaylists()
        // Do any additional setup after loading the view.
    }
    
    
    func getUserPlaylists(){
        var userID: String = ""
        var playlistID: String = ""

        PlaylistApiCaller.shared.getCurrentUsersPlaylist { result in
            switch result {
            case .success(let playlistsResponse):
                guard let playlists = playlistsResponse.items else {
                    print("No playlists found!")
                    return
                }
                
                for playlist in playlists {
                    print("Playlist ID: \(playlist.id), Playlist Name: \(playlist.name)")
                }
            case .failure(let error):
                print("Error fetching playlists: \(error)")
            }
        }
        
        UserApiCaller.shared.getCurrentUserProfile { result in
            switch result {
            case .success(let profile):
                userID = profile.id
                print("Fetched User ID: \(userID)")
                
                PlaylistApiCaller.shared.getCurrentUsersPlaylist { result in
                    switch result {
                    case .success(let response):
                        if let firstPlaylist = response.items?.first {
                            playlistID = firstPlaylist.id
                            print("Fetched Playlist ID: \(playlistID)")
                            
                            // Now you can pass these to fetchAllPlaylistDetails
                            PlaylistApiCaller.shared.fetchAllPlaylistDetails(playlistID: playlistID, userID: userID) { result in
                                switch result {
                                case .success(let details):
                                    print("All playlist details: \(details)")
                                case .failure(let error):
                                    print("Error: \(error)")
                                }
                            }
                        }
                    case .failure(let error):
                        print("Error fetching playlists: \(error)")
                    }
                }
            case .failure(let error):
                print("Error fetching user profile: \(error)")
            }
        }


    }
    
    
    func getPlaylists(){
        let apiCaller = PlaylistApiCaller()

        apiCaller.getCurrentUsersPlaylist { result in
            switch result {
            case .success(let playlistsResponse):
                // Access the playlists array
                let playlists = playlistsResponse.items

                // Example: Print all playlist IDs
                for playlist in playlists! {
                    print("Playlist Name: \(playlist.name), Playlist ID: \(playlist.id)")
                }

                // Example: Access the first playlist ID
                if let firstPlaylistID = playlists?.first?.id {
                    print("First Playlist ID: \(firstPlaylistID)")
                }
            case .failure(let error):
                print("Failed to fetch playlists: \(error)")
            }
        }
        
    }
    
    func fetchPlaylistsAndTracks() {
        let apiCaller = PlaylistApiCaller()

        apiCaller.getCurrentUsersPlaylist { result in
            switch result {
            case .success(let playlistsResponse):
                for playlist in playlistsResponse.items! {
                    print("Playlist Name: \(playlist.name)")
                    
                    // Fetch tracks for each playlist
                    apiCaller.getPlaylistTracks(playlistID: playlist.id) { tracksResult in
                        switch tracksResult {
                        case .success(let tracksResponse):
                            for trackItem in tracksResponse.items {
                                print("Track: \(trackItem.track.name) by \(trackItem.track.artists?.map { $0.name }.joined(separator: ", "))")
                            }
                        case .failure(let error):
                            print("Failed to fetch tracks: \(error)")
                        }
                    }
                }
            case .failure(let error):
                print("Failed to fetch playlists: \(error)")
            }
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
