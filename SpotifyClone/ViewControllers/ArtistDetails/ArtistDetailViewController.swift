//
//  ArtistDetailViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 03/01/2025.
//

import UIKit

class ArtistDetailViewController: UIViewController {
    
//    private let artist: Artist
    private let artistID: String
    
    // MARK: - Initializer
    init(artistID: String) {
        self.artistID = artistID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "'artist.name'"

        // Do any additional setup after loading the view.
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
