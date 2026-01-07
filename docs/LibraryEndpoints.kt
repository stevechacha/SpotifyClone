// Library API Endpoints, Models, and DTOs in Kotlin
// Based on SpotifyClone iOS project

package com.spotifyclone.api.library

import com.google.gson.annotations.SerializedName
import io.ktor.client.HttpClient
import io.ktor.client.call.body
import io.ktor.client.request.get
import io.ktor.client.request.header

// ============================================================================
// API ENDPOINTS
// ============================================================================

object LibraryEndpoints {
    const val BASE_URL = "https://api.spotify.com/v1"
    
    // Get User's Saved Albums
    const val GET_USER_SAVED_ALBUMS = "$BASE_URL/me/albums"
    
    // Get Current User's Playlists
    const val GET_CURRENT_USER_PLAYLISTS = "$BASE_URL/me/playlists"
    
    // Get User's Saved Podcasts/Shows
    const val GET_USER_SAVED_SHOWS = "$BASE_URL/me/shows"
    
    // Get User's Saved Episodes
    const val GET_USER_SAVED_EPISODES = "$BASE_URL/me/episodes"
}

// ============================================================================
// API SERVICE
// ============================================================================

class LibraryApiService(
    private val client: HttpClient,
    private val baseUrl: String = LibraryEndpoints.BASE_URL
) {
    /**
     * Get User's Saved Albums
     * GET /me/albums
     */
    suspend fun getUserSavedAlbums(
        accessToken: String
    ): SpotifyUsersAlbumSavedResponse {
        return client.get("$baseUrl/me/albums") {
            header("Authorization", "Bearer $accessToken")
        }.body()
    }

    /**
     * Get Current User's Playlists
     * GET /me/playlists
     */
    suspend fun getCurrentUserPlaylists(
        accessToken: String
    ): CurrentUsersPlaylistsResponse {
        return client.get("$baseUrl/me/playlists") {
            header("Authorization", "Bearer $accessToken")
        }.body()
    }

    /**
     * Get User's Saved Podcasts/Shows
     * GET /me/shows
     */
    suspend fun getUserSavedShows(
        accessToken: String
    ): UsersSavedShows {
        return client.get("$baseUrl/me/shows") {
            header("Authorization", "Bearer $accessToken")
        }.body()
    }

    /**
     * Get User's Saved Episodes
     * GET /me/episodes
     */
    suspend fun getUserSavedEpisodes(
        accessToken: String
    ): UserSavedEpisodesResponse {
        return client.get("$baseUrl/me/episodes") {
            header("Authorization", "Bearer $accessToken")
        }.body()
    }
}

// ============================================================================
// RESPONSE DTOs
// ============================================================================

// MARK: - Get User's Saved Albums Response
data class SpotifyUsersAlbumSavedResponse(
    val href: String?,
    val items: List<SpotifyUsersAlbumSavedItemResponse>,
    val limit: Int?,
    val next: String?,
    val offset: Int?,
    val previous: String?,
    val total: Int?
)

data class SpotifyUsersAlbumSavedItemResponse(
    @SerializedName("added_at")
    val addedAt: String,
    val album: Album?
)

// MARK: - Get Current User's Playlists Response
data class CurrentUsersPlaylistsResponse(
    val href: String?,
    val limit: Int?,
    val next: String?,
    val offset: Int?,
    val previous: String?,
    val total: Int?,
    val items: List<PlaylistItem>?
)

// MARK: - Get User's Saved Shows/Podcasts Response
data class UsersSavedShows(
    val href: String,
    val limit: Int,
    val next: String?,
    val offset: Int,
    val previous: String?,
    val total: Int?,
    val items: List<UsersSavedShowsItems>?
)

data class UsersSavedShowsItems(
    @SerializedName("added_at")
    val addedAt: String,
    val show: Show
)

// MARK: - Get User's Saved Episodes Response
data class UserSavedEpisodesResponse(
    val href: String?,
    val limit: Int?,
    val next: String?,
    val offset: Int?,
    val previous: String?,
    val total: Int?,
    val items: List<UserSavedEpisode>?
)

data class UserSavedEpisode(
    @SerializedName("added_at")
    val addedAt: String?,
    val episode: Episode?
)

// ============================================================================
// MODEL CLASSES
// ============================================================================

// MARK: - Album Model
data class Album(
    @SerializedName("album_type")
    val albumType: String?,
    @SerializedName("total_tracks")
    val totalTracks: Int?,
    @SerializedName("available_markets")
    val availableMarkets: List<String>?,
    @SerializedName("external_urls")
    val externalUrls: ExternalUrls?,
    val href: String?,
    val id: String?,
    val images: List<APIImage>?,
    val name: String?,
    @SerializedName("release_date")
    val releaseDate: String?,
    @SerializedName("release_date_precision")
    val releaseDatePrecision: String?,
    val restrictions: Restrictions?,
    val type: String?,
    val uri: String?,
    val artists: List<Artist>?,
    val tracks: Tracks?,
    val copyrights: List<Copyright>?,
    @SerializedName("external_ids")
    val externalIds: ExternalIDs?,
    val genres: List<String>?,
    val label: String?,
    val popularity: Int?
)

// MARK: - PlaylistItem Model
data class PlaylistItem(
    val collaborative: Boolean?,
    val description: String?,
    @SerializedName("external_urls")
    val externalUrls: ExternalURLs?,
    val followers: Followers?,
    val href: String?,
    val id: String?,
    val images: List<APIImage>?,
    val name: String?,
    val owner: Owner?,
    @SerializedName("public")
    val publicAccess: Boolean?,
    @SerializedName("snapshot_id")
    val snapshotID: String?,
    val tracks: Tracks?,
    val type: String?,
    val uri: String?
)

// MARK: - Show Model (Podcast)
data class Show(
    @SerializedName("available_markets")
    val availableMarkets: List<String>?,
    val copyrights: List<Copyright>?,
    val description: String?,
    @SerializedName("html_description")
    val htmlDescription: String?,
    val explicit: Boolean?,
    @SerializedName("external_urls")
    val externalUrls: ExternalUrls?,
    val href: String?,
    val id: String?,
    val images: List<APIImage>?,
    @SerializedName("is_externally_hosted")
    val isExternallyHosted: Boolean?,
    val languages: List<String>?,
    @SerializedName("media_type")
    val mediaType: String?,
    val name: String?,
    val publisher: String?,
    val type: String?,
    val uri: String?,
    @SerializedName("total_episodes")
    val totalEpisodes: Int?
)

// MARK: - Episode Model
data class Episode(
    @SerializedName("audio_preview_url")
    val audioPreviewURL: String?,
    val description: String?,
    @SerializedName("html_description")
    val htmlDescription: String?,
    @SerializedName("duration_ms")
    val durationMs: Int?,
    val explicit: Boolean?,
    @SerializedName("external_urls")
    val externalURLs: ExternalURLs?,
    val href: String?,
    val id: String?,
    val images: List<APIImage>?,
    @SerializedName("is_externally_hosted")
    val isExternallyHosted: Boolean?,
    @SerializedName("is_playable")
    val isPlayable: Boolean?,
    val language: String?,
    val languages: List<String>?,
    val name: String?,
    @SerializedName("release_date")
    val releaseDate: String?,
    @SerializedName("release_date_precision")
    val releaseDatePrecision: String?,
    @SerializedName("resume_point")
    val resumePoint: ResumePoint?,
    val type: String?,
    val uri: String?,
    val restrictions: Restrictions?,
    val show: Show?
)

// ============================================================================
// SUPPORTING MODELS
// ============================================================================

data class ExternalUrls(
    val spotify: String?
)

data class ExternalURLs(
    val spotify: String?
)

data class APIImage(
    val url: String?,
    val height: Int?,
    val width: Int?
)

data class Restrictions(
    val reason: String?
)

data class Artist(
    val externalUrls: ExternalUrls?,
    val href: String?,
    val id: String?,
    val name: String?,
    val type: String?,
    val uri: String?
)

data class Tracks(
    val href: String?,
    val limit: Int?,
    val next: String?,
    val offset: Int?,
    val previous: String?,
    val total: Int?,
    val items: List<Track>?
)

data class Track(
    val id: String?,
    val name: String?,
    val artists: List<Artist>?,
    val album: Album?,
    val durationMs: Int?,
    val explicit: Boolean?,
    val previewUrl: String?,
    val uri: String?
)

data class Copyright(
    val text: String?,
    val type: String?
)

data class ExternalIDs(
    val isrc: String?,
    val ean: String?,
    val upc: String?
)

data class Followers(
    val href: String?,
    val total: Int?
)

data class Owner(
    val externalUrls: ExternalUrls?,
    val followers: Followers?,
    val href: String?,
    val id: String?,
    val type: String?,
    val uri: String?,
    val displayName: String?
)

data class ResumePoint(
    @SerializedName("fully_played")
    val fullyPlayed: Boolean?,
    @SerializedName("resume_position_ms")
    val resumePositionMS: Int?
)

