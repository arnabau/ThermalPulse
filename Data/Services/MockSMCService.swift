//
//  MockSMCService.swift
//  ThermalPulse
//
//  Created by Arnaldo Baumanis on 5/8/26.
//

import Foundation

class MockSMCService: SMCServiceProtocol {
    func getCPUTemperature() async throws -> Double { return 42.5 }
    func getGPUTemperature() async throws -> Double { return 38.0 }
    func getFanNumber() async -> Int { return 2 }
    func getFanSpeed(for fanIndex: Int) async throws -> Int { return fanIndex == 0 ? 1250 : 1350 }
    func setFanSpeed(for fanIndex: Int, rpm: Int) async throws { print("Mock: Ajustando fan \(fanIndex) a \(rpm) RPM") }
    func setFanControlMode(isManual: Bool) async throws { print("Mock: Modo manual \(isManual)") }
    func getFanMaxRPM(for fanIndex: Int) async throws -> Int {print(fanIndex); return 6000}
    func getFanMinRPM(for fanIndex: Int) async throws -> Int {print(fanIndex); return 1000}
    func getPowerUsage() async throws -> Double { return 5.2 }
}
