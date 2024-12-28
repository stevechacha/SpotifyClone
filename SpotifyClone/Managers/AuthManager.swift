//
//  AuthManager.swift
//  SpotifyClone
//
//  Created by stephen chacha on 04/12/2024.
//
import Foundation

final class AuthManager {
    static let shared = AuthManager()
    private var refreshingToken = false
    
    // MARK: - Constants
    struct Constants {
        static let clientID = "76a675416313462c92babb568e064676"
        static let clientSecret = "25cb1fc758d14074be471a1c3cb45349" // Replace with your client secret
        static let tokenAPIURL = "https://accounts.spotify.com/api/token"
        static let redirectURI = "http://localhost:3000/callback" // Replace with your registered redirect URI
        static let scopes = [
            "user-read-private",
            "user-read-email",
            "playlist-read-private",
            "playlist-modify-public",
            "user-library-read",
            "user-top-read",
            "streaming"
        ].joined(separator: " ")
        
    }
    
    private init() {}
    
    // MARK: - Computed Property
    var isSignedIn: Bool {
        return accessToken != nil
    }
    
    
    // MARK: - Variables
    public var accessToken: String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
    
    private var refreshToken: String? {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    private var tokenExpirationDate: Date? {
        return UserDefaults.standard.object(forKey: "expiration_date") as? Date
    }
    
    private var shouldRefreshToken: Bool {
        guard let expirationDate = tokenExpirationDate else { return false }
        let currentTime = Date()
        let fiveMinutesBeforeExpiration = expirationDate.addingTimeInterval(-300) // 5 minutes early
        return currentTime >= fiveMinutesBeforeExpiration
    }


    
    public var signInURL: URL? {
        let base = "https://accounts.spotify.com/authorize"
        
        var components = URLComponents(string: base)
        components?.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: Constants.clientID),
            URLQueryItem(name: "scope", value: Constants.scopes),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "show_dialog", value: "TRUE")
        ]
        
        return components?.url
    }
    
    
    // MARK: - Exchange Code for Token
    public func exchangeCodeForToken(code: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: Constants.tokenAPIURL) else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let basicToken = "\(Constants.clientID):\(Constants.clientSecret)"
        guard let basicData = basicToken.data(using: .utf8) else {
            completion(false)
            return
        }
        let base64String = basicData.base64EncodedString()
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        let bodyParameters = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": Constants.redirectURI
        ]
        request.httpBody = bodyParameters.map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.cacheToken(result: result)
                completion(true)
            } catch {
                print("Error decoding token response: \(error.localizedDescription)")
                completion(false)
            }
        }
        task.resume()
    }
    
    private var onRefreshingBlocks = [((String) -> Void)]()
    
   

        
    public func withValidToken(completion: @escaping (String) -> Void) {
        guard !refreshingToken else {
            onRefreshingBlocks.append(completion)
            return
        }
        
        if shouldRefreshToken {
            refreshAccessToken { [weak self] success in
                if let token = self?.accessToken, success {
                    completion(token)
                }
            }
        } else if let token = accessToken {
            completion(token)
        }
    }

    
    public func withvalidToken(completion: @escaping (String) -> Void){
        guard !refreshingToken else {
            onRefreshingBlocks.append(completion)
            return
        }
        if shouldRefreshToken {
            refreshAccessToken { [weak self] success in
                if let token = self?.accessToken , success {
                    completion(token)
                }
            }
        }
        else if let token = accessToken {
            completion(token)
        }
    }
    
    
    // MARK: - Refresh Token
    public func refreshIfNeed(completion: @escaping (Bool) -> Void) {
        guard !refreshingToken else { return }
//        guard shouldRefreshToken,
//              let refreshToken = self.refreshToken,
//              let url = URL(string: Constants.tokenAPIURL) else {
//            completion(false)
//            return
//        }
        
        guard let refreshToken = self.refreshToken else { return }
        
        guard let url = URL(string: Constants.tokenAPIURL) else { return }
        
        refreshingToken = true
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let bodyParameters = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken
        ]
        request.httpBody = bodyParameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&").data(using: .utf8)

        let basicToken = "\(Constants.clientID):\(Constants.clientSecret)"
        guard let basicData = basicToken.data(using: .utf8) else {
            completion(false)
            return
        }
        let base64String = basicData.base64EncodedString()
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")

        
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            self?.refreshingToken = false
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.onRefreshingBlocks.forEach { $0(result.access_token)}
                self?.onRefreshingBlocks.removeAll()
                self?.cacheToken(result: result)
                completion(true)
            } catch {
                print("Error decoding refresh token response: \(error.localizedDescription)")
                completion(false)
            }
        }
        task.resume()
    }
    
    
    // MARK: - Refresh Token
    public func refreshAccessToken(completion: @escaping (Bool) -> Void) {
        guard shouldRefreshToken,
              let refreshToken = self.refreshToken,
              let url = URL(string: Constants.tokenAPIURL) else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let basicToken = "\(Constants.clientID):\(Constants.clientSecret)"
        guard let basicData = basicToken.data(using: .utf8) else {
            completion(false)
            return
        }
        let base64String = basicData.base64EncodedString()
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        let bodyParameters = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken
        ]
        request.httpBody = bodyParameters.map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.cacheToken(result: result)
                completion(true)
            } catch {
                print("Error decoding refresh token response: \(error.localizedDescription)")
                completion(false)
            }
        }
        task.resume()
    }
    
    // MARK: - Cache Tokens
    private func cacheToken(result: AuthResponse) {
        UserDefaults.standard.setValue(result.access_token, forKey: "access_token")
        if let refreshToken = result.refresh_token {
            UserDefaults.standard.setValue(refreshToken, forKey: "refresh_token")
        }
        let expirationDate = Date().addingTimeInterval(TimeInterval(result.expires_in))
        UserDefaults.standard.setValue(expirationDate, forKey: "expiration_date")
    }
    
    public func getCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        AuthManager.shared.createRequest(with: URL(string: "https://api.spotify.com/v1/me"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
                do {
                    let userProfile = try JSONDecoder().decode(UserProfile.self, from: data)
                    completion(.success(userProfile))
                } catch {
                    print("Error decoding user profile: \(error)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }

    
    // MARK: - Create API Request
    public func createRequest(
        with url: URL?,
        type: HTTPMethod,
        completion: @escaping (URLRequest) -> Void
    ) {
        AuthManager.shared.withvalidToken { token in
            guard let apiURL = url else { return }
            
            var request = URLRequest(url: apiURL)
            request.httpMethod = type.rawValue
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.timeoutInterval = 30
            completion(request)
        }
    }
    

    enum HTTPMethod : String {
        case GET
        case POST
        case PUT
        case DELETE
    }
}

// MARK: - AuthResponse Model
struct AuthResponse: Codable {
    let access_token: String
    let expires_in: Int
    let refresh_token: String?
    let scope: String
    let token_type: String
}

 
