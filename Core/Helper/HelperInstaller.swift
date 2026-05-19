//
//  HelperInstaller.swift
//  ThermalPulse
//
//  Created by Arnaldo Baumanis on 5/17/26.
//
// This class will be responsible for validating the existence of the components,
// building the terminal script, and requesting native privilege elevation through the macOS authorization system

import Foundation
import os

final class HelperInstaller {
    private static let logger = Logger(subsystem: "com.arnaldobaumanis.ThermalPulse", category: "HelperInstaller")
    
    static let helperID = "com.arnaldobaumanis.ThermalPulse.Helper"
    static let helperPath = "/Library/PrivilegedHelperTools/\(helperID)"
    static let plistPath = "/Library/LaunchDaemons/\(helperID).plist"
    
    /// Check if the daemon is already physically installed on the system
    static func isInstalled() -> Bool {
        return FileManager.default.fileExists(atPath: helperPath) &&
               FileManager.default.fileExists(atPath: plistPath)
    }
    
    /// Run the installation securely with elevated privileges
    static func install() async -> Bool {
        /// Locate the Helper binary and the Plist within our own App Bundle
        guard let bundleHelperURL = Bundle.main.url(forResource: helperID, withExtension: nil),
              let bundlePlistURL = Bundle.main.url(forResource: "\(helperID).plist", withExtension: nil) else {
            logger.fault("Critical error: Helper resources not found in App Bundle")
            return false
        }
        
        let srcHelper = bundleHelperURL.path
        let srcPlist = bundlePlistURL.path
        
        /// Build the atomic sequence of Unix commands. We use absolute and immutable paths to prevent hijacking attacks.
        let script = """
        mkdir -p /Library/PrivilegedHelperTools
        cp '\(srcHelper)' '\(helperPath)'
        cp '\(srcPlist)' '\(plistPath)'
        chown root:wheel '\(helperPath)'
        chmod 755 '\(helperPath)'
        chown root:wheel '\(plistPath)'
        chmod 644 '\(plistPath)'
        launchctl unload '\(plistPath)' 2>/dev/null
        launchctl load -w '\(plistPath)'
        """
        
        /// Run using osascript to bring up the native macOS authentication dialog box
        return await Task.detached(priority: .userInitiated) {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
            process.arguments = ["-e", "do shell script \"\(script)\" with administrator privileges"]
            
            do {
                try process.run()
                process.waitUntilExit()
                let success = process.terminationStatus == 0
                if success {
                    await logger.info("Helper installed and successfully loaded as LaunchDaemons")
                } else {
                    await logger.error("The user canceled or the installation script failed with status: \(process.terminationStatus)")
                }
                return success
            } catch {
                await logger.fault("Execution failure while attempting to run osascript: \(error.localizedDescription)")
                return false
            }
        }.value
    }
    
    static func uninstall() async -> Bool {
        /// Verify if there is actually something to uninstall
        guard isInstalled() else { return true }
        
        /// Script to download the launchd daemon and delete the physical files
        let script = """
            launchctl unload '\(plistPath)' 2>/dev/null
            launchctl bootout system '\(plistPath)' 2>/dev/null
            rm -f '\(helperPath)'
            rm -f '\(plistPath)'
            """
        
        /// Run asynchronously, requesting credentials from the user
        return await Task.detached(priority: .userInitiated) {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
            process.arguments = ["-e", "do shell script \"\(script)\" with administrator privileges"]
            
            do {
                try process.run()
                process.waitUntilExit()
                let success = process.terminationStatus == 0
                if success {
                    await logger.info("Daemon downloaded and cleanly removed from the system")
                } else {
                    await logger.error("Failed to uninstall Daemon (status: \(process.terminationStatus))")
                }
                return success
            } catch {
                await logger.fault("Critical error during uninstallation: \(error.localizedDescription)")
                return false
            }
        }.value
    }
}
