//
//  ChaptersViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 28/12/2024.
//

import UIKit

class ChaptersViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        fetchShowsEpisodesAndChapters(for: "Those Old Radio Shows")
        
//        ChapterApiCaller.shared.searchSpotifyItem(query: "Those Old Radio Shows", type: "show") { result in
//            switch result {
//            case .success(let chapterIDs):
//                print("Found Chapters: \(chapterIDs)")
//            case .failure(let error):
//                print("Failed to search chapters: \(error)")
//            }
//        }
        
//        ChapterApiCaller.shared.getUserSavedEpisodes { results in
//            switch results {
//                
//            case .success(let savedEpisodes):
//                print("Found Episodes \(savedEpisodes)")
//            case .failure(let error):
//                print(error.localizedDescription)
//            }
//        }
        
        ChapterApiCaller.shared.getUserSavedPodCasts { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print(response)
                case .failure(let error):
                    print("Failed to fetch shows: \(error.localizedDescription)")
                }
            }
        }



    }
    
    // 1. Function to start fetching data for shows, episodes, and chapters
        func fetchShowsEpisodesAndChapters(for query: String) {
            // 1. Search for shows with the given query
            ChapterApiCaller.shared.searchSpotifyItem(query: query, type: "show") { result in
                switch result {
                case .success(let showIds):
                    // If shows are found, proceed to fetch their details
                    self.fetchShowDetails(for: showIds)
                case .failure(let error):
                    print("Failed to search shows: \(error)")
                }
            }
        }

        // 2. Function to fetch details for each show ID
        func fetchShowDetails(for showIds: [String]) {
            for showId in showIds {
                ChapterApiCaller.shared.getPodcastDetails(showID: showId) { result in
                    switch result {
                    case .success(let showDetail):
                        // Successfully fetched show details, now fetch episodes
                        print("Fetched show: \(showDetail.name ?? "Unknow Show Detail Name")")
                        self.fetchEpisodes(for: showId)
                        
                    case .failure(let error):
                        print("Failed to fetch show details for show \(showId): \(error)")
                    }
                }
            }
        }

        // 3. Function to fetch episodes for a given show
        func fetchEpisodes(for showId: String) {
            ChapterApiCaller.shared.getPodcastEpisodes(showID: showId) { result in
                switch result {
                case .success(let episodesResponse):
                    let episodeIds = episodesResponse.episodes?.compactMap { $0.id } ?? []
                    print("Fetched \(episodeIds.count) episodes for show ID: \(showId)")
                    // Now fetch episode details
                    self.fetchEpisodeDetails(for: episodeIds)

                case .failure(let error):
                    print("Failed to fetch episodes for show \(showId): \(error)")
                }
            }
        }

        // 4. Function to fetch details for each episode
        func fetchEpisodeDetails(for episodeIds: [String]) {
            for episodeId in episodeIds {
                ChapterApiCaller.shared.getEpisodeDetails(episodeID: episodeId) { result in
                    switch result {
                    case .success(let episodeDetail):
                        print("Fetched episode: \(episodeDetail.name ?? "Unknown Episode Name")")
                        // Fetch chapters for this episode
                        self.fetchChapters(for: episodeId)
                        
                    case .failure(let error):
                        print("Failed to fetch episode details for episode \(episodeId): \(error)")
                    }
                }
            }
        }

        // 5. Function to fetch chapters for a given episode
        func fetchChapters(for episodeId: String) {
            ChapterApiCaller.shared.getSeveralChapters(ids: [episodeId]) { result in
                switch result {
                case .success(let chaptersResponse):
                    let chapterIds = chaptersResponse.chapters?.compactMap { $0.id } ?? []
                    print("Fetched \(chapterIds.count) chapters for episode ID: \(episodeId)")
                    // Process the chapters (e.g., display them or store them for later)
                    self.processChapters(chapterIds)

                case .failure(let error):
                    print("Failed to fetch chapters for episode \(episodeId): \(error)")
                }
            }
        }

        // 6. Function to process the chapters
        func processChapters(_ chapterIds: [String]) {
            for chapterId in chapterIds {
                ChapterApiCaller.shared.getChapterDetails(chapterID: chapterId) { result in
                    switch result {
                    case .success(let chapterDetail):
                        print("Fetched chapter: \(chapterDetail.name)")
                        // Here, you can update your UI or store the chapter data

                    case .failure(let error):
                        print("Failed to fetch chapter details for chapter \(chapterId): \(error)")
                    }
                }
            }
        }
    
    
    func getChapters(){
        ChapterApiCaller.shared.searchSpotifyItem(query: "Technology", type: "show") { result in
            switch result {
            case .success(let ids):
                print("Show IDs: \(ids)")
                ChapterApiCaller.shared.getSeveralShows(ids: ids) { result in
                    switch result {
                    case .success(let response):
                        print("Fetched Shows: \(response)")
                    case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                print("Error searching for shows: \(error.localizedDescription)")
            }
        }
        
        ChapterApiCaller.shared.getUserSavedPodCasts { result in
            switch result {
            case .success(let savedShows):
                print("User's Saved Shows: \(savedShows)")
            case .failure(let error):
                print("Error fetching saved shows: \(error.localizedDescription)")
            }
        }
        
        ChapterApiCaller.shared.searchSpotifyItem(query: "Science", type: "show") { result in
            switch result {
            case .success(let ids):
                print("Fetched Show IDs: \(ids)")
            case .failure(let error):
                print("Search failed with error: \(error.localizedDescription)")
            }
        }
        
        ChapterApiCaller.shared.getEpisodeDetails(episodeID: "episode1") { result in
            switch result {
            case .success(let episodeDetails):
                print("Episode Details: \(episodeDetails)")
            case .failure(let error):
                print("Error fetching episode details: \(error.localizedDescription)")
            }
        }
        
        // Step 1: Search for Shows
        ChapterApiCaller.shared.search(query: "Science Podcast", type: "show") { result in
            switch result {
            case .success(let searchResponse):
                if let firstShow = searchResponse.shows?.items.first {
                    print("Found Show: \(firstShow.name ?? "Unknown First Show Name") (ID: \(firstShow.id ?? "NO ShowID"))")
                    
                    // Step 2: Get Episodes of the Show
                    ChapterApiCaller.shared.getPodcastEpisodes(showID: firstShow.id!) { result in
                        switch result {
                        case .success(let episodesResponse):
                            // Access the 'items' property for episodes
                            let episodeIDs = episodesResponse.episodes?.map { $0.id }
                            print("Fetched Episode IDs: \(episodeIDs ?? [] )")
                            
                            // Get details for the first episode
                            if let firstEpisodeID = episodeIDs?.first {
                                ChapterApiCaller.shared.getEpisodeDetails(episodeID: firstEpisodeID!) { result in
                                    switch result {
                                    case .success(let episodeDetails):
                                        print("Episode Details: \(episodeDetails)")
                                    case .failure(let error):
                                        print("Error fetching episode details: \(error.localizedDescription)")
                                    }
                                }
                            }
                        case .failure(let error):
                            print("Error fetching show episodes: \(error.localizedDescription)")
                        }
                    }

                }
            case .failure(let error):
                print("Error searching for shows: \(error.localizedDescription)")
            }
        }
    }
}
