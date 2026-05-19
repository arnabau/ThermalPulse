//
//  ThermalPulseHelper.swift
//  ThermalPulse
//
//  Created by Arnaldo Baumanis on 5/16/26.
//

import Foundation
import os

class ThermalPulseHelper: NSObject, ThermalPulseHelperProtocol {
    /// Instance of SMCService adapted for UI-free execution
    private let smcService = SMCService()
    
    func checkPrivileges(completion: @escaping (Bool, String?) -> Void) {
        let euid = geteuid()
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        
        ///UID == 0 (root)
        completion(euid == 0, version)
    }
    
    func setFanControlMode(isManual: Bool, completion: @escaping (Bool) -> Void) {
        Task {
            do {
                try await smcService.setFanControlMode(isManual: isManual)
                completion(true)
            } catch {
                //
            }
        }
    }
    
    func setFanSpeed(index: Int, rpm: Int, completion: @escaping (Bool) -> Void) {
        Task {
            do {
                try await smcService.setFanSpeed(for: index, rpm: rpm)
                completion(true)
            } catch {
                //
            }
        }
    }
}
