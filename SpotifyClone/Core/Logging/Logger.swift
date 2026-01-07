//
//  Logger.swift
//  SpotifyClone
//
//  Created for centralized logging
//

import Foundation
import os.log

/// Log levels for different types of messages
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
    
    var prefix: String {
        switch self {
        case .debug: return "🔍 DEBUG"
        case .info: return "ℹ️ INFO"
        case .warning: return "⚠️ WARNING"
        case .error: return "❌ ERROR"
        }
    }
}

/// Centralized logging utility
final class Logger {
    static let shared = Logger()
    
    private let subsystem: String
    private let category = "SpotifyClone"
    private let log: OSLog
    
    #if DEBUG
    private let isDebugMode = true
    #else
    private let isDebugMode = false
    #endif
    
    private init() {
        subsystem = Bundle.main.bundleIdentifier ?? "com.spotifyclone"
        log = OSLog(subsystem: subsystem, category: category)
    }
    
    /// Log a message with specified level
    func log(
        _ message: String,
        level: LogLevel = .info,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "[\(fileName):\(line)] \(function) - \(message)"
        
        // Skip debug logs in release builds
        if level == .debug && !isDebugMode {
            return
        }
        
        // Log to OSLog (visible in Console.app)
        os_log("%{public}@", log: log, type: level.osLogType, logMessage)
        
        #if DEBUG
        // Print to console in debug mode
        print("\(level.prefix) - \(logMessage)")
        #endif
    }
    
    /// Log a debug message
    func debug(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .debug, file: file, function: function, line: line)
    }
    
    /// Log an info message
    func info(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .info, file: file, function: function, line: line)
    }
    
    /// Log a warning message
    func warning(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    
    /// Log an error message
    func error(
        _ message: String,
        error: Error? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        var fullMessage = message
        if let error = error {
            fullMessage += " - Error: \(error.localizedDescription)"
        }
        log(fullMessage, level: .error, file: file, function: function, line: line)
    }
}

