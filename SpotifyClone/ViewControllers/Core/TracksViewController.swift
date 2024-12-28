//
//  TracksViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 28/12/2024.
//

import UIKit

class TracksViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
     func getTracks(){
         TrackApiCaller.shared.searchTracks(query: "Blinding Lights") { result in
             switch result {
             case .success(let trackIDs):
                 print("Track IDs Array: \(trackIDs)")
                 // Example Output: ["3jfr0TF6DQcOLat8gGn7E2", "7ouMYWpwJ422jRcDASZB7P", ...]
             case .failure(let error):
                 print("Error fetching track IDs: \(error)")
             }
         }
         
         TrackApiCaller.shared.searchFirstTrackID(query: "Blinding Lights") { result in
             switch result {
             case .success(let trackID):
                 print("First Track ID: \(trackID)")
                 // Example Output: "3jfr0TF6DQcOLat8gGn7E2"
             case .failure(let error):
                 print("Error: \(error)")
             }
         }
         
         TrackApiCaller.shared.searchTrack(query: "Blinding Lights") { result in
             switch result {
             case .success(let trackIDs):
                 if let firstTrackID = trackIDs.first {
                     print("Track ID: \(firstTrackID)")
                     
                     // Fetch audio analysis
                     TrackApiCaller.shared.getTracksAudioAnalysis(audioID: firstTrackID) { analysisResult in
                         switch analysisResult {
                         case .success(let audioAnalysis):
                             print("Audio Analysis: \(audioAnalysis)")
                         case .failure(let error):
                             print("Error fetching audio analysis: \(error)")
                         }
                     }
                 }
             case .failure(let error):
                 print("Error searching track: \(error)")
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
