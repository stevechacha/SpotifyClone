//
//  RecommendationsViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 28/12/2024.
//

import UIKit

class RecommendationsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func getAvailableGenreSeeds(){
        RecommendedApiCaller.shared.getAvailableGenreSeeds { result in
            switch result {
            case .success(let genres):
                print("Available genres: \(genres)")
            case .failure(let error):
                print("Error fetching genres: \(error)")
            }
        }

    }
    
    // MARK: - Fetch Recommendations
    private func fetchData() {
//        RecommendedApiCaller.shared.getRecommendedGenre { [weak self] result in
//            DispatchQueue.main.async { [weak self] in
//                guard let self = self else {
//                    print("ViewController deallocated before API response")
//                    return
//                }
//
//                switch result {
//                case .success(let model):
//                    let genres = model.genres
//                    guard !genres.isEmpty else {
//                        print("Genres list is empty. Cannot fetch recommendations.")
//                        self.showError("No genres available to recommend.")
//                        return
//                    }
//
//                    let maxSeeds = min(5, genres.count)
//                    var seeds = Set<String>()
//                    while seeds.count < maxSeeds, let random = genres.randomElement() {
//                        seeds.insert(random)
//                    }
//
//                    print("Genres seeds sent for recommendations: \(seeds)")
//
//                    // Show loading indicator
//                    self.showLoadingIndicator(true)
//
//                    // Fetch recommendations
//                    ApiCaller.shared.getRecommedations(genres: seeds) { recommendationResult in
//                        DispatchQueue.main.async { [weak self] in
//                            guard let self = self else {
//                                print("ViewController deallocated before recommendation response")
//                                return
//                            }
//
//                            // Hide loading indicator
//                            self.showLoadingIndicator(false)
//
//                            switch recommendationResult {
//                            case .success(let recommendations):
//                                print("Fetched recommendations: \(recommendations)")
//                                // Update UI with recommendations here
//                                self.updateUI(with: recommendations)
//                            case .failure(let error):
//                                print("Failed to fetch recommendations: \(error.localizedDescription)")
//                                self.showError("Failed to fetch recommendations. Please try again.")
//                            }
//                        }
//                    }
//
//                case .failure(let error):
//                    print("Failed to fetch GENRES: \(error.localizedDescription)")
//                    self.showError("Failed to fetch genres. Please check your connection.")
//                }
//            }
//        }
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
