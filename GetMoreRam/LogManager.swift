//
//  LogManager.swift
//  GetMoreRam
//
//  Created on 2026-10-07.
//

import Foundation
import SwiftUI

enum LogLevel: String, Codable {
    case info = "INFO"
    case warning = "WARN"
    case error = "ERROR"
    case success = "SUCCESS"
    
    var icon: String {
        switch self {
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        case .success: return "✅"
        }
    }
    
    var color: Color {
        switch self {
        case .info: return .blue
        case .warning: return .orange
        case .error: return .red
        case .success: return .green
        }
    }
}

struct LogEntry: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let level: LogLevel
    let tag: String
    let message: String
    
    init(level: LogLevel = .info, tag: String = "App", message: String) {
        self.id = UUID()
        self.timestamp = Date()
        self.level = level
        self.tag = tag
        self.message = message
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: timestamp)
    }
    
    var fullLine: String {
        "[\(formattedTime)] [\(level.rawValue)] [\(tag)] \(message)"
    }
}

class LogManager: ObservableObject {
    static let shared = LogManager()
    
    @Published var logs: [LogEntry] = []
    private let maxLogs = 500
    private let queue = DispatchQueue(label: "com.getmoreram.logmanager", qos: .utility)
    
    init() {
        log("GetMoreRam initialized", tag: "System")
    }
    
    func log(_ message: String, level: LogLevel = .info, tag: String = "App") {
        let entry = LogEntry(level: level, tag: tag, message: message)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.logs.append(entry)
            if self.logs.count > self.maxLogs {
                self.logs.removeFirst(self.logs.count - self.maxLogs)
            }
        }
    }
    
    func clearLogs() {
        DispatchQueue.main.async { [weak self] in
            self?.logs.removeAll()
            self?.log("Logs cleared", tag: "System")
        }
    }
    
    func exportText() -> String {
        var output = "=== GetMoreRam Diagnostics Log ===\n"
        output += "Exported at: \(Date())\n"
        output += "Device RAM: \(DeviceMemoryInfo.current.formattedPhysicalMemory)\n"
        output += "Memory Budget: \(DeviceMemoryInfo.current.formattedAvailableMemory)\n"
        output += "==================================\n\n"
        
        for entry in logs {
            output += "\(entry.fullLine)\n"
        }
        return output
    }
    
    func exportToFile() -> URL? {
        let text = exportText()
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("GetMoreRam_Logs_\(Int(Date().timeIntervalSince1970)).txt")
        do {
            try text.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            log("Failed to export logs: \(error.localizedDescription)", level: .error, tag: "System")
            return nil
        }
    }
}
