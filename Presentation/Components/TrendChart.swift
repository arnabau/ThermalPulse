//
//  TrendChart.swift
//  ThermalPulse
//
//  Created by Arnaldo Baumanis on 5/10/26.
//

import SwiftUI
import Charts // macOS 13+

struct TemperaturePoint: Identifiable {
    let id = UUID()
    let time: Date
    let temperature: Double
    
    static func == (lhs: TemperaturePoint, rhs: TemperaturePoint) -> Bool {
        lhs.id == rhs.id
    }
}

struct TrendChart: View {
    let data: [TemperaturePoint]
    let color: Color
    
    var body: some View {
        Chart {
            ForEach(data) { point in
                // main line
                LineMark(
                    x: .value("Time", point.time),
                    y: .value("Temp", point.temperature)
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(color)
                .lineStyle(StrokeStyle(lineWidth: 1))

                // shadow under line
                AreaMark(
                    x: .value("Time", point.time),
                    y: .value("Temp", point.temperature)
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(
                    LinearGradient(
                        colors: [color.opacity(0.2), color.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartYScale(domain: 20...80)
        .frame(height: 20)
    }
}
