//
//  DeviceMemoryInfo.swift
//  GetMoreRam
//
//  Created on 2026-10-07.
//

import Foundation
#if canImport(Darwin)
import Darwin
#endif

struct DeviceMemoryInfo {
    let physicalMemoryBytes: UInt64
    let availableMemoryBytes: UInt64
    
    static var current: DeviceMemoryInfo {
        let physical = ProcessInfo.processInfo.physicalMemory
        let available = queryAvailableMemory()
        return DeviceMemoryInfo(physicalMemoryBytes: physical, availableMemoryBytes: available)
    }
    
    var physicalMemoryGB: Double {
        Double(physicalMemoryBytes) / 1_073_741_824.0
    }
    
    var availableMemoryMB: Double {
        Double(availableMemoryBytes) / 1_048_576.0
    }
    
    var availableMemoryGB: Double {
        Double(availableMemoryBytes) / 1_073_741_824.0
    }
    
    var formattedPhysicalMemory: String {
        String(format: "%.1f GB", physicalMemoryGB)
    }
    
    var formattedAvailableMemory: String {
        if availableMemoryBytes > 0 {
            if availableMemoryGB >= 1.0 {
                return String(format: "%.2f GB", availableMemoryGB)
            } else {
                return String(format: "%.0f MB", availableMemoryMB)
            }
        } else {
            return "N/A"
        }
    }
    
    // Estimates default iOS limit (~35-45% of physical RAM)
    var estimatedDefaultLimitGB: Double {
        min(max(physicalMemoryGB * 0.40, 1.5), 3.0)
    }
    
    // Estimates IML limit (~70-80% of physical RAM)
    var estimatedIMLLimitGB: Double {
        max(physicalMemoryGB * 0.75, 4.0)
    }
    
    var formattedDefaultLimit: String {
        String(format: "~%.1f GB", estimatedDefaultLimitGB)
    }
    
    var formattedIMLLimit: String {
        String(format: "~%.1f GB", estimatedIMLLimitGB)
    }
    
    private static func queryAvailableMemory() -> UInt64 {
        #if canImport(Darwin)
        typealias OSProcAvailableMemoryType = @convention(c) () -> size_t
        if let handle = dlopen(nil, RTLD_NOW) {
            defer { dlclose(handle) }
            if let sym = dlsym(handle, "os_proc_available_memory") {
                let function = unsafeBitCast(sym, to: OSProcAvailableMemoryType.self)
                return UInt64(function())
            }
        }
        #endif
        return 0
    }
}
