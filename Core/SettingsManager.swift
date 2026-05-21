//
//  SettingsManager.swift
//  ThermalPulse
//
//  Created by Arnaldo Baumanis on 5/12/26.
//

import Foundation
import ServiceManagement
import SwiftUI

final class SettingsManager {
    static let shared = SettingsManager()
    private let defaults = UserDefaults.standard    
    
    enum Keys {
        static let launchAtLogin = "launchAtLogin"
    }
    
    /// Launch at Login using SMAppService (macOS 13+)
    var launchAtLogin: Bool {
        get { defaults.bool(forKey: Keys.launchAtLogin) }
        set {
            defaults.set(newValue, forKey: Keys.launchAtLogin)
            toggleLaunchAtLogin(enabled: newValue)
        }
    }
    
    private func toggleLaunchAtLogin(enabled: Bool) {
        let service = SMAppService.mainApp
        do {
            if enabled {
                if service.status != .enabled {
                    try service.register()
                }
            } else {
                if service.status == .enabled {
                    try service.unregister()
                }
            }
        } catch {
            print("Error setting Launch at Login: \(error)")
        }
    }
    
    /// Reset setting data. Could be usefull for testing
    func resetUserDefaults() {
        guard let bundleID = Bundle.main.bundleIdentifier else { return } /// Get the Bundle Identifier of the current app
        UserDefaults.standard.removePersistentDomain(forName: bundleID) /// removed the entire domain
        UserDefaults.standard.synchronize() /// Force synchronization (optional, but recommended on macOS)
        
        print("UserDefaults data reset")
    }
}

extension UserDefaults {
    @objc dynamic var showMenuBarCPUUsage: Bool { bool(forKey: "showMenuBarCPUUsage") }
    @objc dynamic var showMenuBarGPUUsage: Bool { bool(forKey: "showMenuBarGPUUsage") }
    @objc dynamic var showMenuBarRAMUsage: Bool { bool(forKey: "showMenuBarRAMUsage") }
    @objc dynamic var showMenuBarCPUTemp: Bool { bool(forKey: "showMenuBarCPUTemp") }
}
