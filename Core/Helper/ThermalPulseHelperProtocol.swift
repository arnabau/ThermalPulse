//
//  ThermalPulseHelperProtocol.swift
//  ThermalPulse
//
//  Created by Arnaldo Baumanis on 5/8/26.
//

import Foundation

/// The protocol that the privileged helper tool must implement
/// All XPC functions must be asynchronous or use completion handlers
@objc protocol ThermalPulseHelperProtocol {
    func checkPrivileges(completion: @escaping (Bool, String?) -> Void)
    func setFanSpeed(index: Int, rpm: Int, completion: @escaping (Bool) -> Void)
    func setFanControlMode(isManual: Bool, completion: @escaping (Bool) -> Void)
}
