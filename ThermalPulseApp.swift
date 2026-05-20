//
//  ThermalPulseApp.swift
//  ThermalPulse
//
//  Created by Arnaldo Baumanis on 5/8/26.
//

import SwiftUI
import AppKit

@main
struct ThermalPulseApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        //SettingsManager.shared.resetUserDefaults()
    }
    
    var body: some Scene {
        Settings {
            EmptyView() /// MenuBar-only approach
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    // ==============================================================
    // Check minimum requirements. ThermalPulse only can run on Apple Silicon and macOS > 25
    
    let requiredVersion = OperatingSystemVersion(majorVersion: 25, minorVersion: 0, patchVersion: 0)
    let currentVersion = ProcessInfo.processInfo.operatingSystemVersion
    
    func isAppleSilicon() -> Bool {
        #if arch(arm64)
        return true
        #else
        return false
        #endif
    }
    func canUseApp() -> Bool {
        let isSilicon = isAppleSilicon()
        
        if isSilicon || currentVersion.majorVersion >= requiredVersion.majorVersion {
            return true
        }

        return false
    }
    

    var menuBarController: MenuBarController?
    let popover = NSPopover()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if !canUseApp() {
            let alert = NSAlert()
            alert.messageText = "ThermalPulse requires macOS \(requiredVersion.majorVersion) or later on an Apple Silicon chip"
            alert.alertStyle = .critical
            alert.runModal()
            
            NSApp.terminate(nil)
        }
        
        // If the minimum requirements are met...
        
        NSApp.setActivationPolicy(.accessory)
        
        /// 1. Register default values ​​in UserDefaults before the UI reads them
        UserDefaults.standard.register(defaults: [
            "showMenuBarCPUUsage": true,
            "showMenuBarGPUUsage": false,
            "showMenuBarRAMUsage": false
        ])
        
        /// 2. Configure the Popover with your DashboardView
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: DashboardView())
        
        /// 3. Initialize the controller and save the strong reference in the class property
        menuBarController = MenuBarController(popover: popover)
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        Task {
            if HelperInstaller.isInstalled() {
                await HardwareMonitorManager.shared.setFanManualMode(enabled: false)
            }
            XPCClient.shared.invalidate() /// close conecction to XPCClient service

            sender.reply(toApplicationShouldTerminate: true)
        }
        
        return .terminateLater
    }
}


