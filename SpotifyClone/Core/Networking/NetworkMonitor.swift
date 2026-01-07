//
//  NetworkMonitor.swift
//  SpotifyClone
//
//  Created for network reachability monitoring
//

import Foundation
import Network

/// Delegate protocol for network status changes
protocol NetworkMonitorDelegate: AnyObject {
    func networkStatusChanged(isConnected: Bool)
}

/// Monitors network connectivity status
final class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.spotifyclone.networkmonitor")
    
    /// Current network connection status
    private(set) var isConnected: Bool = false
    
    /// Delegate to notify about network status changes
    weak var delegate: NetworkMonitorDelegate?
    
    private init() {
        startMonitoring()
    }
    
    /// Start monitoring network connectivity
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            let wasConnected = self?.isConnected ?? false
            self?.isConnected = path.status == .satisfied
            
            // Notify delegate if status changed
            if wasConnected != self?.isConnected {
                DispatchQueue.main.async {
                    self?.delegate?.networkStatusChanged(isConnected: self?.isConnected ?? false)
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    /// Stop monitoring network connectivity
    func stopMonitoring() {
        monitor.cancel()
    }
    
    /// Check if network is currently available
    func checkConnectivity() -> Bool {
        return isConnected
    }
}

