//
//  StatCard.swift
//  ThermalPulse
//
//  Created by Arnaldo Baumanis on 5/8/26.
//

import SwiftUI
import Charts

struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let status: String
    let accentColor: Color
    let icon: String
    var batteryLevel: Double? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(status)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(accentColor)
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(accentColor)
            }
            
            HStack(spacing: 2) {
                HStack {
                    Text(value)
                        .font(.system(size: 25, weight: .medium, design: .rounded))
                    Text(unit)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if let level = batteryLevel {
                    HStack {
                        BatteryBar(level: level)
                            .frame(maxWidth: .infinity)
                        Text("\(Int(level * 100))%")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color.secondary)
                    }
                }
            }
        }
        .tpCardStyle()
    }
}

struct DonutChart: View {
    let progress: Double // 0.0 to 1.0
    let accentColor: Color
    let label: String
    let height: CGFloat
    
    private struct ChartData: Identifiable {
        let id = UUID()
        let name: String
        let value: Double
    }
    
    private var chartData: [ChartData] {
        [
            ChartData(name: "Used", value: progress),
            ChartData(name: "Free", value: max(0, 1.0 - progress))
        ]
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 6)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(accentColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
            
            VStack(spacing: 0) {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                if !label.isEmpty {
                    Text("\(label)")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(width: height, height: height)
    }
}


struct MetricSelector<Content: View>: View {
    let isActive: Bool
    let toggleAction: () -> Void
    let tooltip: String
    let chartView: Content
    
    var body: some View {
        VStack(spacing: 1) {
            Button(action: toggleAction) {
                Image(systemName: isActive ? "checkmark.seal.fill" : "checkmark.seal.fill")
                    .foregroundColor(isActive ? .tpAccentTeal : .secondary.opacity(0.6))
                    .font(.system(size: 13, weight: .bold))
            }
            .frame(maxWidth: .infinity, alignment: .topTrailing)
            .buttonStyle(.plain)
            .focusEffectDisabled()
            .help(tooltip)
            
            /// DonutChart inyection
            chartView
        }
        .frame(maxWidth: .infinity)
    }
}

struct BatteryBar: View {
    let level: Double // 0.0 a 1.0
    
    var body: some View {
        GeometryReader { geo in
            Capsule()
                .fill(Color.secondary.opacity(0.2))
                .frame(height: 6)
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(colorForLevel(level))
                        .frame(width: geo.size.width * CGFloat(max(0, min(1, level))), height: 6)
                        .animation(.easeInOut(duration: 0.5), value: level)
                }
        }
        .frame(height: 6)
    }
    
    private func colorForLevel(_ level: Double) -> Color {
        level > 0.2 ? .tpAccentBlue : .tpAccentOrange
    }
}


#Preview {
//    @Previewable @StateObject var viewModel = DashboardViewModel()
//    
//    StatCard(title: "Power", value: String(format: "%.1f", viewModel.powerUsage), unit: "W", status: viewModel.metrics?.batterySource ?? "Desktop", accentColor: .tpAccentGreen, icon: viewModel.metrics?.batteryIsCharging == true ? "battery.100.bolt" : "bolt.fill")
    
    DonutChart(progress: 0.7, accentColor: .blue, label: "CPU", height: 52)
    
    StatCard(title: "Temperature", value: "23", unit: "°C", status: "Normal", accentColor: .blue, icon: "")
    StatCard(title: "CPU", value: "32", unit: "°", status: "Normal", accentColor: .tpAccentOrange, icon: "")
}
