//
//  ThermalProfile.swift
//  ThermalPulse
//
//  Created by Arnaldo Baumanis on 5/15/26.
//

import Foundation
import SwiftUI

enum ThermalProfile: String, CaseIterable, Identifiable {
    case system = "System"
    case balanced = "Balanced"
    case aggressive = "Aggressive"
    
    var id: String { self.rawValue }
    
    /// Minimum threshold where the fan starts to accelerate above its base (Celsius)
    var tempMin: Double {
        switch self {
        case .system: return 0.0
        case .balanced: return 75.0
        case .aggressive: return 45.0
        }
    }
    
    /// Maximum threshold where the fan should be delivering its assigned maximum
    var tempMax: Double {
        switch self {
        case .system: return 0.0
        case .balanced: return 95.0
        case .aggressive: return 75.0
        }
    }
    
    /// Define what percentage of the fan's physical range each profile uses.
    func rpmBounds(minPhysical: Double, maxPhysical: Double) -> (min: Double, max: Double) {
        let range = maxPhysical - minPhysical
        switch self {
        case .system:
            return (minPhysical, maxPhysical)
        case .balanced:
            /// Silent: Maintains minimum noise level for longer, maximum limited to 50% of capacity
            return (minPhysical, minPhysical + (range * 0.50))
//        case .airwaves:
//            // Airwaves: A small increase at the base, up to 80% capacity
//            return (minPhysical + (range * 0.10), minPhysical + (range * 0.80))
        case .aggressive:
            /// High performance: Elevated base for preventative cooling, use 100% if needed
            return (minPhysical + (range * 0.25), maxPhysical)
        }
    }
}

extension ThermalProfile {
    var themeColor: Color {
        switch self {
        case .system:
            return .tpAccentGreen
        case .balanced:
            return .tpAccentBlue
        case .aggressive:
            return .tpAccentOrange
        }
    }
    
    var iconName: String {
        switch self {
        case .system: return "leaf.fill"
        case .balanced: return "wind"
        case .aggressive: return "flame.fill"
        }
    }
    
    var bannerDescription: String {
        switch self {
        case .system:
            return "Automatic control. (Apple native)"
        case .balanced:
            return "Optimizes thermal flow. Quiet environment"
        case .aggressive:
            return "Proactive dissipation"
        }
    }
}
