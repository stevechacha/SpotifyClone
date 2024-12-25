//
//  SpotifyCategoriesResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//

//Get Several Browse Categories
//curl --request GET \
//  --url https://api.spotify.com/v1/browse/categories \
//  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
// @GET(browse/categories)

struct SpotifyCategoriesResponse: Codable {
    let categories: Categories
}

struct Categories: Codable {
    let href: String
    let limit: Int
    let next: String?
    let offset: Int
    let previous: String?
    let total: Int
    let items: [CategoryItem]
}

struct CategoryItem: Codable {
    let href: String
    let icons: [APIImage]
    let id: String
    let name: String
}

//curl --request GET \
//--url https://api.spotify.com/v1/browse/categories/dinner \
//--header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
// @Return BaseBrowseCategory
// @Get(https://api.spotify.com/v1/browse/categories/{category_id}

// Define the structure for the browse category
struct BrowseCategory: Codable {
    let href: String
    let icons: [Icon]
    let id: String
    let name: String
}

struct Icon: Codable {
    let url: String
    let height: Int
    let width: Int
}



