# Code Improvement Examples

This document provides concrete code examples for implementing the recommended improvements.

## 1. AppConfiguration (Centralized Constants)

**File**: `SpotifyClone/Core/Configuration/AppConfiguration.swift`

```swift
import Foundation

enum AppConfiguration {
    enum Spotify {
        static let baseURL = "https://api.spotify.com/v1"
        static let authURL = "https://accounts.spotify.com"
        static let tokenURL = "\(authURL)/api/token"
        
        static var clientID: String {
            guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
                  let plist = NSDictionary(contentsOfFile: path) as? [String: Any],
                  let id = plist["SpotifyClientID"] as? String, !id.isEmpty else {
                fatalError("SpotifyClientID not found in Config.plist")
            }
            return id
        }
        
        static var clientSecret: String {
            guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
                  let plist = NSDictionary(contentsOfFile: path) as? [String: Any],
                  let secret = plist["SpotifyClientSecret"] as? String, !secret.isEmpty else {
                fatalError("SpotifyClientSecret not found in Config.plist")
            }
            return secret
        }
        
        static var redirectURI: String {
            guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
                  let plist = NSDictionary(contentsOfFile: path) as? [String: Any],
                  let uri = plist["SpotifyRedirectURI"] as? String else {
                return "http://localhost:3000/callback"
            }
            return uri
        }
    }
    
    enum UserDefaultsKeys {
        static let accessToken = "access_token"
        static let refreshToken = "refresh_token"
        static let expirationDate = "expiration_date"
    }
    
    enum Cache {
        static let maxMemorySize = 50 * 1024 * 1024 // 50MB
        static let maxDiskSize = 200 * 1024 * 1024 // 200MB
        static let expirationInterval: TimeInterval = 3600 // 1 hour
    }
}
```

## 2. NetworkMonitor (Network Reachability)

**File**: `SpotifyClone/Core/Networking/NetworkMonitor.swift`

```swift
import Foundation
import Network

protocol NetworkMonitorDelegate: AnyObject {
    func networkStatusChanged(isConnected: Bool)
}

final class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    private(set) var isConnected: Bool = false
    weak var delegate: NetworkMonitorDelegate?
    
    private init() {
        startMonitoring()
    }
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            let wasConnected = self?.isConnected ?? false
            self?.isConnected = path.status == .satisfied
            
            if wasConnected != self?.isConnected {
                DispatchQueue.main.async {
                    self?.delegate?.networkStatusChanged(isConnected: self?.isConnected ?? false)
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}
```

## 3. Enhanced DataCache with Expiration

**File**: `SpotifyClone/Core/Cache/DataCache.swift`

```swift
import Foundation

struct CachedItem<T: Codable> {
    let data: T
    let expirationDate: Date
    
    var isExpired: Bool {
        Date() > expirationDate
    }
}

final class DataCache {
    static let shared = DataCache()
    
    private let memoryCache = NSCache<NSString, NSData>()
    private let diskCacheURL: URL
    private let fileManager = FileManager.default
    
    private init() {
        // Configure memory cache
        memoryCache.countLimit = 100
        memoryCache.totalCostLimit = 50 * 1024 * 1024 // 50MB
        
        // Setup disk cache directory
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        diskCacheURL = cacheDirectory.appendingPathComponent("SpotifyCache")
        
        try? fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
    }
    
    func cache<T: Codable>(_ item: T, forKey key: String, expirationInterval: TimeInterval = AppConfiguration.Cache.expirationInterval) {
        let expirationDate = Date().addingTimeInterval(expirationInterval)
        let cachedItem = CachedItem(data: item, expirationDate: expirationDate)
        
        // Memory cache
        if let data = try? JSONEncoder().encode(cachedItem) {
            memoryCache.setObject(data as NSData, forKey: key as NSString)
        }
        
        // Disk cache
        let fileURL = diskCacheURL.appendingPathComponent(key)
        if let data = try? JSONEncoder().encode(cachedItem) {
            try? data.write(to: fileURL)
        }
    }
    
    func retrieve<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        // Check memory cache first
        if let memoryData = memoryCache.object(forKey: key as NSString) as Data?,
           let cachedItem = try? JSONDecoder().decode(CachedItem<T>.self, from: memoryData),
           !cachedItem.isExpired {
            return cachedItem.data
        }
        
        // Check disk cache
        let fileURL = diskCacheURL.appendingPathComponent(key)
        if let diskData = try? Data(contentsOf: fileURL),
           let cachedItem = try? JSONDecoder().decode(CachedItem<T>.self, from: diskData),
           !cachedItem.isExpired {
            // Restore to memory cache
            memoryCache.setObject(diskData as NSData, forKey: key as NSString)
            return cachedItem.data
        }
        
        return nil
    }
    
    func remove(forKey key: String) {
        memoryCache.removeObject(forKey: key as NSString)
        let fileURL = diskCacheURL.appendingPathComponent(key)
        try? fileManager.removeItem(at: fileURL)
    }
    
    func clearAll() {
        memoryCache.removeAllObjects()
        try? fileManager.removeItem(at: diskCacheURL)
        try? fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
    }
}
```

## 4. Protocol-Based Dependency Injection

**File**: `SpotifyClone/Core/Networking/AuthManagerProtocol.swift`

```swift
import Foundation

protocol AuthManagerProtocol {
    var isSignedIn: Bool { get }
    var accessToken: String? { get }
    var signInURL: URL? { get }
    
    func exchangeCodeForToken(code: String, completion: @escaping (Bool) -> Void)
    func refreshAccessToken(completion: @escaping (Bool) -> Void)
    func withValidToken(completion: @escaping (String) -> Void)
    func signOut(completion: (Bool) -> Void)
    func createRequest(with url: URL?, type: HTTPMethod, completion: @escaping (URLRequest) -> Void)
}

extension AuthManager: AuthManagerProtocol {}

// In tests, create a mock:
class MockAuthManager: AuthManagerProtocol {
    var isSignedIn: Bool = true
    var accessToken: String? = "mock_token"
    var signInURL: URL? = URL(string: "https://example.com")
    
    func exchangeCodeForToken(code: String, completion: @escaping (Bool) -> Void) {
        completion(true)
    }
    
    func refreshAccessToken(completion: @escaping (Bool) -> Void) {
        completion(true)
    }
    
    func withValidToken(completion: @escaping (String) -> Void) {
        completion("mock_token")
    }
    
    func signOut(completion: (Bool) -> Void) {
        completion(true)
    }
    
    func createRequest(with url: URL?, type: HTTPMethod, completion: @escaping (URLRequest) -> Void) {
        var request = URLRequest(url: url!)
        request.setValue("Bearer mock_token", forHTTPHeaderField: "Authorization")
        completion(request)
    }
}
```

## 5. Enhanced Error Handling with User Messages

**File**: `SpotifyClone/Core/Error/UserFriendlyError.swift`

```swift
import Foundation

extension ApiError {
    var userMessage: String {
        switch self {
        case .code:
            return "Authentication failed. Please try logging in again."
        case .tokenNotFound:
            return "Your session has expired. Please log in again."
        case .invalidInput:
            return "Invalid input. Please check your search and try again."
        case .invalidURL:
            return "Something went wrong. Please try again."
        case .failedToGetData:
            return "Unable to load data. Please check your internet connection."
        case .decodeError:
            return "Unable to process the response. Please try again."
        case .rateLimitExceeded:
            return "Too many requests. Please wait a moment and try again."
        case .invalidResponse(let statusCode):
            switch statusCode {
            case 401:
                return "Your session has expired. Please log in again."
            case 403:
                return "You don't have permission to access this."
            case 404:
                return "The requested item was not found."
            case 429:
                return "Too many requests. Please wait a moment."
            case 500...599:
                return "Server error. Please try again later."
            default:
                return "Something went wrong. Please try again."
            }
        default:
            return "An unexpected error occurred. Please try again."
        }
    }
    
    var recoveryAction: String? {
        switch self {
        case .tokenNotFound, .code:
            return "Log In"
        case .failedToGetData:
            return "Retry"
        case .rateLimitExceeded:
            return "Wait"
        default:
            return nil
        }
    }
}
```

## 6. Logging Framework Wrapper

**File**: `SpotifyClone/Core/Logging/Logger.swift`

```swift
import Foundation
import os.log

enum LogLevel {
    case debug
    case info
    case warning
    case error
    
    var osLogType: OSLogType {
        switch self {
        case .debug: return .debug
        case .info: return .info
        case .warning: return .default
        case .error: return .error
        }
    }
}

final class Logger {
    static let shared = Logger()
    
    private let subsystem = Bundle.main.bundleIdentifier ?? "com.spotifyclone"
    private let category = "SpotifyClone"
    private let log: OSLog
    
    #if DEBUG
    private let isDebugMode = true
    #else
    private let isDebugMode = false
    #endif
    
    private init() {
        log = OSLog(subsystem: subsystem, category: category)
    }
    
    func log(_ message: String, level: LogLevel = .info, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "[\(fileName):\(line)] \(function) - \(message)"
        
        if level == .debug && !isDebugMode {
            return // Skip debug logs in release
        }
        
        os_log("%{public}@", log: log, type: level.osLogType, logMessage)
        
        #if DEBUG
        print("\(level) - \(logMessage)")
        #endif
    }
    
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }
    
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line)
    }
    
    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    
    func error(_ message: String, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        var fullMessage = message
        if let error = error {
            fullMessage += " - Error: \(error.localizedDescription)"
        }
        log(fullMessage, level: .error, file: file, function: function, line: line)
    }
}
```

## 7. Retry Strategy for API Calls

**File**: `SpotifyClone/Core/Networking/RetryStrategy.swift`

```swift
import Foundation

struct RetryConfiguration {
    let maxRetries: Int
    let baseDelay: TimeInterval
    let maxDelay: TimeInterval
    let multiplier: Double
    
    static let `default` = RetryConfiguration(
        maxRetries: 3,
        baseDelay: 1.0,
        maxDelay: 30.0,
        multiplier: 2.0
    )
}

extension SpotifyAPIClient {
    func sendWithRetry<T: Decodable>(
        _ endpoint: Endpoint,
        configuration: RetryConfiguration = .default,
        decoder customDecoder: JSONDecoder? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        send(endpoint, decoder: customDecoder) { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure(let error):
                if let apiError = error as? ApiError,
                   case .rateLimitExceeded = apiError,
                   configuration.maxRetries > 0 {
                    // Retry with exponential backoff
                    let delay = min(
                        configuration.baseDelay * pow(configuration.multiplier, Double(configuration.maxRetries)),
                        configuration.maxDelay
                    )
                    
                    DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                        var newConfig = configuration
                        newConfig = RetryConfiguration(
                            maxRetries: configuration.maxRetries - 1,
                            baseDelay: configuration.baseDelay,
                            maxDelay: configuration.maxDelay,
                            multiplier: configuration.multiplier
                        )
                        self?.sendWithRetry(endpoint, configuration: newConfig, decoder: customDecoder, completion: completion)
                    }
                } else {
                    completion(result)
                }
            }
        }
    }
}
```

## 8. Example Unit Test

**File**: `SpotifyCloneTests/AuthManagerTests.swift`

```swift
import XCTest
@testable import SpotifyClone

final class AuthManagerTests: XCTestCase {
    var authManager: AuthManager!
    var mockUserDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        mockUserDefaults = UserDefaults(suiteName: "test")!
        // Use dependency injection if possible, or test the singleton
        authManager = AuthManager.shared
    }
    
    override func tearDown() {
        mockUserDefaults.removePersistentDomain(forName: "test")
        super.tearDown()
    }
    
    func testIsSignedIn_WithValidToken_ReturnsTrue() {
        // Given
        mockUserDefaults.set("test_token", forKey: "access_token")
        
        // When
        let isSignedIn = authManager.isSignedIn
        
        // Then
        XCTAssertTrue(isSignedIn)
    }
    
    func testIsSignedIn_WithoutToken_ReturnsFalse() {
        // Given
        mockUserDefaults.removeObject(forKey: "access_token")
        
        // When
        let isSignedIn = authManager.isSignedIn
        
        // Then
        XCTAssertFalse(isSignedIn)
    }
    
    func testShouldRefreshToken_WhenExpired_ReturnsTrue() {
        // Given
        let expiredDate = Date().addingTimeInterval(-600) // 10 minutes ago
        mockUserDefaults.set(expiredDate, forKey: "expiration_date")
        
        // When
        // Note: This requires exposing shouldRefreshToken or testing indirectly
        // through withValidToken
        
        // Then
        // Assert expected behavior
    }
}
```

## 9. Removing UI from API Layer

**Before** (ChapterApiCaller.swift):
```swift
if httpResponse.statusCode == 429 {
    DispatchQueue.main.async {
        let alert = UIAlertController(...)
        viewController.present(alert, animated: true)
    }
}
```

**After**:
```swift
if httpResponse.statusCode == 429 {
    if let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After") {
        let error = ApiError.rateLimitExceeded(retryAfter: retryAfter)
        completion(.failure(error))
        return
    }
}
```

Then handle in ViewController:
```swift
apiCaller.fetch(...) { result in
    switch result {
    case .success(let data):
        // Handle success
    case .failure(let error):
        if case ApiError.rateLimitExceeded(let retryAfter) = error {
            self.showRateLimitAlert(retryAfter: retryAfter)
        } else {
            self.showError(error)
        }
    }
}
```

---

These examples provide concrete patterns you can follow to implement the recommended improvements. Start with the critical items and work your way through the priority list.

