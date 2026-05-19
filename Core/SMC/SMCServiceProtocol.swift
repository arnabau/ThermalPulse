//
//  SMCServiceProtocol.swift
//  ThermalPulse
//
//  Created by Arnaldo Baumanis on 5/8/26.
//
// Protocols and Wrappers for SMCKit

import Foundation
import SMCKit

/// Protocol defining the hardware interactions needed for ThermalPulse.
protocol SMCServiceProtocol {
    func getCPUTemperature() async  throws -> Double
    func getGPUTemperature() async throws -> Double
    func getFanNumber() async  -> Int
    func getFanSpeed(for fanIndex: Int) async  throws -> Int
    func setFanSpeed(for fanIndex: Int, rpm: Int) async  throws
    func setFanControlMode(isManual: Bool) async throws
    func getFanMaxRPM(for fanIndex: Int) async  throws -> Int
    func getFanMinRPM(for fanIndex: Int) async  throws -> Int
    func getPowerUsage() async  throws -> Double
}
