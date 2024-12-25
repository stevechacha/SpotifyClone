//
//  AudioAnalysisResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//


import Foundation



// MARK: - AudioAnalysisResponse
struct AudioAnalysisResponse: Codable {
    let meta: Meta
    let track: AudioAnalysisTrack
    let bars: [Bar]
    let beats: [Beat]
    let sections: [Section]
    let segments: [Segment]
    let tatums: [Tatum]
}

// MARK: - Meta
struct Meta: Codable {
    let analyzerVersion: String
    let platform: String
    let detailedStatus: String
    let statusCode: Int
    let timestamp: Int
    let analysisTime: Double
    let inputProcess: String
    
    enum CodingKeys: String, CodingKey {
        case analyzerVersion = "analyzer_version"
        case platform
        case detailedStatus = "detailed_status"
        case statusCode = "status_code"
        case timestamp
        case analysisTime = "analysis_time"
        case inputProcess = "input_process"
    }
}

// MARK: - Track
struct AudioAnalysisTrack: Codable {
    let numSamples: Int
    let duration: Double
    let sampleMD5: String
    let offsetSeconds: Int
    let windowSeconds: Int
    let analysisSampleRate: Int
    let analysisChannels: Int
    let endOfFadeIn: Double
    let startOfFadeOut: Double
    let loudness: Double
    let tempo: Double
    let tempoConfidence: Double
    let timeSignature: Int
    let timeSignatureConfidence: Double
    let key: Int
    let keyConfidence: Double
    let mode: Int
    let modeConfidence: Double
    let codestring: String
    let codeVersion: Double
    let echoprintstring: String
    let echoprintVersion: Double
    let synchstring: String
    let synchVersion: Int
    let rhythmstring: String
    let rhythmVersion: Int
    
    enum CodingKeys: String, CodingKey {
        case numSamples = "num_samples"
        case duration
        case sampleMD5 = "sample_md5"
        case offsetSeconds = "offset_seconds"
        case windowSeconds = "window_seconds"
        case analysisSampleRate = "analysis_sample_rate"
        case analysisChannels = "analysis_channels"
        case endOfFadeIn = "end_of_fade_in"
        case startOfFadeOut = "start_of_fade_out"
        case loudness, tempo
        case tempoConfidence = "tempo_confidence"
        case timeSignature = "time_signature"
        case timeSignatureConfidence = "time_signature_confidence"
        case key
        case keyConfidence = "key_confidence"
        case mode
        case modeConfidence = "mode_confidence"
        case codestring
        case codeVersion = "code_version"
        case echoprintstring
        case echoprintVersion = "echoprint_version"
        case synchstring
        case synchVersion = "synch_version"
        case rhythmstring
        case rhythmVersion = "rhythm_version"
    }
}

// MARK: - Bar
struct Bar: Codable {
    let start: Double
    let duration: Double
    let confidence: Double
}

// MARK: - Beat
struct Beat: Codable {
    let start: Double
    let duration: Double
    let confidence: Double
}

// MARK: - Section
struct Section: Codable {
    let start: Double
    let duration: Double
    let confidence: Double
    let loudness: Double
    let tempo: Double
    let tempoConfidence: Double
    let key: Int
    let keyConfidence: Double
    let mode: Int
    let modeConfidence: Double
    let timeSignature: Int
    let timeSignatureConfidence: Double
    
    enum CodingKeys: String, CodingKey {
        case start, duration, confidence, loudness, tempo
        case tempoConfidence = "tempo_confidence"
        case key
        case keyConfidence = "key_confidence"
        case mode
        case modeConfidence = "mode_confidence"
        case timeSignature = "time_signature"
        case timeSignatureConfidence = "time_signature_confidence"
    }
}

// MARK: - Segment
struct Segment: Codable {
    let start: Double
    let duration: Double
    let confidence: Double
    let loudnessStart: Double
    let loudnessMax: Double
    let loudnessMaxTime: Double
    let loudnessEnd: Double
    let pitches: [Double]
    let timbre: [Double]
    
    enum CodingKeys: String, CodingKey {
        case start, duration, confidence
        case loudnessStart = "loudness_start"
        case loudnessMax = "loudness_max"
        case loudnessMaxTime = "loudness_max_time"
        case loudnessEnd = "loudness_end"
        case pitches, timbre
    }
}

// MARK: - Tatum
struct Tatum: Codable {
    let start: Double
    let duration: Double
    let confidence: Double
}
