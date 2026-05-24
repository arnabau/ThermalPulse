//
//  RealSMCService.swift
//  ThermalPulse
//
//  Created by Arnaldo Baumanis on 5/8/26.
//

import Foundation
import SMCKit

final class SMCService: SMCServiceProtocol {
    private let smc = SMCKit.shared
    
    /// Apple silicon keys
    ///
    /// Tp0D (CPU Die/Package): This is one of the key indicators. It measures the overall temperature of the CPU die or main package. "Average" to show in UI
    /// Tp01 and Tp05 (CPU E-Core Cluster / P-Core Cluster): These keys monitor specific core clusters. Tp01 (usually) measures the average efficiency core (E-core) block.
    ///     The other (such as Tp05) measures the performance core (P-core) block.
    /// Tp09 and Tp0b (CPU Core Digital Sensors / Auxiliaries): These are digital thermal diodes distributed in strategic areas of the CPU
    /// Tp0T (CPU Thermal Proximity / Top): Measures temperature by thermal proximity
    /// Priority: P-Cores > E-Cores > Die (Average)
    private let cpuKeys = ["Tp05", "Tp01", "Tp0D", "Tp0T", "Tp09", "Tp0b"]
    
    /// TG0D (GPU 0 Die): Measures the temperature of the GPU's main silicon block (Die). It is one of the most important and reliable keys
    /// TGDD (GPU Die Domain): It is the graphics digital domain sensor
    /// TG0P (GPU 0 Proximity): Proximity temperature
    /// TG0E and TG0F (GPU 0 Diode E / Diode F): These are secondary thermal diodes placed in the power supply phases or in the power lines dedicated to the GPU
    /// Tg0J (GPU Junction): Measures the junction temperature
    /// Tg05 and Tg0f (GPU Cluster Sensors): Map specific execution clusters within the GPU
    /// Tg0L (GPU Local / Limit): Monitors the local thermal limits of the GPU's texture units or shaders
    ///
    /// Priority: Junction (Hottest point) > Clusters > Die
    private let gpuKeys = ["Tg0J", "Tg05", "Tg0f", "TG0D", "TGDD", "Tg0L", "TG0P", "TG0E", "TG0F"]
    
    private var activeCpuKey: FourCharCode?
    private var activeGpuKey: FourCharCode?
    private var cachedFanCount: Int?
    
    private var lastValidCpuTemp: Double = 40.0
    private var lastValidGpuTemp: Double = 40.0
    
    /// Get CPU temp
    func getCPUTemperature() async throws -> Double {
        let (temp, key) = await performValidatedRead(currentKey: activeCpuKey, candidates: cpuKeys)
        
        self.activeCpuKey = key
        
        if let temp = temp {
            lastValidCpuTemp = temp
            return temp
        }
        
        return lastValidCpuTemp
    }
    
    /// Get GPU temp
    func getGPUTemperature() async throws -> Double {
        let (temp, key) = await performValidatedRead(currentKey: activeGpuKey, candidates: gpuKeys)
        
        self.activeGpuKey = key
        
        if let temp = temp {
            lastValidGpuTemp = temp
            return temp
        }
        
        return lastValidGpuTemp
    }
    
    private func performValidatedRead(currentKey: FourCharCode?, candidates: [String]) async -> (Double?, FourCharCode?) {
        /// 1. Try with the key that we already know
        if let key = currentKey {
            if let val: Float = try? await smc.read(key), isValid(val) {
                return (Double(val), key)
            }
        }
        
        /// 2. If the previous one failed or does not exist, we search the candidates
        for keyString in candidates {
            let code = keyString.fourCharCode
            if let val: Float = try? await smc.read(code), isValid(val) {
                //print("🎯 New key found: \(keyString)")
                return (Double(val), code)
            }
        }
        
        /// 3. If nothing worked, return nil for the value and nil for the key (forcing rescan)
        return (nil, nil)
    }
    
    private func isValid(_ temp: Float) -> Bool {
        /// Realistic-safety threshold usually starts at 15°C - 20°C to avoid *Sensor Jitter*
        return temp > 15 && temp < 110
    }
    
    /// Get Fans number
    func getFanNumber() async -> Int {
        if let count = cachedFanCount { return count }
        do {
            let count: UInt8 = try await smc.read("FNum".fourCharCode)
            let finalCount = Int(count)
            self.cachedFanCount = finalCount
            return finalCount
        } catch {
            return 0
        }
    }
    
    /// Get Fan speed
    func getFanSpeed(for fanIndex: Int) async throws -> Int {
        // F0Mt or F0Ac
        let fanCount = await getFanNumber()
        guard fanIndex < fanCount else { return 0 }
        let key = "F\(fanIndex)Ac".fourCharCode
        
        do {
            let speed: Float = try await smc.read(key)
            if speed < 0 || speed > 10000 { return 0 } /// to avoid odd metrics
            return Int(speed)
        } catch {
            return 0
        }
    }
    
    func getFanMaxRPM(for fanIndex: Int) async throws -> Int {
        let key = "F\(fanIndex)Mx".fourCharCode
        if let value: Float = try? await smc.read(key) {
            return Int(value)
        }
        return 0
    }
    
    func getFanMinRPM(for fanIndex: Int) async throws -> Int {
        let key = "F\(fanIndex)Mn".fourCharCode
        if let value: Float = try? await smc.read(key) {
            return Int(value)
        }
        return 0
    }
    
    /// Set Fans speed
    func setFanSpeed(for fanIndex: Int, rpm: Int) async throws {
        let targetKey = "F\(fanIndex)Tg".fourCharCode
        
        do {
            /// SMC can spect UInt16 or Float for RPM
            try await smc.write(targetKey, Float(rpm))
        } catch {
            print("SetFanSpeed Something went wrong while setting fan \(fanIndex): \(error)")
            throw error
        }
    }
    
    
    func setFanControlMode(isManual: Bool) async throws {
        let fanCount = await getFanNumber()
        let value: UInt8 = isManual ? 1 : 0
        
        for i in 0..<fanCount {
            /// F{i}Md instead of FS!
            let modeKey = "F\(i)Md".fourCharCode
            do {
                try await smc.write(modeKey, value)
                print("Manual mode set for fan \(i)")
            } catch {
                /// If F0Md dosn't  exist, try fallback to FS! (legacy models)
                if i == 0 {
                    let legacyValue: UInt16 = isManual ? 1 : 0
                    try? await smc.write("FS! ".fourCharCode, legacyValue)
                }
                print("setFanControlMode Something went wrong while setting fan \(i): \(error)")
            }
        }
    }
    
    
    func getPowerUsage() async throws -> Double {
        /// PSTR usually Float
        if let watts: Float = try? await smc.read("PSTR".fourCharCode) {
            return Double(watts)
        }
        return 0.0
    }
}

extension String {
    /// Converts a 4-character String (e.g. "TC0P") to FourCharCode (UInt32)
    var fourCharCode: FourCharCode {
        guard self.count == 4 else { return 0 }
        var result: UInt32 = 0
        for char in self.utf8 {
            result = (result << 8) + UInt32(char)
        }
        return result
    }
}
