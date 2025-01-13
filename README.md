# SpotifyClone

# Spotify Clone App

This is a **Spotify Clone App** built using **Swift** and **UIKit**, designed to replicate the core features and functionality of the Spotify music streaming platform. This project demonstrates a clean architecture, modular design, and integration with modern iOS development practices.

## Features

- **User Authentication**

  - Login with Spotify API integration
  - Secure user authentication flows

- **Browse and Search**

  - Explore curated playlists, albums, and categories
  - Search for artists, albums, tracks, shows, and episodes

- **Music Playback**

  - Stream songs in-app
  - Playback controls (play, pause, skip, rewind)

- **User Library**

  - Save favorite tracks, albums, playlists, and shows
  - Access recently played items

- **Dynamic UI**

  - Adaptive layouts for iPhone and iPad
  - Dark mode support

## Technologies Used

- **Language**: Swift
- **Framework**: UIKit
- **Networking**: URLSession, Spotify Web API
- **Persistence**: UserDefaults/CoreData
- **Dependency Management**: CocoaPods/Swift Package Manager (SPM)
- **Version Control**: Git

## Requirements

- iOS 15.0+
- Xcode 14+
- Spotify Developer Account

## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/stevechacha/SpotifyClone.git
   cd SpotifyClone
   ```

2. Install dependencies:

   - If using CocoaPods:
     ```bash
     pod install
     ```
   - If using Swift Package Manager, dependencies will resolve automatically when you open the project in Xcode.

3. Set up Spotify API:

   - Create a developer account at [Spotify Developer Dashboard](https://developer.spotify.com/dashboard/).
   - Create a new app and retrieve your **Client ID** and **Client Secret**.
   - Add your redirect URI in the Spotify app settings (e.g., `spotify-clone://callback`).
   - Update the app configuration with your credentials.

4. Open the project in Xcode:

   ```bash
   open SpotifyClone.xcworkspace
   ```

5. Build and run the app on a simulator or device.

## Project Structure

- **Models**: Data structures and API response models
- **Views**: UIKit components for UI rendering
- **ViewModels**: Handles data binding and business logic
- **Controllers**: Manage views and user interaction
- **Services**: API calls and networking logic

## Screenshots

![Home Screen](https://via.placeholder.com/400x800.png?text=Home+Screen)
![Search Screen](https://via.placeholder.com/400x800.png?text=Search+Screen)
![Playback Screen](https://via.placeholder.com/400x800.png?text=Playback+Screen)

## Contributing

Contributions are welcome! To contribute:

1. Fork the repository
2. Create a new branch (`git checkout -b feature/your-feature-name`)
3. Commit your changes (`git commit -m 'Add some feature'`)
4. Push to the branch (`git push origin feature/your-feature-name`)
5. Open a Pull Request

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.

## Acknowledgments

- [Spotify Web API Documentation](https://developer.spotify.com/documentation/web-api/)
- [UIKit Documentation](https://developer.apple.com/documentation/uikit/)

---

