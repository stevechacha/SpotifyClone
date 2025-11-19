# Structure Review

## Current Observations
- The project relies on the folder-per-feature approach inside `ViewControllers`, but shared infrastructure (errors, networking helpers, extensions) lives in disparate places (`Resources`, `Managers`).
- API callers duplicate request construction, JSON decoding, and even UI-alert logic, which makes behaviour inconsistent and hard to maintain.
- Models occasionally embed cross-cutting types (e.g. `ApiError` previously lived inside `UserProfile`), which makes discovery and reuse difficult.
- There is no central documentation describing how a new feature should be laid out (views vs. controllers vs. view models), so the tree is growing organically with subtle naming and casing differences.

## Improvements in this pass
- Introduced a `Core` namespace with `Core/Error/ApiError.swift` and `Core/Networking` to host shared infrastructure.
- Added an `Endpoint` protocol plus a concrete `SpotifyAPIClient` so authenticated requests are centralised, including HTTP error handling and rate-limit propagation.
- Replaced the placeholder `SpotifyEndpoint` file with an enum that conforms to `Endpoint` and captures artist/search endpoints declaratively.
- Refactored `ArtistApiCaller` to consume the shared client, removing duplicate networking code and UIKit dependencies from the API layer.

## Recommended Next Steps
1. **Adopt the Core layer broadly** – migrate other API managers (albums, playlists, chapters, tracks, etc.) to the shared client and add dedicated endpoint cases. This will significantly reduce request boilerplate.
2. **Feature pods/modules** – group each feature (Home, Search, Library, Player, etc.) under a `Features/<FeatureName>/` root that contains its `Views`, `ViewModels`, and `Controllers`. This keeps feature code collocated and makes it easier to move into Swift Packages later.
3. **Split shared UI components** – move `CustomView`, `Extensions`, and similar assets under `Core/UI` with subfolders for `Components`, `Styling`, and `Extensions` to make reuse explicit.
4. **Configuration management** – extract secrets (`clientID`, `clientSecret`) into an xcconfig/plist that is gitignored, and load via a `Configuration` type inside `Core/Environment`.
5. **Testing scaffolding** – add snapshot/unit test targets per feature plus mocks for the `SpotifyAPIClient` so business logic can be exercised without hitting the network.

> Tip: once the Core/Features split is complete, consider wrapping each feature as a Swift Package. That keeps Xcode projects lean and improves compile times.

## Feature Roadmap

See [FEATURE_SUGGESTIONS.md](./FEATURE_SUGGESTIONS.md) for a comprehensive list of features that can be added to enhance the app, including:
- Core music features (queue, lyrics, offline downloads)
- Discovery & recommendations
- Social features
- Platform integrations (Widgets, CarPlay, Apple Watch)
- UI/UX enhancements

## Immediate Actionable Improvements

### Quick Wins (1-2 days each)
1. **Mini Player** - Add persistent mini player at bottom when music is playing
2. **Heart/Like Button** - Add like functionality to tracks, albums, playlists
3. **Shuffle & Repeat Controls** - Enhance player with shuffle/repeat toggles
4. **Search Filters** - Add filter buttons (Tracks, Artists, Albums, Playlists)
5. **Sort Options** - Add sort functionality to playlists/library

### Medium Effort (3-5 days each)
1. **Queue Management** - View and manage playback queue
2. **Recently Played Enhancement** - Better UI and filtering for recently played
3. **Offline Downloads** - Download playlists/albums for offline playback
4. **Statistics Dashboard** - Show top tracks/artists/genres
5. **Widget Support** - Home screen widgets for Now Playing

### High Value Features (1-2 weeks each)
1. **Lyrics Display** - Show lyrics for currently playing track
2. **Enhanced Recommendations** - Daily Mix, Discover Weekly integration
3. **Social Features** - Follow users, see friend activity
4. **Playlist Collaboration** - Collaborative playlist editing
5. **CarPlay Support** - Full CarPlay integration
