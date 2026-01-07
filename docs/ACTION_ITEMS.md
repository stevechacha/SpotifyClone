# Action Items - Priority Checklist

## 🔴 Critical (Do First - This Week)

- [ ] **Fix SpotifyAPIClient** - Verify it compiles and works correctly
- [ ] **Remove UI code from API layer** - Remove `UIAlertController` from `ChapterApiCaller` and `AlbumApi`
- [ ] **Migrate API managers to SpotifyAPIClient** - Start with `TrackApi`, `PlaylistApi`, `SearchApi`
- [ ] **Fix token refresh race condition** - Improve `AuthManager.withValidToken`

## 🟡 High Priority (Next 2 Weeks)

- [ ] **Add unit tests** - Start with `AuthManager` and `SpotifyAPIClient` (target: 10 tests)
- [ ] **Implement proper caching** - Enhance `DataCache` with expiration and image caching
- [ ] **Add NetworkMonitor** - Check network availability before requests
- [ ] **Standardize error handling** - Use `Result<T, Error>` everywhere
- [ ] **Create AppConfiguration** - Centralize all constants and URLs

## 🟢 Medium Priority (Next Month)

- [ ] **Reorganize features** - Move to `Features/` structure
- [ ] **Add dependency injection** - Create protocols for managers
- [ ] **Add logging framework** - Replace `print()` statements
- [ ] **Add SwiftLint** - Enforce code style
- [ ] **Audit memory leaks** - Check all closures for retain cycles

## 🔵 Features (Ongoing)

- [ ] **Mini Player** - Persistent bottom player
- [ ] **Queue Management** - View and manage playback queue
- [ ] **Offline Downloads** - Download for offline playback
- [ ] **Widget Support** - Home screen widgets

## 📝 Quick Wins (Can do today)

- [ ] Add SwiftLint configuration (30 min)
- [ ] Create `AppConfiguration.swift` (1 hour)
- [ ] Add basic `NetworkMonitor` (2 hours)
- [ ] Write 3 unit tests for `AuthManager` (2 hours)
- [ ] Remove UI code from `ChapterApiCaller` (30 min)

---

**Total Estimated Time for Critical Items**: ~16 hours
**Total Estimated Time for High Priority**: ~40 hours
**Total Estimated Time for Medium Priority**: ~60 hours

