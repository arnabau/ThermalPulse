//
//  MenuBarController.swift
//  ThermalPulse
//
//  Created by Arnaldo Baumanis on 5/11/26.
//

import AppKit
import SwiftUI
import Combine

class MenuBarController: NSObject, NSPopoverDelegate {
    private var statusItem: NSStatusItem?
    
    private let defaults = UserDefaults.standard
    
    private var cancellables = Set<AnyCancellable>()
    private let popover: NSPopover
    
    init(popover: NSPopover) {
        self.popover = popover
        super.init()
        self.popover.delegate = self
        
        setupItems()
        setupSubscriptions()
    }
    
    /// menubar icons
    private func setupItems() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "fan.fill", accessibilityDescription: "ThermalPulse")
            button.action = #selector(togglePopover)
            button.target = self
            button.imagePosition = .imageLeading
        }
    }
    
    
    private func setupSubscriptions() {
        let monitor = HardwareMonitorManager.shared
        
        let preferencesPublisher = Publishers.CombineLatest3(
            defaults.publisher(for: \.showMenuBarCPUUsage),
            defaults.publisher(for: \.showMenuBarGPUUsage),
            defaults.publisher(for: \.showMenuBarRAMUsage)
        )
        
        let metricsPublisher = Publishers.CombineLatest3(
            monitor.$cpuHistory,
            monitor.$metrics,
            monitor.$fanRPM
        )
        
        Publishers.CombineLatest(preferencesPublisher, metricsPublisher)
            .throttle(for: .seconds(3), scheduler: DispatchQueue.main, latest: true)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] preferences, data in
                self?.updateMenuBar(
                    showCPUUsage: preferences.0,
                    showGPUUsage: preferences.1,
                    showRAMUsage: preferences.2,
                    cpuHistory: data.0,
                    metrics: data.1
                )
            }
            .store(in: &cancellables)
    }
    
    
    private func updateMenuBar(showCPUUsage: Bool, showGPUUsage: Bool, showRAMUsage: Bool, cpuHistory: [TemperaturePoint], metrics: SystemMetrics?) {

        guard let button = statusItem?.button else { return }
        
        /// If no metric is selected, use default icon
        let showDefault = !showCPUUsage && !showGPUUsage && !showRAMUsage
        
        if showDefault {
            button.image = NSImage(systemSymbolName: "fan.fill", accessibilityDescription: "ThermalPulse")
            button.title = ""
            return
        }
        
        var titleComponents: [String] = []
        
        if showCPUUsage {
            var cpuBlock = "CPU:"
            cpuBlock += String(format: " %.0f%%", (metrics?.cpuUsage ?? 0) * 100)
            cpuBlock += String(format: " %.0f°", HardwareMonitorManager.shared.cpuTemp)
            titleComponents.append(cpuBlock)
        }
        
        if showGPUUsage{
            var gpuBlock = "GPU:"
            gpuBlock += String(format: " %.0f%%", (metrics?.gpuUsage ?? 0) * 100)
            gpuBlock += String(format: " %.0f°", HardwareMonitorManager.shared.gpuTemp)
            titleComponents.append(gpuBlock)
        }
        
        if showRAMUsage {
            let ramUsageValue = metrics?.ramUsage ?? 0
            titleComponents.append(String(format: "RAM: %.0f%%", ramUsageValue * 100))
        }
        
        button.image = NSImage(systemSymbolName: "", accessibilityDescription: "Metrics")
        button.title = titleComponents.joined(separator: " | ")
    }
    
    // MARK: - NSPopoverDelegate
    
    @objc func popoverWillShow(_ notification: Notification) {
        HardwareMonitorManager.shared.setHighPriority(true)
    }
    
    @objc func popoverDidClose(_ notification: Notification) {
        HardwareMonitorManager.shared.setHighPriority(false)
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        guard let button = statusItem?.button else { return }
        
        if popover.isShown {
            popover.performClose(sender)
        } else if button == sender as? NSStatusBarButton {
            NSApp.activate(ignoringOtherApps: true)
            //DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                self.popover.contentViewController?.view.window?.makeKey()
            //}
        }
    }
}
