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
    private var onRefreshingBlocks = [((String) -> Void)]()

   
    
    // MARK: - Constants
    struct Constants {
        static let clientID = "76a675416313462c92babb568e064676" // Replace with your client ID
        static let clientSecret = "25cb1fc758d14074be471a1c3cb45349" // Replace with your client secret
        static let tokenAPIURL = "https://accounts.spotify.com/api/token"
        static let redirectURI = "http://localhost:3000/callback" // Replace with your registered redirect URI
        
        static let rawScopes = [
            "user-follow-read",
            "user-read-private",
            "user-read-email",
            "playlist-read-private",
            "playlist-modify-public",
            "ugc-image-upload",
            "user-read-recently-played",
            "user-read-playback-state",
            "user-modify-playback-state",
            "user-read-currently-playing",
            "user-library-modify",
            "user-library-read",
            "playlist-read-private",
            "playlist-modify-private",
            "playlist-read-collaborative",
            "playlist-modify-public",
            "user-top-read",
            "app-remote-control",
            "streaming",
            "user-follow-modify",
            "user-read-playback-position",
            "user-modify-playback-state ",
            "user-read-playback-state"
        ]
        
        static let scopes = Array(Set(rawScopes)).joined(separator: " ")
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
        request.setValue("Basic \(createBase64AuthHeader())", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyParameters = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": Constants.redirectURI
        ]
        request.httpBody = bodyParameters.map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        
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
    
    
    
    public func withValidToken(completion: @escaping (String) -> Void) {
        if shouldRefreshToken {
            refreshAccessToken { [weak self] success in
                guard let token = self?.accessToken, success else {
                    print("Error: Unable to refresh token. User might need to reauthenticate.")
                    return
                }
                completion(token)
            }
        } else if let token = accessToken {
            completion(token)
        } else {
            print("Error: No valid token found. Redirecting to login.")
        }
    }
    
    
    // MARK: - Refresh Token
    public func refreshAccessToken(completion: @escaping (Bool) -> Void) {
        guard let refreshToken = self.refreshToken,
              let url = URL(string: Constants.tokenAPIURL),
              shouldRefreshToken else {
            completion(false)
            return
        }
        
        refreshingToken = true
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \(createBase64AuthHeader())", forHTTPHeaderField: "Authorization")
        
        let bodyParameters = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken
        ]
        request.httpBody = bodyParameters.map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            self?.refreshingToken = false
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.onRefreshingBlocks.forEach { $0(result.access_token) }
                self?.onRefreshingBlocks.removeAll()
                self?.cacheToken(result: result)
                completion(true)
            } catch {
                print("Error decoding refresh token response: \(error)")
                completion(false)
            }
        }
        task.resume()
    }
    
    private func createBase64AuthHeader() -> String {
        let basicToken = "\(Constants.clientID):\(Constants.clientSecret)"
        guard let basicData = basicToken.data(using: .utf8) else { return "" }
        return basicData.base64EncodedString()
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
    
    // MARK: - Cache Tokens
    public func signOut(completion: (Bool)->Void ) {
        UserDefaults.standard.setValue(nil, forKey: "access_token")
        UserDefaults.standard.setValue(nil, forKey: "refresh_token")
        UserDefaults.standard.setValue(nil, forKey: "expiration_date")
        
        completion(true)
    }
    
    
    // MARK: - Create API Request
    public func createRequest(
        with url: URL?,
        type: HTTPMethod,
        completion: @escaping (URLRequest) -> Void
    ) {
        withValidToken { token in
            guard let apiURL = url else { return }
            
            var request = URLRequest(url: apiURL)
            request.httpMethod = type.rawValue
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.timeoutInterval = 30
            completion(request)
        }
    }
    
    func performRequest<T: Decodable>(
        url: URL?,
        type: AuthManager.HTTPMethod,
        responseType: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let apiURL = url else {
            completion(.failure(ApiError.invalidURL))
            return
        }
        
        createRequest(with: apiURL, type: type) { request in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                // Handle network error
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                // Check the status code
                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200:
                        break
                    case 404:
                        print("Error: Endpoint not found (404). Please check the URL.")
                        completion(.failure(ApiError.failedToGetData))  // 404 specific handling
                        return
                    default:
                        print("HTTP Status Code: \(httpResponse.statusCode)")
                    }
                }
                
                // Handle empty or invalid response
                guard let data = data else {
                    print("No data received from the server.")
                    completion(.failure(ApiError.failedToGetData))
                    return
                }
                
//                // Print raw response data for debugging
//                if let jsonString = String(data: data, encoding: .utf8) {
//                    print("From AuthManagerapi Raw Response Data: \(jsonString)")
//                }
                do {
                    let decoder = JSONDecoder()
                    let decodedResponse = try decoder.decode(responseType, from: data)
                    completion(.success(decodedResponse))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(error))
                }
            }
            
            task.resume()
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

enum AuthManagerError: Error {
    case invalidURL
    case decodingError(String)
    case failedToGetData
    case tokenRefreshFailed
    case unknown(String)
}

 
