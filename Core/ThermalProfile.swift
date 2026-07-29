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
    case cool = "Cool"
    case aggressive = "Aggressive"
    
    var id: String { self.rawValue }
    
    /// Minimum threshold where the fan starts to accelerate above its base (Celsius)
    var tempMin: Double {
        switch self {
        case .system: return 0.0
        case .balanced: return 75.0
        case .cool: return 60.0
        case .aggressive: return 50.0
        }
    }
    
    /// Maximum threshold where the fan should be delivering its assigned maximum
    var tempMax: Double {
        switch self {
        case .system: return 0.0
        case .balanced: return 99.0
        case .cool: return 90.0
        case .aggressive: return 80.0
        }
    }
    
    /// Define what percentage of the fan's physical range each profile uses.
    /// Final value = Minimum + (Range x Percentage)
    func rpmBounds(minPhysical: Double, maxPhysical: Double) -> (min: Double, max: Double) {
        let range = maxPhysical - minPhysical
        switch self {
        case .system:
            return (minPhysical, maxPhysical)
        case .balanced:
            /// Silent: Maintains minimum noise level for longer, maximum limited to 50% of capacity
            return (minPhysical, minPhysical + (range * 0.50))
            //return (minPhysical + (range * 0.05), minPhysical + (range * 0.50))
        case .cool:
            return (minPhysical + (range * 0.10), minPhysical + (range * 0.75)) /// set min to 10% max to 75%
        case .aggressive:
            /// High performance: Elevated base for preventative cooling. minPhysical + 20% is gonna be "the floor" always
            return (minPhysical + (range * 0.20), minPhysical + (range * 0.90)) /// set min to 20% max to 90%
            //return (minPhysical + (range * 0.25), maxPhysical) /// use 100% if needed
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
            case .cool:
            return .tpAccentTeal.opacity(0.7)
        case .aggressive:
            return .tpAccentOrange
        }
    }
    
    var iconName: String {
        switch self {
        case .system: return "leaf.fill"
        case .balanced: return "wind"
        case .cool: return "snowflake"
        case .aggressive: return "flame.fill"
        }
    }
    
    var bannerDescription: String {
        switch self {
        case .system:
            return "Automatic control. (Apple native)"
        case .balanced:
            return "Optimizes thermal flow. Quiet but not to hot"
        case .cool:
            return "Keeps you cool in hot conditions"
        case .aggressive:
            return "Proactive dissipation. Use 100% if needed"
        }
    }
}
