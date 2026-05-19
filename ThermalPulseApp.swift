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
    /// I'm only using AppDelegate to close the app. It returns the fans to automatic mode
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    /// Store the controller in a lifecycle property to prevent ARC from destroying it.
//    @State private var menuBarController: MenuBarController?
    
    func isAppleSilicon() -> Bool {
        #if arch(arm64)
        return true
        #else
        return false
        #endif
    }
    
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
    var menuBarController: MenuBarController?
    let popover = NSPopover()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 1. Registrar valores por defecto en UserDefaults antes de que la UI los lea
        UserDefaults.standard.register(defaults: [
            "showMenuBarCPUUsage": true,
            "showMenuBarGPUUsage": false,
            "showMenuBarRAMUsage": false
        ])
        
        // 2. Configurar el Popover con tu DashboardView
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: DashboardView())
        
        // 3. Inicializar el controlador y guardar la referencia fuerte en la propiedad de la clase
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


