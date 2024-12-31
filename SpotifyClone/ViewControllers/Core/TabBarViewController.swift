//
//  TabBarViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 04/12/2024.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let homeController = HomeViewController()
        let searchController = SearchViewController()
        let libraryController = SavedItemsViewController()
        let profileController = ProfileViewController()
        
        homeController.title = "Browse"
        searchController.title = "Search"
        libraryController.title = "Library"
        profileController.title = "Profile"
        
        let nav1 = UINavigationController(rootViewController: homeController)
        let nav2 = UINavigationController(rootViewController: searchController)
        let nav3 = UINavigationController(rootViewController: libraryController)
        let nav4 = UINavigationController(rootViewController: profileController)
        
        nav1.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 2)
        nav3.tabBarItem = UITabBarItem(title: "Library", image: UIImage(systemName: "music.note.list"), tag: 3)
        nav4.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.circle"), tag: 4)
        
        nav1.navigationBar.prefersLargeTitles = true
        nav2.navigationBar.prefersLargeTitles = true
        nav3.navigationBar.prefersLargeTitles = true
        nav4.navigationBar.prefersLargeTitles = true
        
        setViewControllers([nav1, nav2 , nav3,nav4], animated: false)

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
