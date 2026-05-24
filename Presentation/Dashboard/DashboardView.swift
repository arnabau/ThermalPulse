//
//  DashboardView.swift
//  ThermalPulse
//
//  Created by Arnaldo Baumanis on 5/8/26.
//

import SwiftUI

@MainActor
struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var refreshRotation: Double = 0
    
    var body: some View {
        VStack(spacing: 7) {
            Header
            
            HistoryChart()
            
            MetricSection()
            
            /// Disks
            if !viewModel.diskMetrics.isEmpty {
                VStack(spacing: 8) {
                    ForEach(viewModel.diskMetrics) { disk in
                        DiskUsageRow(disk: disk)
                    }
                }
                .tpCardStyle()
            }
            
            /// Power/battery
            HStack (spacing: 10) {
                let bLevel = viewModel.metrics?.batteryLevel ?? 0
                let showBattery = bLevel > 0
                
                StatCard(title: "Power", value: String(format: "%.1f", viewModel.powerUsage), unit: "W", status: viewModel.metrics?.batterySource ?? "Desktop", accentColor: .tpAccentGreen, icon: viewModel.metrics?.batteryIsCharging == true ? "battery.100.bolt" : "bolt.fill", batteryLevel: showBattery ? bLevel : nil)
            }
            
            /// Fan Section
            if viewModel.fanNumber > 0 {
                FanSection()
            } else {
                NoFanSection()
            }
            
            Capsule().fill(Color.tpAccentBlue).frame(height: 2).frame(width: 50)
            
            /// Footer Controls
            VStack {
                HStack {
                    /// Social networks icons...
                    Button(action: {
                        NSWorkspace.shared.open(URL(string: "https://github.com/arnabau")!)
                    }) {
                        GitHub()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Check out my GitHub page")
                    
                    Button(action: {
                        NSWorkspace.shared.open(URL(string: "https://www.linkedin.com/in/arnaldo-baumanis/")!)
                    }) {
                        LinkedIn()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Check out my LinkedIn page")

                    Spacer()

                    Text("Startup?").font(.caption2).foregroundColor(.secondary)
                    Toggle("Startup?", isOn: $viewModel.launchAtLogin)
                        .toggleStyle(.switch)
                        .labelsHidden()
                }
            }
            .padding(5)
        }
        .padding(8)
        .frame(width: 320)
        .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow).ignoresSafeArea())
    }
    
    
    // MARK: - Subviews
    
    private var Header: some View {
        HStack(spacing: 6) {
            Image(systemName: "fanblades.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.tpAccentTeal)
                .frame(width: 32, height: 32)
                .background(Color.tpAccentTeal.opacity(0.05))
                .clipShape(Circle())
            VStack(alignment: .leading) {
                Text("ThermalPulse v\(Bundle.main.releaseVersionNumber ?? "1.0")")
                    .font(.headline)
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.5)) { refreshRotation += 360 }
                viewModel.refreshAll()
            }) {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .foregroundColor(.secondary)
                    .font(Font.system(size: 16).bold())
            }.buttonStyle(.plain).help(Text("Refresh metrics")).focusEffectDisabled().rotationEffect(.degrees(refreshRotation))
            
            Button(action: { NSApp.terminate(nil) }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
                    .font(Font.system(size: 16).bold())
            }.buttonStyle(.plain).help(Text("Quit ThermalPulse")).focusEffectDisabled()
        }
        .padding(3)
    }
    
    
    private func HistoryChart() -> some View {
        HStack(spacing: 10) {
            /// CPU
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("CPU").font(.system(size: 12, weight: .bold)).foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(viewModel.cpuTemp))°").font(.system(size: 18, weight: .medium, design: .rounded))
                }
                
                TrendChart(data: viewModel.cpuHistory, color: .tpAccentOrange)
            }
            .tpCardStyle()
            
            /// GPU
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("GPU").font(.system(size: 12, weight: .bold)).foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(viewModel.gpuTemp))°").font(.system(size: 18, weight: .medium, design: .rounded))
                }
                
                TrendChart(data: viewModel.gpuHistory, color: .tpAccentPurple)
            }
            .tpCardStyle()
        }
    }
    
    
    struct DiskUsageRow: View {
        let disk: DiskInfo
        
        var usage: Double {
            let used = Double(disk.totalCapacity - disk.availableCapacity)
            return used / Double(disk.totalCapacity)
        }
        
        var body: some View {
            VStack(spacing: 4) {
                HStack {
                    Image(systemName: disk.isInternal ? "internaldrive" : "externaldrive.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    
                    Text(disk.name)
                        .font(.system(size: 10, weight: .medium))
                    
                    Spacer()
                    
                    Text("\(disk.availableCapacityFormatted) free")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
                
                /// Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.2))
                            .frame(height: 4)
                        
                        Capsule()
                            .fill(usage > 0.9 ? Color.red : Color.tpAccentBlue)
                            .frame(width: geo.size.width * CGFloat(usage), height: 4)
                    }
                }
                .frame(height: 4)
            }
            .padding(.vertical, 2)
        }
    }
    
    
    private func MetricSection() -> some View {
        VStack {
            HStack (alignment: .top, spacing: 2) {
                MetricSelector(
                    isActive: viewModel.showMenuBarCPUUsage,
                    toggleAction: { viewModel.showMenuBarCPUUsage.toggle() },
                    tooltip: "Show CPU usage in menu bar",
                    chartView: DonutChart(
                        progress: viewModel.metrics?.cpuUsage ?? 0,
                        accentColor: .tpAccentOrange,
                        label: "cpu",
                        height: 60
                    )
                )
                
                MetricSelector(
                    isActive: viewModel.showMenuBarGPUUsage,
                    toggleAction: { viewModel.showMenuBarGPUUsage.toggle() },
                    tooltip: "Show GPU usage in menu bar",
                    chartView: DonutChart(
                        progress: viewModel.metrics?.gpuUsage ?? 0,
                        accentColor: .tpAccentPurple,
                        label: "gpu",
                        height: 60
                    )
                )
                
                MetricSelector(
                    isActive: viewModel.showMenuBarRAMUsage,
                    toggleAction: { viewModel.showMenuBarRAMUsage.toggle() },
                    tooltip: "Show RAM usage in menu bar",
                    chartView: DonutChart(
                        progress: viewModel.metrics?.ramUsage ?? 0,
                        accentColor: .tpAccentGreen,
                        label: "ram",
                        height: 60
                    ).help(viewModel.ramSummary)
                )
            }
            .frame(maxWidth: .infinity)
            
            Divider().opacity(0.2).padding(2)
            
            HardwareSpecsDetails()
            
        }
        .frame(maxWidth: .infinity)
        .tpCardStyle()
    }
    
    
    private func HardwareSpecsDetails() -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Label("\(viewModel.metrics?.macDescriptionName ?? "Unknown")", systemImage: "desktopcomputer").bold()
                Text("\(viewModel.metrics?.gpuName ?? "")")
            }
            
            HStack {
                Label("\(viewModel.metrics?.coreCount ?? 0) Cores CPU (\(viewModel.metrics?.performanceCores ?? 0)P / \(viewModel.metrics?.efficiencyCores ?? 0)E) \(viewModel.metrics?.gpuCores ?? 0) Cores GPU", systemImage: "cpu")
            }
            
            HStack {
                Label("\(viewModel.metrics?.ramFormatted ?? "") Total RAM - Pressure: ", systemImage: "memorychip")
                Text("\(viewModel.metrics?.memoryPressure ?? "")").foregroundColor((viewModel.metrics?.memoryPressure == "Normal") ? .tpAccentGreen : .orange)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(2)
        .foregroundColor(.secondary)
        .font(Font.system(size: 11))
    }
}


struct ModeButton: View {
    let title: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
                .frame(height: 25)
                .font(.system(size: 12, weight: .bold))
                .background(isActive ? Color.tpAccentBlue.opacity(0.6) : Color.clear)
                .foregroundColor(isActive ? .white : .secondary)
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}


struct FanSection: View {
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Fan Management")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.secondary)
                Spacer()
                Circle().fill(Color.green).frame(width: 8, height: 8)
                Text("\(viewModel.fanNumber)").font(.caption2).foregroundColor(.secondary)
            }
            
            if !viewModel.fanRPM.isEmpty {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text("\(viewModel.fanRPM[0])")
                                .font(.system(size: 32, weight: .medium, design: .rounded))
                            Text("rpm")
                                .font(.system(size: 16, weight: .medium, design: .monospaced))
                        }
                        
                        // more than one fan...
                        if viewModel.fanRPM.count > 1 {
                            ForEach(1..<viewModel.fanRPM.count, id: \.self) { index in
                                Text("#\(index + 1) \(viewModel.fanRPM[index]) rpm")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Spacer()
                    DonutChart(progress: viewModel.fanProgress, accentColor: .tpAccentBlue, label: "", height: 52)
                }
                .padding(2)
            }
            
            /// Control Banner
            ModeBanner
            
            /// manual buttons section
            ManualModeSection
        }
        .tpCardStyle()
    }
    
    
    private var ManualModeSection: some View {
        VStack {
            Divider().opacity(0.2)
            
            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    ForEach(ThermalProfile.allCases) { profile in
                        let isSelected = viewModel.selectedProfile == profile
                        let isAllowed = profile == .system || viewModel.isHelperInstalled
                        Button(action: { viewModel.setProfile(profile) }) {
                            VStack(spacing: 6) {
                                Image(systemName: profileIcon(for: profile))
                                    .font(.title3)
                                Text(profile.rawValue)
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(isSelected ? profileColor(for: profile).opacity(0.15) : Color.gray.opacity(0.05))
                            .foregroundColor(isSelected ? profileColor(for: profile) : .secondary)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isSelected ? profileColor(for: profile) : Color.clear, lineWidth: 1.5)
                            )
                        }
                        .disabled(!isAllowed || isSelected)
                        .opacity(isAllowed ? 1.0 : 0.4)
                        .buttonStyle(.plain)
                        .help(isAllowed ? "Activate profile \(profile.rawValue)" : "Requiere Privileged Helper Tool")
                    }
                }
                .padding(.horizontal)
                
                Divider().opacity(0.2)
                
                if !viewModel.isHelperInstalled {
                    HStack(spacing: 8) {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.orange)
                        Text("Manual control requires installing a secure system component to adjust hardware speeds")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Button("Install Privileged Helper Tool?") {
                        Task { viewModel.installHelperTool() }
                    }
                    .controlSize(.small)
                    .tint(.blue)
                    
                } else {
                    Button("Uninstall Privileged Helper Tool?") {
                        viewModel.removeHelperTool()
                    }
                    .controlSize(.small)
                    .tint(.blue)
                }
            }
        }
    }
    
    
    private var ModeBanner: some View {
        let currentProfile = viewModel.selectedProfile
        
        return HStack(spacing: 6) {
            Image(systemName: currentProfile.iconName)
                .font(.title2)
                .foregroundColor(currentProfile.themeColor)
                .frame(width: 30, height: 30)
                .background(currentProfile.themeColor.opacity(0.15))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Mode: \(currentProfile.rawValue)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                Text(currentProfile.bannerDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(.all, 6)
        .background(
            currentProfile.themeColor
                .opacity(0.08)
        )
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(currentProfile.themeColor.opacity(0.2), lineWidth: 1)
        )
        .animation(.smooth(duration: 0.35), value: currentProfile)
    }
}

struct NoFanSection: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "leaf.fill")
                .foregroundColor(.green)
                .font(.system(size: 24))
            Text("Passive Cooling")
                .font(.caption.bold())
                .font(.caption.bold())
            Text("No fans detected")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 80)
        .tpCardStyle()
    }
}

func profileIcon(for profile: ThermalProfile) -> String {
    switch profile {
    case .system: return "leaf.fill"
    case .balanced: return "wind"
    case .aggressive: return "flame.fill"
    }
}

func profileColor(for profile: ThermalProfile) -> Color {
    switch profile {
    case .system: return .green
    case .balanced: return .blue
    case .aggressive: return .orange
    }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) { }
}

// Get app version
extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
