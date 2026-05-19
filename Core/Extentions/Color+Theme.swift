//
//  Color+Theme.swift
//  ThermalPulse
//
//  Created by Arnaldo Baumanis on 5/8/26.
//

import Foundation
import SwiftUI

extension Color {
    static let tpBackground = Color(NSColor.windowBackgroundColor).opacity(0.85)
    static let tpCardBackground = Color.black.opacity(0.3)
    static let tpAccentOrange = Color.orange
    static let tpAccentGreen = Color.green
    static let tpAccentBlue = Color(red: 0.0, green: 0.5, blue: 1.0)
    static let tpAccentPurple = Color.purple
    static let tpAccentTeal = Color(red: 0.0, green: 1.0, blue: 1.0)
}

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.tpCardBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}

extension View {
    func tpCardStyle() -> some View {
        self.modifier(CardModifier())
    }
}
