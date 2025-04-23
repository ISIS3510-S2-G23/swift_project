//
//  Untitled.swift
//  swift_app
//
//  Created by Paulina Arrazola on 23/04/25.
//

import Foundation
import Network

enum NetworkStatus {
    case connected
    case disconnected
}

class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
    
    var status: NetworkStatus = .disconnected
    var isConnected: Bool { status == .connected }
    
    private init() {
        startMonitoring()
    }
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    self.status = .connected
                    NotificationCenter.default.post(name: .networkStatusChanged, object: nil)
                } else {
                    self.status = .disconnected
                }
            }
        }
        
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}

extension Notification.Name {
    static let networkStatusChanged = Notification.Name("networkStatusChanged")
}
