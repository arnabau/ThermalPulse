//
//  SystemMetricsProvider.swift
//  ThermalPulse
//
//  Created by Arnaldo Baumanis on 5/13/26.
//

import Foundation
import IOKit.ps
import Metal

class SystemMetricsProvider {
    static let cpuTracker = CPUTracker()
    
    /// Cache static data so we don't have to request it from the kernel every X seconds
    private static let coreInfo: (cores: Int, pCores: Int, eCores: Int) = {
        var ncpu: Int32 = 0
        var pCores: Int32 = 0
        var eCores: Int32 = 0
        var size = MemoryLayout<Int32>.size
        sysctlbyname("hw.ncpu", &ncpu, &size, nil, 0)
        sysctlbyname("hw.perflevel0.physicalcpu", &pCores, &size, nil, 0)
        sysctlbyname("hw.perflevel1.physicalcpu", &eCores, &size, nil, 0)
        return (Int(ncpu), Int(pCores), Int(eCores))
    }()
    
    static func fetchMetrics() async -> SystemMetrics {
        let cpuUsage = cpuTracker.getUsage().reduce(0, +) / Double(coreInfo.cores)
        let ram = getDetailedRAM()
        let battery = getBatteryStatus()
        
        return SystemMetrics(
            cpuUsage: cpuUsage,
            cpuIdle: 1.0 - cpuUsage,
            coreCount: coreInfo.cores,
            performanceCores: coreInfo.pCores,
            efficiencyCores: coreInfo.eCores,
            ramUsage: ram.usageRatio,
            ramCompressed: ram.compressed,
            ramWired: ram.wired,
            ramFree: ram.available,
            memoryPressure: getMemoryPressure(),
            ramFormatted: ram.formatted,
            batteryLevel: battery.level,
            batteryIsCharging: battery.isCharging,
            batterySource: battery.source,
            batteryTimeRemaining: battery.time,
            macOSVersion: ProcessInfo.processInfo.operatingSystemVersionString,
            macDescriptionName: getProductDescriptionARM() ?? "",
            gpuName: MTLCreateSystemDefaultDevice()?.name ?? "GPU",
            gpuUsage: getGPUUsage() / 100.0,
            gpuCores: getGPUCoreCount(),
            diskVolumes: await getDiskInfo()
        )
    }
    
    // MARK: Memory
    
    private static func getDetailedRAM() -> (usageRatio: Double, wired: String, compressed: String, available: String, formatted: String) {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)
        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        
        if result == KERN_SUCCESS {
            let pageSize = UInt64(vm_kernel_page_size)
            let wired = Double(UInt64(stats.wire_count) * pageSize) / 1024 / 1024 / 1024
            let active = Double(UInt64(stats.active_count) * pageSize) / 1024 / 1024 / 1024
            let compressed = Double(UInt64(stats.compressor_page_count) * pageSize) / 1024 / 1024 / 1024
            let free = Double(UInt64(stats.free_count) * pageSize) / 1024 / 1024 / 1024
            
            let totalUsed = wired + active + compressed
            let totalRAM = Double(ProcessInfo.processInfo.physicalMemory) / 1024 / 1024 / 1024
            
            return (
                usageRatio: totalUsed / totalRAM,
                wired: String(format: "%.2f GB", wired),
                compressed: String(format: "%.1f MB", compressed * 1024),
                available: String(format: "%.2f GB", free),
                formatted: "\(Int(totalRAM)) GB"
            )
        }
        return (0.4, "0 GB", "0 MB", "0 GB", "Unknown")
    }
    
    private static func getMemoryPressure() -> String {
        var pressure: Int32 = 0
        var size = MemoryLayout<Int32>.size
        sysctlbyname("kern.memorystatus_vm_pressure_level", &pressure, &size, nil, 0)
        switch pressure {
        case 1: return "Normal"
        case 2: return "Warning"
        case 4: return "Critical"
        default: return "Normal"
        }
    }
    
    private static func getBatteryStatus() -> (level: Double, isCharging: Bool, source: String, time: String) {
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array
        for source in sources {
            if let desc = IOPSGetPowerSourceDescription(snapshot, source).takeUnretainedValue() as? [String: Any] {
                let level = (desc[kIOPSCurrentCapacityKey] as? Double ?? 0) / 100.0
                let isCharging = desc[kIOPSIsChargingKey] as? Bool ?? false
                let source = (desc[kIOPSPowerSourceStateKey] as? String == kIOPSBatteryPowerValue) ? "Battery" : "Power Adapter"
                return (level, isCharging, source, "Calculating...")
            }
        }
        return (0, false, "AC Power", "")
    }
    
    
    // MARK: Disks
    
    static func getDiskInfo() async -> [DiskInfo] {
        let keys: [URLResourceKey] = [.volumeNameKey, .volumeTotalCapacityKey, .volumeAvailableCapacityKey, .volumeIsInternalKey]
        let paths = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: keys, options: [.skipHiddenVolumes]) ?? []
        
        var disks: [DiskInfo] = []
        
        for url in paths {
            guard let values = try? url.resourceValues(forKeys: Set(keys)) else { continue }
            
            let disk = DiskInfo(
                name: values.volumeName ?? "Unknown",
                totalCapacity: Int64(values.volumeTotalCapacity ?? 0),
                availableCapacity: Int64(values.volumeAvailableCapacity ?? 0),
                isInternal: values.volumeIsInternal ?? true
            )
            
            /// Only add if there is > 0 (avoids extraneous logical volumes)
            if disk.totalCapacity > 0 {
                disks.append(disk)
            }
        }
        
        // Priority: Internal first, then by size, limited to 3
        return disks.sorted { $0.isInternal && !$1.isInternal }.prefix(3).map { $0 }
    }
    
    
    // MARK: - GPU
    
    /// Get GPU info using Metal
    private func getGPUInfo() -> String {
        /// We get the Metal device by default (the SoC in Apple Silicon)
        guard let device = MTLCreateSystemDefaultDevice() else {
            return "Unknown GPU"
        }
        return device.name // e.g: "Apple M3"
    }
    
    /// GPU metrics
    private static func getGPUUsage() -> Double {
        var usage: Double = 0
        var iterator: io_iterator_t = 0
        let match = IOServiceMatching("IOAccelerator")
        
        let result = IOServiceGetMatchingServices(kIOMainPortDefault, match, &iterator)
        if result == KERN_SUCCESS {
            var service = IOIteratorNext(iterator)
            while service != 0 {
                if let props = IORegistryEntryCreateCFProperty(service, "PerformanceStatistics" as CFString, kCFAllocatorDefault, 0)?.takeRetainedValue() as? [String: Any] {
                    /// Apple Silicon use "Device Utilization %"
                    if let utilization = props["Device Utilization %"] as? Int {
                        usage = max(usage, Double(utilization))
                    }
                }
                IOObjectRelease(service)
                service = IOIteratorNext(iterator)
            }
            IOObjectRelease(iterator)
        }
        return usage
    }
    
    private static func getGPUCoreCount() -> Int {
        var coreCount = 0
        
        /// In Apple Silicon the device is usually found under "AGXAccelerator" or within the Device Tree as "gpu-core-count"
        let matcher = IOServiceMatching("AGXAccelerator")
        var iterator: io_iterator_t = 0
        
        if IOServiceGetMatchingServices(kIOMainPortDefault, matcher, &iterator) == KERN_SUCCESS {
            let service = IOIteratorNext(iterator)
            if service != 0 {
                /// Parent/Device Tree
                if let props = IORegistryEntryCreateCFProperty(service, "gpu-core-count" as CFString, kCFAllocatorDefault, 0),
                   let count = props.takeRetainedValue() as? NSNumber {
                    coreCount = count.intValue
                } else {
                    // Some M1 models
                    var parent: io_registry_entry_t = 0
                    if IORegistryEntryGetParentEntry(service, kIODeviceTreePlane, &parent) == KERN_SUCCESS {
                        if let props = IORegistryEntryCreateCFProperty(parent, "gpu-core-count" as CFString, kCFAllocatorDefault, 0),
                           let count = props.takeRetainedValue() as? NSNumber {
                            coreCount = count.intValue
                        }
                        IOObjectRelease(parent)
                    }
                }
                IOObjectRelease(service)
            }
            IOObjectRelease(iterator)
        }
        
        return coreCount
    }
    
    // MARK: OS Info
    
    static func getProductDescriptionARM() -> String? {
        let appleSiliconProduct = IORegistryEntryFromPath(kIOMainPortDefault, "IOService:/AppleARMPE/product")
        guard appleSiliconProduct != 0 else { return nil }
        defer { IOObjectRelease(appleSiliconProduct) }
        
        if let cfKeyValue = IORegistryEntryCreateCFProperty(appleSiliconProduct, "product-description" as CFString, kCFAllocatorDefault, 0),
           let data = cfKeyValue.takeRetainedValue() as? Data {
            return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .newlines)
        }
        return nil
    }
    
}
