//
//  XPCClient.swift
//  ThermalPulse
//
//  Created by Arnaldo Baumanis on 5/17/26.
//

import Foundation

class XPCClient {
    static let shared = XPCClient()
    private var connection: NSXPCConnection?

    func establishConnection() -> ThermalPulseHelperProtocol? {
        if connection == nil {
            /// Direct connection to the Mach service registered by the global LaunchDaemon
            let connection = NSXPCConnection(machServiceName: HelperInstaller.helperID, options: .privileged)
            connection.remoteObjectInterface = NSXPCInterface(with: ThermalPulseHelperProtocol.self)
            
            connection.interruptionHandler = {
                print("XPC connection interrupted")
            }
            connection.invalidationHandler = {
                print("XPC connection invalidated")
            }
            
            connection.resume()
            self.connection = connection
        }
        
        return connection?.remoteObjectProxy as? ThermalPulseHelperProtocol
    }
    
    func invalidate() {
        connection?.invalidate()
        connection = nil
    }
}
