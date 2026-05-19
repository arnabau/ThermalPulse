//
//  DashboardViewModel.swift
//  ThermalPulse
//
//  Created by Arnaldo Baumanis on 5/8/26.
//

import Foundation
import SwiftUI
import Combine
@preconcurrency import ServiceManagement

@MainActor
class DashboardViewModel: ObservableObject {
    @Published private(set) var isHelperInstalled: Bool = false
    
    unowned private let manager = HardwareMonitorManager.shared
    
    @AppStorage("showMenuBarCPUUsage") var showMenuBarCPUUsage: Bool = true
    @AppStorage("showMenuBarGPUUsage") var showMenuBarGPUUsage: Bool = false
    @AppStorage("showMenuBarRAMUsage") var showMenuBarRAMUsage: Bool = false
    //@AppStorage("showMenuBarCPUTemp") var showMenuBarCPUTemp: Bool = false
    //@AppStorage("showMenuBarGPUTemp") var showMenuBarGPUTemp: Bool = false
    
    @Published var isManual: Bool = false
    @Published var selectedProfile: ThermalProfile = .system
    @Published var userTargetSpeed: Double = 2000
    
    @Published var cpuTemp: Double = 0
    @Published var gpuTemp: Double = 0
    @Published var cpuHistory: [TemperaturePoint] = []
    @Published var gpuHistory: [TemperaturePoint] = []
    @Published var metrics: SystemMetrics?
    @Published var diskMetrics: [DiskInfo] = []
    @Published var powerUsage: Double = 0
    
    @Published var errorMessage: String? = nil
    
    /// fans
    @Published var fanRPM: [Int] = []
    @Published var fanNumber: Int = 0
    @Published var fanProgress: Double = 0
    
    var physicalMinStr: String { String(format: "%.0f RPM", manager.physicalMinRPM) }
    var physicalMaxStr: String { String(format: "%.0f RPM", manager.physicalMaxRPM) }
    var physicalRange: ClosedRange<Double> { manager.physicalMinRPM...manager.physicalMaxRPM }
    
    @Published var launchAtLogin: Bool = false {
        didSet { SettingsManager.shared.launchAtLogin = launchAtLogin }
    }
    
    private let settingsChanged = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()
    private let settings = SettingsManager.shared
    
    init() {
        checkInstallationStatus()
        
        self.isManual = manager.isManualMode
        self.selectedProfile = manager.activeProfile
        self.userTargetSpeed = Double(manager.manualTargetRPM)
        
        loadSettings()
        setupSubscriptions()
    }
    
    
    func triggerSettingsUpdate() {
        settingsChanged.send()
        
        /// fan control
        guard isManual && isHelperInstalled else { return }
        HardwareMonitorManager.shared.setFanSpeedSmoothly(targetRpm: Int(userTargetSpeed))
    }
    
    
    private func loadSettings() {
        let settings = SettingsManager.shared
        self.launchAtLogin = settings.launchAtLogin
    }
    
    private func setupSubscriptions() {
        manager.$metrics.assign(to: &$metrics)
        manager.$diskMetrics
            .receive(on: RunLoop.main)
            .assign(to: &$diskMetrics)
        manager.$cpuTemp.sink { [weak self] v in self?.cpuTemp = v }.store(in: &cancellables)
        manager.$gpuTemp.sink { [weak self] v in self?.gpuTemp = v }.store(in: &cancellables)
        manager.$powerUsage.sink { [weak self] v in self?.powerUsage = v }.store(in: &cancellables)
        manager.$fanRPM.sink { [weak self] rpms in
            self?.fanRPM = rpms
            if let firstFan = rpms.first {
                // COMPRBAR SI ES 6000 O ES EL MAXIMO QUE PERMITE EL FAN
                self?.fanProgress = min(Double(firstFan) / 6000.0, 1.0)
            }
        }.store(in: &cancellables)
        manager.$fanCount.sink { [weak self] v in self?.fanNumber = v }.store(in: &cancellables)
        manager.$cpuHistory.sink { [weak self] v in self?.cpuHistory = v }.store(in: &cancellables)
        manager.$gpuHistory.sink { [weak self] v in self?.gpuHistory = v }.store(in: &cancellables)
    }
    
    /// Optional: public function to force (manually) data refresh. For now, it is only called from the Refresh button in DashboardView
    func refreshAll() {
        manager.forceRefresh()
        checkInstallationStatus()
    }
    
    // MARK: - Profile actions
    
    func setProfile(_ profile: ThermalProfile) {
        guard isHelperInstalled || profile == .system else {
            self.errorMessage = "Administrator privileges are required for manual profiles"
            return
        }
        
        self.selectedProfile = profile
        /// Delegate the command to the HardwareMonitorManager (which will use the XPC channel)
        HardwareMonitorManager.shared.updateActiveProfile(profile)
    }
    
    func selectProfile(_ profile: ThermalProfile) {
        selectedProfile = profile
        manager.updateActiveProfile(profile)
    }
    
    /// this is call in DashboardView as a .help for the RAM donut graphics, like a tooltip
    var ramSummary: String {
        guard let m = metrics else { return "No RAM data" }
        return [
            "Total: \(m.ramFormatted)",
            "Compressed: \(m.ramCompressed)",
            "Wired: \(m.ramWired)",
            "Free: \(m.ramFree)"
        ].joined(separator: "\n")
    }
    
    // MARK: Privileged Helper Tool
    
    func checkInstallationStatus() {
        self.isHelperInstalled = HelperInstaller.isInstalled()
        if isHelperInstalled {
            /// ...
        }
    }
    
    func toggleManualMode(enabled: Bool) {
        guard isHelperInstalled else { return }
        self.isManual = enabled
        
        guard let proxy = XPCClient.shared.establishConnection() else { return }
        proxy.setFanControlMode(isManual: enabled) { success in
            if !success {
                print("The manual control mode could not be applied")
            }
        }
    }
    
    func applyFanSpeed(rpm: Int) {
        guard isHelperInstalled, isManual else { return }
        
        guard let proxy = XPCClient.shared.establishConnection() else { return }
        proxy.setFanSpeed(index: 0, rpm: rpm) { success in
            if !success {
                print("Error adjusting fan speed")
            }
        }
    }
    
    func installHelperTool() {
        /// Registered the component as a system daemon using SMAppService
        /// The .plist must be located within app bundle in Contents/Library/LaunchDaemons/
        Task {
            let success = await HelperInstaller.install()
            await MainActor.run {
                if success {
                    self.isHelperInstalled = true
                    self.errorMessage = nil
                    print("Helper installed successfully")
                    
                    checkInstallationStatus()
                } else {
                    self.errorMessage = "The thermal control component could not be installed"
                }
            }
        }
    }
    
    func removeHelperTool() {
        errorMessage = nil
        Task {
            let success = await HelperInstaller.uninstall()
            if success {
                self.isHelperInstalled = false
                self.setProfile(.system)
                checkInstallationStatus()
                print("Helper uninstalled and safely purged from the system")
            } else {
                errorMessage = "The Helper could not be uninstalled. Check the permissions"
            }
        }
    }
    
}


class CPUTracker {
    private var prevCpuInfo: processor_info_array_t?
    private var prevCpuInfoCnt: mach_msg_type_number_t = 0
    private var numCpuInfo: processor_info_array_t?
    private var numCpuInfoCnt: mach_msg_type_number_t = 0
    private var numCPUs: uint = 0
    private let CPUUsageLock = NSLock()
    
    init() {
        let result = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUs, &numCpuInfo, &numCpuInfoCnt)
        if result == KERN_SUCCESS {
            prevCpuInfo = numCpuInfo
            prevCpuInfoCnt = numCpuInfoCnt
        }
    }
    
    func getUsage() -> [Double] {
        var usage = [Double]()
        var numCPUsU: natural_t = 0
        let result = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUsU, &numCpuInfo, &numCpuInfoCnt)
        
        if result == KERN_SUCCESS {
            CPUUsageLock.lock()
            for i in 0 ..< Int32(numCPUsU) {
                var inUse: Int32 = 0
                var total: Int32 = 0
                for j in 0 ..< Int32(CPU_STATE_MAX) {
                    let index = Int32(CPU_STATE_MAX) * i + j
                    if let prevInfo = prevCpuInfo, let currInfo = numCpuInfo {
                        let diff = currInfo[Int(index)] - prevInfo[Int(index)]
                        if j != CPU_STATE_IDLE {
                            inUse += diff
                        }
                        total += diff
                    }
                }
                if total > 0 {
                    usage.append(Double(inUse) / Double(total))
                } else {
                    usage.append(0)
                }
            }
            
            if let prev = prevCpuInfo {
                vm_deallocate(mach_task_self_, vm_address_t(bitPattern: prev), vm_size_t(prevCpuInfoCnt))
            }
            
            prevCpuInfo = numCpuInfo
            prevCpuInfoCnt = numCpuInfoCnt
            CPUUsageLock.unlock()
        }
        return usage
    }
}
