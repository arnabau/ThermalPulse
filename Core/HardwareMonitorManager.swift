//
//  HardwareMonitorManager.swift
//  ThermalPulse
//
//  Created by Arnaldo Baumanis on 5/11/26.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class HardwareMonitorManager: ObservableObject {
    static let shared = HardwareMonitorManager()
    
    private var isUIVisible: Bool = false
    
    #if DEBUG
    private let smcService: SMCServiceProtocol = MockSMCService()
    #else
    private let smcService: SMCServiceProtocol = SMCService()
    #endif
    
    @Published var metrics: SystemMetrics? = nil
    @Published var diskMetrics: [DiskInfo] = []
    @Published var cpuTemp: Double = 0
    @Published var gpuTemp: Double = 0
    @Published var fanRPM: [Int] = []
    @Published var fanCount: Int = 0
    @Published var powerUsage: Double = 0
    @Published var cpuHistory: [TemperaturePoint] = []
    @Published var gpuHistory: [TemperaturePoint] = []
    
    @Published var isManualMode: Bool = false
    @Published var activeProfile: ThermalProfile = .system
    
    /// cache
    private var lastAppliedSMCMode: Bool? = nil
    private var lastTargetRPM: Int? = nil
    private var rampingTask: Task<Void, Never>? /// Private property to control the active acceleration thread for fan speed. (smooth transition)
    
    private(set) var physicalMinRPM: Double = 1000 /// just a reference value. Calculations are made later for real-physical ram
    private(set) var physicalMaxRPM: Double = 4900 /// just a reference value
    private var timer: AnyCancellable?
    private let backgroundInterval: TimeInterval = 6.0
    private let foregroundInterval: TimeInterval = 3.0
    private var lastDiskUpdate: Date = .distantPast
    private let diskUpdateInterval: TimeInterval = 300 /// 5 min
    private let maxHistoryPoints = 30
    private var isRefreshing = false
    
    private init() {
        Task {
            self.fanCount = await smcService.getFanNumber()

            if let minRpm = try? await smcService.getFanMinRPM(for: 0) { self.physicalMinRPM = Double(minRpm) }
            if let maxRpm = try? await smcService.getFanMaxRPM(for: 0) { self.physicalMaxRPM = Double(maxRpm) }
            //print("Fan: \(fanCount), min: \(physicalMinRPM), max: \(physicalMaxRPM)")
        }
        startMonitoring(interval: backgroundInterval)
    }
    
    func setHighPriority(_ enabled: Bool) {
        self.isUIVisible = enabled
        let newInterval = enabled ? foregroundInterval : backgroundInterval
        if enabled { Task { await refreshData() } }
        
        startMonitoring(interval: newInterval)
    }
    
    func startMonitoring(interval: TimeInterval) {
        timer?.cancel()
        timer = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                Task { await self.refreshData() }
            }
    }
    
    func stopMonitoring() {
        timer?.cancel()
        timer = nil
    }
    
    private func refreshData() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }
        
        // ==========================================
        // PHASE 1: PASSIVE MONITORING (Always running)
        // ==========================================
        
        let showCPU = UserDefaults.standard.bool(forKey: "showMenuBarCPUUsage")
        let showGPU = UserDefaults.standard.bool(forKey: "showMenuBarGPUUsage")
        let showRAM = UserDefaults.standard.bool(forKey: "showMenuBarRAMUsage")
        
        let isMenuBarActive = showCPU || showGPU || showRAM
        let needsThermalControl = (activeProfile != .system)
        
        /// If the popover is closed, there is no text in the MenuBar and Apple handles the fans, suspend monitoring
        if !isUIVisible && !isMenuBarActive && !needsThermalControl {
            return
        }
        
        do {
            let cpu = try await smcService.getCPUTemperature()
            let gpu = try await smcService.getGPUTemperature()
            
            var power: Double = 0
            var currentSpeeds: [Int] = []
            
            /// Only query fan/watt info if the user opened the popover
            if isUIVisible {
                power = (try? await smcService.getPowerUsage()) ?? 0
                for i in 0..<fanCount {
                    let speed = try? await smcService.getFanSpeed(for: i)
                    currentSpeeds.append(speed ?? 0)
                }
            }
            
            /// Advanced system metrics (CPU tracker, RAM, battery) are only visible if someone is viewing them
            var newMetrics: SystemMetrics? = nil
            if isUIVisible || isMenuBarActive {
                newMetrics = await SystemMetricsProvider.fetchMetrics()
            }
            
            var updatedDisks = self.diskMetrics
            if isUIVisible && Date().timeIntervalSince(lastDiskUpdate) > diskUpdateInterval {
                updatedDisks = await SystemMetricsProvider.getDiskInfo()
                lastDiskUpdate = Date()
            }
            
            withAnimation(.smooth) {
                self.cpuTemp = cpu
                self.gpuTemp = gpu
                if isUIVisible {
                    self.fanRPM = currentSpeeds
                    self.powerUsage = power
                    self.diskMetrics = updatedDisks
                }
                if let metrics = newMetrics {
                    self.metrics = metrics
                }
            }
            
            if isUIVisible {
                let now = Date()
                updateHistory(history: &self.cpuHistory, newValue: cpu, time: now)
                updateHistory(history: &self.gpuHistory, newValue: gpu, time: now)
            }
        } catch {
            print("Manager Error: \(error)")
        }
        
        // ==========================================
        // PHASE 2: ACTIVE THERMAL CONTROL (Optimized on demand)
        // ==========================================
        
        /// no privileges? exit immediately. Zero resource consumption in control logic
        guard HelperInstaller.isInstalled() else { return }
        
        /// Current profile requires app intervention? If profile is .system, we delegate thermal control entirely to Apple
        let targetSMCManualMode = (activeProfile != .system)
        
        /// Apply mode change to SMC only if the state change (Idempotence)
        if lastAppliedSMCMode != targetSMCManualMode {
            do {
                let _ = await setFanControlModeViaHelper(isManual: targetSMCManualMode)
                lastAppliedSMCMode = targetSMCManualMode
                print("SMC Hardware Mode successfully changed to: \(targetSMCManualMode ? "Manual" : "Native/Apple")")
            }
        }
        
        /// If Apple has control of the hardware there's no point in running automatic thermal curve algorithms from the app
        if !targetSMCManualMode {
            /// Cleaning up leftover tasks by software if it return to Apple's native mode
            if rampingTask != nil {
                rampingTask?.cancel()
                rampingTask = nil
                lastTargetRPM = nil
            }
            return
        }
        
        /// If the app has control through Smart Profiles (.balanced, .aggressive...)
        if !isManualMode {
            let maxCurrentTemp = max(cpuTemp, gpuTemp)
            let calculatedRpm = calculateAutoRPM(for: maxCurrentTemp)
            
            /// Only trigger the ramp if the RPM target changes significantly. Avoid restarting asynchronous tasks if the thermal target remains the same
            /// Ignore changes below 150 RPM to avoid fan "stuttering" caused by normal temperature fluctuations in the P-Cores
            let currentTarget = lastTargetRPM ?? 0
            if abs(currentTarget - calculatedRpm) > 150 {
                lastTargetRPM = calculatedRpm
                setFanSpeedSmoothly(targetRpm: calculatedRpm)
            }
//            if lastTargetRPM != calculatedRpm {
//                lastTargetRPM = calculatedRpm
//                setFanSpeedSmoothly(targetRpm: calculatedRpm)
//            }
        }
    }
    
    /// Linear Interpolation Equation for the Smart Curve
    private func calculateAutoRPM(for temperature: Double) -> Int {
        let bounds = activeProfile.rpmBounds(minPhysical: physicalMinRPM, maxPhysical: physicalMaxRPM)
        let profile = activeProfile
        
        if temperature <= profile.tempMin { return Int(bounds.min) }
        if temperature >= profile.tempMax { return Int(bounds.max) }
        
        /// Proportional mathematical mapping: Degrees -> RPMs
        let fraction = (temperature - profile.tempMin) / (profile.tempMax - profile.tempMin)
        let calculatedRPM = bounds.min + (bounds.max - bounds.min) * fraction
        return Int(calculatedRPM)
    }
    
    func updateActiveProfile(_ profile: ThermalProfile) {
        activeProfile = profile
        Task { await refreshData() }
    }
    
    /// public function to force the updating of metrics via button
    func forceRefresh() {
        lastDiskUpdate = .distantPast
        Task { await refreshData() }
    }
    
    private func updateHistory(history: inout [TemperaturePoint], newValue: Double, time: Date) {
        history.append(TemperaturePoint(time: time, temperature: newValue))
        if history.count > maxHistoryPoints { history.removeFirst() }
    }
    
    // MARK: Fans properties
    func setFanManualMode(enabled: Bool) async {
        print("setFanManualMode: \(enabled)")
        let _ = await setFanControlModeViaHelper(isManual: enabled)
    }
    
    func setFanSpeed(rpm: Int) async {
        let _ = await setFanSpeedViaHelper(index: 0, rpm: rpm)
    }
    
    /// Change the fan speed gradually to avoid sudden changes
    func setFanSpeedSmoothly(targetRpm: Int) {
        /// 1. canceling any transitions that are currently running
        rampingTask?.cancel()
        
        /// 2. Start a new asynchronous smoothing task
        rampingTask = Task {
            guard var currentTarget = fanRPM.first else { return }
            
            let step = 100 /// How many RPMs does it increase/decrease in each iteration?
            let intervalNanoseconds = UInt64(150_000_000) /// 150 miliseconds
            
            while !Task.isCancelled {
                let difference = targetRpm - currentTarget
                
                /// If we're already very close to the goal, we make the final adjustment and leave
                if abs(difference) <= step {
                    let _ = await setFanSpeedViaHelper(index: 0, rpm: targetRpm)
                    break
                }
                
                currentTarget += (difference > 0) ? step : -step
                
                let _ = await setFanSpeedViaHelper(index: 0, rpm: currentTarget)
                
                do {
                    try await Task.sleep(nanoseconds: intervalNanoseconds) /// wait a little bit before next step
                } catch {
                    break /// If the task is canceled during sleep, exit the loop
                }
            }
        }
    }
    
    
    private func setFanSpeedViaHelper(index: Int, rpm: Int) async -> Bool {
        #if DEBUG
        try? await smcService.setFanSpeed(for: index, rpm: rpm)
        return true
        #else
        return await withCheckedContinuation { continuation in
            guard let helper = XPCClient.shared.establishConnection() else {
                print("❌ HardwareMonitorManager: Could not connect to the Helper via XPC")
                continuation.resume(returning: false)
                return
            }
            
            helper.setFanSpeed(index: index, rpm: rpm) { success in
                continuation.resume(returning: success)
            }
        }
        #endif
    }
    
    private func setFanControlModeViaHelper(isManual: Bool) async -> Bool {
        #if DEBUG
        try? await smcService.setFanControlMode(isManual: isManual)
        return true
        #else
        return await withCheckedContinuation { continuation in
            guard let helper = XPCClient.shared.establishConnection() else {
                print("❌ HardwareMonitorManager: Could not connect to the Helper via XPC")
                continuation.resume(returning: false)
                return
            }
            
            helper.setFanControlMode(isManual: isManual) { success in
                continuation.resume(returning: success)
            }
        }
        #endif
    }
}
