//
//  SystemMetrics.swift
//  ThermalPulse
//
//  Created by Arnaldo Baumanis on 5/11/26.
//

import Foundation
import IOKit

struct SystemMetrics {
    // CPU
    let cpuUsage: Double
    let cpuIdle: Double             // Idle time
    let coreCount: Int              // Logic cores
    let performanceCores: Int       // P-Cores
    let efficiencyCores: Int        // E-Cores
    // RAM
    let ramUsage: Double
    let ramCompressed: String
    let ramWired: String
    let ramFree: String
    let memoryPressure: String // "Normal", "Warning", "Critical"
    let ramFormatted: String
    // BATTERY
    let batteryLevel: Double
    let batteryIsCharging: Bool
    let batterySource: String         // "Power Adapter" or "Battery"
    let batteryTimeRemaining: String  // "2h 30m" o "Calculating..."
    // SYSTEM/OS
    let macOSVersion: String
    let macDescriptionName: String  // e.g MacBook Air (13 inc, M3, 2014)
    // GPU
    let gpuName: String
    let gpuUsage: Double
    let gpuCores: Int
    // DISKS
    //let diskVolumes: [DiskInfo]
}

struct DiskInfo: Identifiable {
    let id = UUID()
    let name: String
    let totalCapacity: Int64
    let availableCapacity: Int64
    let isInternal: Bool
    
    /// Formatted output
    var totalCapacityFormatted: String {
        totalCapacity.formatted(.byteCount(style: .file))
    }
    
    var availableCapacityFormatted: String {
        availableCapacity.formatted(.byteCount(style: .file))
    }
    
    /// % for the progressbar
    var usagePercentage: Double {
        guard totalCapacity > 0 else { return 0 }
        let used = totalCapacity - availableCapacity
        return Double(used) / Double(totalCapacity)
    }
}
